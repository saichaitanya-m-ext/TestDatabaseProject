/*    
-------------------------------------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_Assignment_PatientConflict]1,62,0  
Description   : This procedure is used to get the details of population definition  
Created By    : Rathnam  
Created Date  : 27.09.2012    
--------------------------------------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
25-Jul-2013 NagaBabu Modified UserProgram tables and Columns into PatientProgram and Columns.    
--------------------------------------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Assignment_PatientConflict] (
	@i_AppUserId INT
	,@i_ProgramID INT
	,@IsAutoConflict BIT --> 1 means Autometic , 0 means Manual  
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		-- Check if valid Application User ID is passed    
		IF (@i_AppUserId IS NULL)
			OR (@i_AppUserId <= 0)
		BEGIN
			RAISERROR (
					N'Invalid Application User ID %d passed.'
					,17
					,1
					,@i_AppUserId
					)
		END

		--- Getting the Program related patients  
		SELECT DISTINCT PatientUserID
		INTO #patList
		FROM ProgramTaskBundle
		INNER JOIN ProgramPatientTaskConflict ON ProgramPatientTaskConflict.ProgramTaskBundleId = ProgramTaskBundle.ProgramTaskBundleID
		INNER JOIN TaskBundle ON TaskBundle.TaskBundleId = ProgramTaskBundle.TaskBundleID
		WHERE ProgramTaskBundle.ProgramID = @i_ProgramID
			AND ProgramTaskBundle.StatusCode = 'A'
			AND ProgramPatientTaskConflict.StatusCode = 'A'
			AND TaskBundle.StatusCode = 'A'

		--- Getting the Program related tasks  
		SELECT DISTINCT ProgramID
			,TaskType
			,GeneralizedID
		INTO #patTasks
		FROM ProgramTaskBundle
		INNER JOIN TaskBundle ON TaskBundle.TaskBundleId = ProgramTaskBundle.TaskBundleID
		WHERE ProgramID = @i_ProgramID
			AND ProgramTaskBundle.StatusCode = 'A'
			AND TaskBundle.StatusCode = 'A'

		CREATE NONCLUSTERED INDEX [IX_Pat] ON [dbo].[#patList] ([PatientUserID])

		SELECT DISTINCT pptc.PatientUserID
			,ptb.ProgramTaskBundleID
			,ptb.ProgramID
			,ptb.TaskType
			,ptb.GeneralizedID
			,ptb.TaskBundleID
			,ptb.FrequencyNumber
			,ptb.Frequency
		INTO #ConflictPatients
		FROM ProgramPatientTaskConflict pptc
		INNER JOIN ProgramTaskBundle ptb ON ptb.ProgramTaskBundleID = pptc.ProgramTaskBundleId
		INNER JOIN TaskBundle tb ON tb.TaskBundleId = ptb.TaskBundleID
		INNER JOIN #patList P ON p.PatientUserid = pptc.patientuserid
		INNER JOIN #patTasks t ON t.TaskType = ptb.TaskType
			AND t.GeneralizedID = ptb.GeneralizedID
		INNER JOIN Program ON Program.ProgramId = ptb.ProgramID
		WHERE ptb.StatusCode = 'A'
			AND tb.StatusCode = 'A'
			AND pptc.StatusCode = 'A'
			AND program.StatusCode = 'A'

		----Not Conflicticed patients  
		SELECT patientuserid
			,generalizedid
			,TaskType
			,COUNT(patientuserid) cnt
		INTO #NotConflictedPatients
		FROM #ConflictPatients
		GROUP BY patientuserid
			,generalizedid
			,TaskType
		HAVING COUNT(patientuserid) = 1

		DELETE
		FROM #ConflictPatients
		WHERE EXISTS (
				SELECT 1
				FROM #NotConflictedPatients
				WHERE #NotConflictedPatients.patientuserid = #ConflictPatients.patientuserid
					AND #NotConflictedPatients.generalizedid = #ConflictPatients.generalizedid
					AND #NotConflictedPatients.tasktype = #ConflictPatients.tasktype
				)

		SELECT p.ProgramID
			,p.ProgramName
			,dbo.ufn_Program_GetTypeNamesByGeneralizedId(TaskType, GeneralizedID) TaskName
			--,dbo.ufn_Program_GetTypeNamesByGeneralizedId(TaskType , GeneralizedID) TaskName1  
			,TaskType
			,GeneralizedID
			,FrequencyNumber
			,Frequency
			,ProgramTaskBundleID
			,COUNT(DISTINCT PatientUserid) PatientCount
			,CASE 
				WHEN Tasktype = 'E'
					THEN ''
				ELSE 'Once Every ' + CONVERT(VARCHAR, #ConflictPatients.FrequencyNumber) + CASE 
						WHEN #ConflictPatients.Frequency = 'W'
							THEN ' Week(s)'
						WHEN #ConflictPatients.Frequency = 'D'
							THEN ' Day(s)'
						WHEN #ConflictPatients.Frequency = 'M'
							THEN ' Month(s)'
						WHEN #ConflictPatients.Frequency = 'Y'
							THEN ' Year(s)'
						END
				END FrequencyTitration
		INTO #TotalConflicts
		FROM #ConflictPatients
		INNER JOIN Program p ON p.ProgramID = #ConflictPatients.ProgramID
		GROUP BY p.ProgramID
			,TaskType
			,generalizedid
			,FrequencyNumber
			,Frequency
			,ProgramTaskBundleID
			,p.ProgramName
		ORDER BY TaskType
			,GeneralizedID

		SELECT ProgramTaskBundleID
			,ProgramName
			,TaskName
			,GeneralizedID
			,FrequencyTitration
			,PatientCount
		FROM #TotalConflicts
		WHERE (
				(
					ProgramId = @i_ProgramID
					AND @IsAutoConflict = 1
					)
				OR @IsAutoConflict = 0
				)

		--- If it is automatic conflict go to the if clause   
		IF @IsAutoConflict = 1
		BEGIN
			SELECT *
				,ROW_NUMBER() OVER (
					PARTITION BY GeneralizedID
					,Tasktype ORDER BY CASE 
							WHEN Frequency = 'D'
								THEN frequencynumber * 1
							WHEN Frequency = 'W'
								THEN frequencynumber * 7
							WHEN Frequency = 'M'
								THEN frequencynumber * 30
							WHEN Frequency = 'Y'
								THEN frequencynumber * 365
							END 
					) FrequencyOrder
			INTO #ConflictUpdate
			FROM #TotalConflicts

			--- updating the conflicted patients which are present in the other progrms based on High Frequency  
			UPDATE ProgramPatientTaskConflict
			SET StatusCode = 'I'
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			FROM #ConflictUpdate
			WHERE #ConflictUpdate.ProgramTaskBundleID = ProgramPatientTaskConflict.ProgramTaskBundleID
				AND EXISTS (
					SELECT 1
					FROM #patList p
					INNER JOIN PatientProgram ups ON p.PatientUserID = ups.PatientID
					WHERE p.patientUserID = ProgramPatientTaskConflict.PatientUserID
						AND ups.ProgramId = #ConflictUpdate.ProgramId
						AND ups.StatusCode = 'A'
					)
				AND FrequencyOrder > 1

			--- updating the conflicted patients which are present in the other progrms based on High Frequency  
			UPDATE ProgramPatientTaskConflict
			SET StatusCode = 'A'
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			FROM #ConflictUpdate
			WHERE #ConflictUpdate.ProgramTaskBundleID = ProgramPatientTaskConflict.ProgramTaskBundleID
				AND EXISTS (
					SELECT 1
					FROM #patList p
					INNER JOIN PatientProgram ups ON p.PatientUserID = ups.PatientID
					WHERE p.patientUserID = ProgramPatientTaskConflict.PatientUserID
						AND ups.ProgramId = #ConflictUpdate.ProgramId
						AND ups.StatusCode = 'A'
					)
				AND FrequencyOrder = 1

			---- Updating the not conflicted patients for that program  
			UPDATE ProgramPatientTaskConflict
			SET StatusCode = 'A'
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			FROM #NotConflictedPatients
			INNER JOIN ProgramTaskBundle ON ProgramTaskBundle.GeneralizedID = #NotConflictedPatients.GeneralizedID
				AND ProgramTaskBundle.TaskType = #NotConflictedPatients.TaskType
			WHERE ProgramTaskBundle.ProgramID = @i_ProgramID
				AND ProgramTaskBundle.ProgramTaskBundleID = ProgramPatientTaskConflict.programtaskbundleid
				AND #NotConflictedPatients.patientuserid = ProgramPatientTaskConflict.patientuserid
		END
	END TRY

	BEGIN CATCH
		---------------------------------------------------------------------------------------------------------------------------    
		-- Handle exception    
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Assignment_PatientConflict] TO [FE_rohit.r-ext]
    AS [dbo];

