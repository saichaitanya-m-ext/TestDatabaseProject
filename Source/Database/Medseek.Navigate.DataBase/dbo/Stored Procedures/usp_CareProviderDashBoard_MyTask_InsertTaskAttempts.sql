
/*              
------------------------------------------------------------------------------              
Procedure Name: usp_CareProviderDashBoard_MyTask_InsertTaskAttempts  
Description   : This porcedure is used for inserting the Phonecallattempts,AttemptStatus into Taskattempt   
                Table based upon callpage tasks by pateintId.         
Created By    : Rathnam  
Created Date  : 24-Feb-2012
------------------------------------------------------------------------------              
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION 
18-Mar-2013 P.V.P.Mohan changed Table name for userProgram to PatientProgram,UserQuestionaire to PatientQuestionaire
			UserEncounters to PatientEncounters,UserImmunizations to PatientImmunizations,
			UserDrugCodes to PatientDrugCodes and Modified PatientID in place of UserID.
------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyTask_InsertTaskAttempts] (
	@i_AppUserId KEYID
	,@t_TaskAttempts TASKATTEMPTS READONLY
	,@t_TaskCompletedComments TASKCOMPLETEDCOMMENTS READONLY
	)
AS
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

	INSERT INTO TaskAttempts (
		TaskId
		,TasktypeCommunicationID
		,AttemptedContactDate
		,Comments
		,UserId
		,NextContactDate
		,TaskTerminationDate
		,AttemptStatus
		,CommunicationTemplateID
		,CommunicationSequence
		,CommunicationTypeId
		)
	SELECT tblAttempts.TaskId
		,tblAttempts.TasktypeCommunicationID
		,tblAttempts.AttemptedContactDate
		,tblAttempts.Comments
		,@i_AppUserId
		,tblAttempts.NextContactDate
		,tblAttempts.TaskTerminationDate
		,tblAttempts.AttemptStatus
		,tblAttempts.CommunicationTemplateID
		,tblAttempts.CommunicationSequence
		,tblAttempts.CommunicationTypeId
	FROM @t_TaskAttempts tblAttempts
	WHERE tblAttempts.TasktypeCommunicationID IS NOT NULL

	IF EXISTS (
			SELECT 1
			FROM @t_TaskCompletedComments
			)
	BEGIN
		UPDATE PatientGoal
		SET GoalCompletedDate = t.CompletedDate
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		FROM @t_TaskCompletedComments t
		WHERE t.TaskTypeName = 'Life Style Goal\Activity Follow Up'
			AND PatientGoal.PatientGoalId = t.GeneralizedId

		UPDATE PatientQuestionaire
		SET DateTaken = t.CompletedDate
			,Comments = t.Comments
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		FROM @t_TaskCompletedComments t
		WHERE t.TaskTypeName = 'Questionnaire'
			AND PatientQuestionaire.PatientQuestionaireId = t.GeneralizedId

		/*
			UPDATE PatientEncounters
			SET EncounterDate = t.CompletedDate
				,Comments = t.Comments
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			FROM @t_TaskCompletedComments t
			WHERE t.TaskTypeName = 'Schedule Encounter\Appointment'
				AND PatientEncounters.PatientEncounterID = t.GeneralizedId
			*/
		UPDATE PatientProcedureGroupTask
		SET ProcedureGroupCompletedDate = t.CompletedDate
			,Commments = t.Comments
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		FROM @t_TaskCompletedComments t
		WHERE t.TaskTypeName = 'Schedule Procedure'
			AND PatientProcedureGroupTask.PatientProcedureGroupTaskID = t.GeneralizedId

		/*
			UPDATE PatientImmunizations
			SET ImmunizationDate = t.CompletedDate
				,Comments = t.Comments
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			FROM @t_TaskCompletedComments t
			WHERE t.TaskTypeName = 'Immunization'
				AND PatientImmunizations.PatientImmunizationID = t.GeneralizedId
			
			UPDATE PatientQuestionaire
			SET DateTaken = t.CompletedDate
				,Comments = t.Comments
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			FROM @t_TaskCompletedComments t
			WHERE t.TaskTypeName = 'Medication Titration'
				AND PatientQuestionaire.PatientQuestionaireId = t.GeneralizedId
			*/
		UPDATE PatientDrugCodes
		SET DateFilled = t.CompletedDate
			,Comments = t.Comments
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		FROM @t_TaskCompletedComments t
		WHERE t.TaskTypeName = 'Medication Prescription'
			AND PatientDrugCodes.PatientDrugId = t.GeneralizedId

		UPDATE PatientCommunication
		SET DateSent = t.CompletedDate
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		FROM @t_TaskCompletedComments t
		WHERE t.TaskTypeName = 'Communications'
			AND PatientCommunication.PatientCommunicationId = t.GeneralizedId

		/*
			UPDATE PatientHealthStatusScore
			SET DateDetermined = t.CompletedDate
				,Comments = t.Comments
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			FROM @t_TaskCompletedComments t
			WHERE t.TaskTypeName = 'Schedule Health Risk Score'
				AND PatientHealthStatusScore.PatientHealthStatusId = t.GeneralizedId

			
			UPDATE PatientPhoneCallLog
			SET CallDate = t.CompletedDate
				,Comments = t.Comments
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			FROM @t_TaskCompletedComments t
			WHERE t.TaskTypeName = 'Schedule Phone Call'
				AND PatientPhoneCallLog.PatientPhoneCallId = t.GeneralizedId
			*/
		UPDATE PatientEducationMaterial
		SET DateSent = t.CompletedDate
			,Comments = t.Comments
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		FROM @t_TaskCompletedComments t
		WHERE t.TaskTypeName = 'Patient Education Material'
			AND PatientEducationMaterial.PatientEducationMaterialID = t.GeneralizedId

		UPDATE PatientOtherTask
		SET DateTaken = t.CompletedDate
			,Comments = t.Comments
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		FROM @t_TaskCompletedComments t
		WHERE t.TaskTypeName = 'Other Tasks'
			AND PatientOtherTask.PatientOtherTaskId = t.GeneralizedId

		UPDATE Task
		SET TaskStatusId = 3
			,TaskCompletedDate = t.CompletedDate
			,Comments = t.Comments
		FROM @t_TaskCompletedComments t
		WHERE t.TaskTypeName = 'Ad-hoc Task'
			AND Task.TaskId = t.TaskID
	END
END TRY

--------------------------------------------------------               
BEGIN CATCH
	-- Handle exception              
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyTask_InsertTaskAttempts] TO [FE_rohit.r-ext]
    AS [dbo];

