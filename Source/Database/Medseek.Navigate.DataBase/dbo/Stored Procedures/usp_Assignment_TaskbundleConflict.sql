
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Assignment_TaskbundleConflict
Description   : This procedure is used to get the information regaring the conflicts for the assginment
Created By    : Rathnam  
Created Date  : 08-Oct-2012  
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Assignment_TaskbundleConflict] (
	@i_AppUserId KEYID
	,@i_ProgramID KEYID = NULL
	,@b_IsMapTaskBundleLevel ISINDICATOR = 0
	,@o_ConflictReturn BIT OUTPUT
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

		SET @o_ConflictReturn = 0

		IF @b_IsMapTaskBundleLevel = 0
		BEGIN
			IF EXISTS (
					SELECT TaskType
						,GeneralizedID
					FROM ProgramTaskBundle
					WHERE ProgramID = @i_ProgramID
						AND StatusCode = 'A'
					GROUP BY TaskType
						,GeneralizedID
					HAVING COUNT(*) > 1
					)
			BEGIN
				SELECT @o_ConflictReturn = 1
			END

			IF @o_ConflictReturn = 0
			BEGIN
				SELECT DISTINCT PatientUserID
				INTO #patList
				FROM ProgramTaskBundle
				INNER JOIN ProgramPatientTaskConflict ON ProgramPatientTaskConflict.ProgramTaskBundleId = ProgramTaskBundle.ProgramTaskBundleID
				WHERE ProgramTaskBundle.ProgramID = @i_ProgramID
					AND ProgramTaskBundle.StatusCode = 'A'
					AND ProgramPatientTaskConflict.StatusCode = 'A'

				--- Getting the Program related tasks
				PRINT GETDATE()

				SELECT DISTINCT ProgramID
					,TaskType
					,GeneralizedID
				INTO #patTasks
				FROM ProgramTaskBundle
				WHERE ProgramID = @i_ProgramID
					AND ProgramTaskBundle.StatusCode = 'A'

				CREATE NONCLUSTERED INDEX [IX_Pat] ON [dbo].[#patList] ([PatientUserID])

				PRINT GETDATE()

				SELECT pptc.PatientUserID
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
				INNER JOIN #patList P ON p.PatientUserid = pptc.patientuserid
				INNER JOIN #patTasks t ON t.TaskType = ptb.TaskType
					AND t.GeneralizedID = ptb.GeneralizedID
				INNER JOIN Program ON Program.ProgramId = ptb.ProgramID
				WHERE ptb.StatusCode = 'A'
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

				IF (
						SELECT COUNT(*)
						FROM #ConflictPatients
						) > 0
				BEGIN
					SELECT @o_ConflictReturn = 1
				END
			END
		END
		ELSE
		BEGIN
			IF EXISTS (
					SELECT TaskType
						,GeneralizedID
					FROM ProgramTaskBundle
					WHERE ProgramID = @i_ProgramID
						AND StatusCode = 'A'
					GROUP BY TaskType
						,GeneralizedID
					HAVING COUNT(*) > 1
					)
			BEGIN
				SELECT @o_ConflictReturn = 1
			END
		END
	END TRY

	--------------------------------------------------------     
	BEGIN CATCH
		-- Handle exception    
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Assignment_TaskbundleConflict] TO [FE_rohit.r-ext]
    AS [dbo];

