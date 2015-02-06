
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Assignment_PatientConflictUpdate]2
Description   : This procedure is used to get the details of population definition
Created By    : Rathnam
Created Date  : 11.10.2012  
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
04-APR-2013 P.V.P.MOHAN modified UserProgram Table to PatientProgram and Columns of that Table .  
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Assignment_PatientConflictUpdate] (
	@i_AppUserId INT
	,@i_ProgramID INT
	,@tblConflicts TBLTASKTYPEANDTYPEID READONLY
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
		DECLARE @dt_date datetime = GETDATE(),
		   @ip_ProgramID INT
		   
		   SET @ip_ProgramID = @i_ProgramID 
		  
		  CREATE TABLE #Conflicts(TypeID INT,TID INT)
		  INSERT INTO #Conflicts
		  SELECT * FROM @tblConflicts
		
		 

		--- Getting the Program related patients
		SELECT DISTINCT PatientUserID
		INTO #patList 
		FROM ProgramTaskBundle
		INNER JOIN ProgramPatientTaskConflict ON ProgramPatientTaskConflict.ProgramTaskBundleId = ProgramTaskBundle.ProgramTaskBundleID
		INNER JOIN TaskBundle ON TaskBundle.TaskBundleId = ProgramTaskBundle.TaskBundleID
		WHERE ProgramTaskBundle.ProgramID = @ip_ProgramID
			AND ProgramTaskBundle.StatusCode = 'A'
			AND ProgramPatientTaskConflict.StatusCode = 'A'
			AND TaskBundle.StatusCode = 'A'
			
		 
		 CREATE NONCLUSTERED INDEX [IX_#patList_PatientUserid] ON #patList (PatientUserid)

		--- Getting the Program related tasks
		SELECT DISTINCT ProgramID
			,TaskType
			,GeneralizedID
		INTO #patTasks
		FROM ProgramTaskBundle
		INNER JOIN TaskBundle ON TaskBundle.TaskBundleId = ProgramTaskBundle.TaskBundleID
		WHERE ProgramID = @ip_ProgramID
			AND ProgramTaskBundle.StatusCode = 'A'
			AND TaskBundle.StatusCode = 'A'
			
		

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

        CREATE NONCLUSTERED INDEX [IX_#NotConflictedPatients_GeneralisedID] ON #NotConflictedPatients (GeneralizedID)
		-- 
		UPDATE ProgramPatientTaskConflict
		SET StatusCode = 'I'
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = @dt_date
		FROM #Conflicts t
		WHERE t.TypeID = ProgramPatientTaskConflict.ProgramTaskBundleID
			AND EXISTS (
				SELECT 1
				FROM #patList p
				INNER JOIN PatientProgram ups ON ups.PatientID = p.PatientUserID
				INNER JOIN ProgramTaskBundle ptb ON ptb.ProgramID = ups.ProgramId
				WHERE p.patientUserID = ProgramPatientTaskConflict.PatientUserID
					AND ptb.ProgramTaskBundleID = t.TypeID
					AND ups.StatusCode = 'A'
				)
			AND t.TypeID = 0 -- User Not selected from the application
			
		 	

		UPDATE ProgramPatientTaskConflict
		SET StatusCode = 'A'
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = @dt_date
		FROM #Conflicts t
		WHERE t.TypeID = ProgramPatientTaskConflict.ProgramTaskBundleID
			AND EXISTS (
				SELECT 1
				FROM #patList p
				INNER JOIN PatientProgram ups ON ups.patientID = p.PatientUserID
				INNER JOIN ProgramTaskBundle ptb ON ptb.ProgramID = ups.ProgramId
				WHERE p.patientUserID = ProgramPatientTaskConflict.PatientUserID
					AND ptb.ProgramTaskBundleID = t.TypeID
					AND ups.StatusCode = 'A'
				)
			AND t.TypeID = 1 -- User  selected from the application
		
		 	

		UPDATE ProgramPatientTaskConflict
		SET StatusCode = 'A'
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = @dt_date
		FROM #NotConflictedPatients
		INNER JOIN ProgramTaskBundle ON ProgramTaskBundle.GeneralizedID = #NotConflictedPatients.GeneralizedID
			AND ProgramTaskBundle.TaskType = #NotConflictedPatients.TaskType
		WHERE ProgramTaskBundle.ProgramID = @ip_ProgramID
			AND ProgramTaskBundle.ProgramTaskBundleID = ProgramPatientTaskConflict.programtaskbundleid
			AND #NotConflictedPatients.patientuserid = ProgramPatientTaskConflict.patientuserid
		 
			
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
    ON OBJECT::[dbo].[usp_Assignment_PatientConflictUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

