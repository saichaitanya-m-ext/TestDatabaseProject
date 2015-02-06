
/*          
--------------------------------------------------------------------------------------------------------------          
Procedure Name: [dbo].[usp_AdhocTask_Delete]  
Description   : This proc is used to Change the status of the deleted tasks  
Created By    : Rathnam       
Created Date  : 06-Nov-2012    
---------------------------------------------------------------------------------------------------------------          
Log History   :           
DD-Mon-YYYY  BY  DESCRIPTION   
19-mar-2013 P.V.P.Mohan Modified all the users task table to Pateint and modified userId to PatientID  
06-jun-2013 P.V.P.Mohan Modified  the PatientProcedure table to PatientProcedureGroup and modified Columns 
----------------------------------------------------------------------------------------------------------------          
 */
CREATE PROCEDURE [dbo].[usp_AdhocTask_Delete] (
	@i_AppUserId KEYID
	,@t_PatientIdList TTYPEKEYID READONLY
	,@v_TaskTypeName VARCHAR(250)
	,@d_DueDate DATETIME
	,@i_TaskGeneralizedID KEYID = NULL
	,@vc_ManualTaskName SHORTDESCRIPTION = NULL
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

	IF @v_TaskTypeName IN ('Life Style Goal\Activity Follow Up')
	BEGIN
		UPDATE PatientGoal
		SET StatusCode = 'I'
			,LastModifiedDate = GETDATE()
			,LastModifiedByUserId = @i_AppUserId
		FROM @t_PatientIdList p
		WHERE PatientGoal.PatientId = p.tKeyId
			AND PatientGoal.LifeStyleGoalId = @i_TaskGeneralizedID
			AND PatientGoal.IsAdhoc = 1
			AND PatientGoal.GoalCompletedDate IS NULL
			AND CONVERT(DATE, PatientGoal.StartDate) = CONVERT(DATE, @d_DueDate)
	END
	ELSE
	BEGIN
		IF @v_TaskTypeName IN (
				'Questionnaire'
				,'Medication Titration'
				)
		BEGIN
			UPDATE PatientQuestionaire
			SET StatusCode = 'I'
				,LastModifiedDate = GETDATE()
				,LastModifiedByUserId = @i_AppUserId
			FROM @t_PatientIdList p
			WHERE PatientQuestionaire.PatientId = p.tKeyId
				AND PatientQuestionaire.QuestionaireId = @i_TaskGeneralizedID
				AND PatientQuestionaire.IsAdhoc = 1
				AND PatientQuestionaire.DateTaken IS NULL
				AND CONVERT(DATE, PatientQuestionaire.DateDue) = CONVERT(DATE, @d_DueDate)
		END
		ELSE
		BEGIN
			IF @v_TaskTypeName = 'Schedule Procedure'
			BEGIN
				UPDATE PatientProcedureGroupTask
				SET StatusCode = 'I'
					,LastModifiedDate = GETDATE()
					,LastModifiedByUserId = @i_AppUserId
				FROM @t_PatientIdList p
				WHERE PatientProcedureGroupTask.PatientId = p.tKeyId
					AND PatientProcedureGroupTask.CodeGroupingID = @i_TaskGeneralizedID
					AND PatientProcedureGroupTask.IsAdhoc = 1
					AND PatientProcedureGroupTask.ProcedureGroupCompletedDate IS NULL
					AND CONVERT(DATE, PatientProcedureGroupTask.DueDate) = CONVERT(DATE, @d_DueDate)
			END
			ELSE
			BEGIN
				IF @v_TaskTypeName = 'Medication Prescription'
				BEGIN
					UPDATE PatientDrugCodes
					SET StatusCode = 'I'
						,LastModifiedDate = GETDATE()
						,LastModifiedByUserId = @i_AppUserId
					FROM @t_PatientIdList p
					WHERE PatientDrugCodes.PatientId = p.tKeyId
						AND PatientDrugCodes.DrugCodeId = @i_TaskGeneralizedID
						AND PatientDrugCodes.IsAdhoc = 1
						AND PatientDrugCodes.DateFilled IS NULL
						AND CONVERT(DATE, PatientDrugCodes.DatePrescribed) = CONVERT(DATE, @d_DueDate)
				END
				ELSE
				BEGIN
					IF @v_TaskTypeName = 'Ad-hoc Task'
					BEGIN
						UPDATE Task
						SET TaskStatusId = 4
							,--> Closed Incomplete for Manual Tasks  
							LastModifiedByUserId = @i_AppUserId
							,LastModifiedDate = GETDATE()
						FROM @t_PatientIdList p
						WHERE Task.PatientId = P.tKeyId
							AND Task.ManualTaskName = @vc_ManualTaskName
					END
				END
			END
		END
	END
END TRY

BEGIN CATCH
	----------------------------------------------------------------------------------------------------------         
	-- Handle exception          
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_AdhocTask_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

