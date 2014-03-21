
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_AssignmentProgramTaskBundle_Insert        
Description   : This procedure is used to insert record into ProgramTaskBundle table
Created By    : Rathnam
Created Date  : 01-Oct-2012       
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION
18-Mar-2013 P.V.P.Mohan changed Table name for userProgram to PatientProgram
			and Modified PatientID in place of UserID.
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_AssignmentProgramTaskBundle_Insert] (
	@i_AppUserId KEYID
	,@t_TaskBundleCopyInclude TASKBUNDLEDEPENDENCIES READONLY
	,@i_ProgramID KEYID
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

		---------insert operation into ProgramTaskBundle table-----       
		DECLARE @l_TranStarted BIT = 0

		IF (@@TRANCOUNT = 0)
		BEGIN
			BEGIN TRANSACTION

			SET @l_TranStarted = 1 -- Indicator for start of transactions
		END
		ELSE
		BEGIN
			SET @l_TranStarted = 0
		END

		UPDATE ProgramTaskBundle
		SET StatusCode = 'A'
			,FrequencyNumber = t.FrequencyNumber
			,Frequency = t.Frequency
		FROM @t_TaskBundleCopyInclude t
		WHERE ProgramTaskBundle.TaskBundleID = t.TaskBundleId
			AND ProgramTaskBundle.TaskType = t.TaskType
			AND ProgramTaskBundle.GeneralizedID = t.TaskTypeGeneralizedID
			AND ProgramTaskBundle.IsInclude = t.CopyInclude
			AND ProgramTaskBundle.ProgramID = @i_ProgramID

		UPDATE ProgramTaskBundle
		SET StatusCode = 'I'
		WHERE NOT EXISTS (
				SELECT 1
				FROM @t_TaskBundleCopyInclude t
				WHERE ProgramTaskBundle.TaskBundleID = t.TaskBundleId
					AND ProgramTaskBundle.TaskType = t.TaskType
					AND ProgramTaskBundle.GeneralizedID = t.TaskTypeGeneralizedID
					AND ProgramTaskBundle.IsInclude = t.CopyInclude
				)
			AND ProgramTaskBundle.ProgramID = @i_ProgramID

		INSERT INTO ProgramTaskBundle (
			ProgramID
			,TaskBundleID
			,TaskType
			,GeneralizedID
			,CreatedByUserId
			,IsInclude
			,FrequencyNumber
			,Frequency
			)
		SELECT @i_ProgramID
			,TaskBundleId
			,TaskType
			,TaskTypeGeneralizedID
			,@i_AppUserId
			,CONVERT(BIT, CopyInclude)
			,FrequencyNumber
			,Frequency
		FROM @t_TaskBundleCopyInclude t
		WHERE NOT EXISTS (
				SELECT 1
				FROM ProgramTaskBundle ptb
				WHERE ptb.ProgramID = @i_ProgramID
					AND ptb.TaskBundleID = t.TaskBundleId
					AND ptb.TaskType = t.TaskType
					AND ptb.GeneralizedID = t.TaskTypeGeneralizedID
					AND ptb.IsInclude = t.CopyInclude
				)

		INSERT INTO ProgramPatientTaskConflict (
			ProgramTaskBundleId
			,PatientUserID
			,CreatedByUserId
			)
		SELECT DISTINCT ProgramTaskBundle.ProgramTaskBundleID
			,PatientProgram.PatientID UserId
			,@i_AppUserId
		FROM PatientProgram
		INNER JOIN ProgramTaskBundle ON ProgramTaskBundle.ProgramID = PatientProgram.ProgramId
		WHERE PatientProgram.ProgramID = @i_ProgramID
			AND PatientProgram.StatusCode = 'A'
			AND ProgramTaskBundle.StatusCode = 'A'
			AND PatientProgram.PatientID IS NOT NULL
			AND PatientProgram.EnrollmentEndDate IS NULL
			AND NOT EXISTS (
				SELECT 1
				FROM ProgramPatientTaskConflict pptc
				WHERE pptc.ProgramTaskBundleId = ProgramTaskBundle.ProgramTaskBundleID
					AND pptc.PatientUserID = PatientProgram.PatientID
				)

		UPDATE ProgramPatientTaskConflict
		SET StatusCode = 'I'
		FROM ProgramTaskBundle
		WHERE ProgramTaskBundle.ProgramTaskBundleID = ProgramPatientTaskConflict.ProgramTaskBundleId
			AND ProgramID = @i_ProgramID
			AND ProgramTaskBundle.StatusCode = 'I'

		
		IF (@l_TranStarted = 1) -- If transactions are there, then commit
		BEGIN
			SET @l_TranStarted = 0

			COMMIT TRANSACTION
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
    ON OBJECT::[dbo].[usp_AssignmentProgramTaskBundle_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

