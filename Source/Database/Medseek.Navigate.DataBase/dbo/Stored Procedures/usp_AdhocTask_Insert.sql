/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_AdhocTask_Insert]  
Description   : This procedure is used to Insert AdhocTask Records
Created By    : Rathnam
Created Date  : 05-Nov-2012   
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
18-Mar-2013 P.V.P.Mohan changed Table names for userProgram,UserDrugCodesUserHealthStatusScore,UserProcedureCodes,
			UserEncounters,UserQuestionaire and Modified PatientID in place of UserID
18-Mar-2013 P.V.P.Mohan Modified PatientuserId to PatientID in Task table 
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_AdhocTask_Insert] (
	@i_AppUserId KEYID
	,@v_TaskTypeName VARCHAR(250)
	,@t_PatientIdList TTYPEKEYID READONLY
	,@i_TaskGeneralizedId KEYID
	,@dt_TaskDueDate USERDATE = NULL
	,@i_AssignedCareProviderId KEYID = NULL
	,@vc_Comments SHORTDESCRIPTION = NULL
	,@dt_TaskCompletedDate USERDATE = NULL
	,@vc_ManualTaskName SHORTDESCRIPTION = NULL
	,@vc_IsSchduledType VARCHAR(1) = NULL
	,@b_IsAdhoc BIT = NULL
	,@vc_DurationUnits VARCHAR(5) = NULL --> PatientGoald realted Parameters
	,@i_DurationTimeline INT = NULL
	,@V_GoalStatus VARCHAR(5) = NULL
	,@t_AdhocTaskSchduledAttempts TBLTASKREMAINDERS READONLY
	,@i_ManagedPopulationID KEYID = NULL
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

	DECLARE @i_TaskStatusID INT
		,@i_RowCnt INT

	SELECT @i_TaskStatusID = TaskStatusID
	FROM TaskStatus
	WHERE TaskStatusText = 'Closed Complete'

	DECLARE @i_TaskID KEYID
	DECLARE @tblTasks TABLE (
		TaskID INT
		,TypeID INT
		,TaskTypeID INT
		)

	IF @i_TaskGeneralizedId IS NOT NULL
	BEGIN
		--IF @v_TaskTypeName = 'Managed Population Enrollment'
		--BEGIN
		--	INSERT INTO PatientProgram (
		--		PatientID
		--		,ProgramId
		--		,DueDate
		--		,EnrollmentStartDate
		--		,StatusCode
		--		,CreatedByUserId
		--		,IsAdhoc
		--		,IsAutoEnrollment
		--		,IdentificationDate
		--		)
		--	SELECT p.tKeyId
		--		,@i_TaskGeneralizedId
		--		,GETDATE()
		--		,GETDATE()
		--		,'A'
		--		,@i_AppUserId
		--		,@b_IsAdhoc
		--		,0
		--		,GETDATE()
		--	FROM @t_PatientIdList p
		--	WHERE NOT EXISTS (
		--			SELECT 1
		--			FROM PatientProgram ups
		--			WHERE ups.PatientID = p.tKeyId
		--				AND ups.ProgramId = @i_TaskGeneralizedId
		--			)

		--	INSERT INTO ProgramPatientTaskConflict (
		--		ProgramTaskBundleId
		--		,PatientUserID
		--		,CreatedByUserId
		--		)
		--	SELECT DISTINCT ProgramTaskBundle.ProgramTaskBundleID
		--		,PatientProgram.PatientID UserId
		--		,@i_AppUserId
		--	FROM PatientProgram
		--	INNER JOIN @t_PatientIdList p
		--		ON PatientProgram.PatientID = P.tKeyId
		--	INNER JOIN ProgramTaskBundle
		--		ON ProgramTaskBundle.ProgramID = PatientProgram.ProgramId
		--	WHERE ProgramTaskBundle.ProgramId = @i_TaskGeneralizedId
		--		AND PatientProgram.StatusCode = 'A'
		--		AND ProgramTaskBundle.StatusCode = 'A'
		--		AND PatientProgram.PatientID IS NOT NULL
		--		AND ProgramTaskBundle.ProgramTaskBundleID IS NOT NULL
		--		AND NOT EXISTS (
		--			SELECT 1
		--			FROM ProgramPatientTaskConflict pptc
		--			WHERE pptc.ProgramTaskBundleId = ProgramTaskBundle.ProgramTaskBundleID
		--				AND pptc.PatientUserID = PatientProgram.PatientID
		--			)
		--END

		IF @v_TaskTypeName IN ('Life Style Goal\Activity Follow Up')
		BEGIN
			INSERT INTO PatientGoal (
				PatientId
				,
				--Description,  
				DurationUnits
				,DurationTimeline
				,
				--ContactFrequencyUnits,  
				--ContactFrequency,  
				--CommunicationTypeId,  
				--CancellationReason,  
				Comments
				,LifeStyleGoalId
				--,GoalCompletedDate
				,GoalStatus
				,StatusCode
				,StartDate
				,CreatedByUserId
				,IsAdhoc
				,AssignedCareProviderId
				,ProgramId
				,PatientProgramId
				)
			SELECT DISTINCT p.tKeyId
				,
				--@vc_Description,  
				@vc_DurationUnits
				,@i_DurationTimeline
				,
				--@vc_ContactFrequencyUnits,  
				--@i_ContactFrequency,  
				--@i_CommunicationTypeId,  
				--@i_CancellationReason, 
				@vc_Comments
				,@i_TaskGeneralizedId
				--,@dt_TaskCompletedDate
				,@V_GoalStatus
				,'A'
				,@dt_TaskDueDate
				,@i_AppUserId
				,@b_IsAdhoc
				,@i_AssignedCareProviderId
				,@i_ManagedPopulationID
				,(SELECT MAX(PatientProgramId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
				  FROM PatientProgram pp
				  WHERE PP.PatientID = P.tKeyId
				  AND PP.ProgramID = @i_ManagedPopulationID	)PatientProgramId
			FROM @t_PatientIdList p
			WHERE NOT EXISTS (
					SELECT 1
					FROM PatientGoal pg
					WHERE pg.LifeStyleGoalId = @i_TaskGeneralizedId
						AND pg.PatientId = p.tKeyId
						AND pg.StartDate = @dt_TaskDueDate
						AND IsAdhoc = 1
					)

			SET @i_RowCnt = @@ROWCOUNT
		END

		IF @v_TaskTypeName IN (
				'Questionnaire'
				,'Medication Titration'
				) -- Questionnaire and Medication titration
		BEGIN
			IF @vc_IsSchduledType = 'S'
			BEGIN
				INSERT INTO PatientQuestionaire (
					PatientId
					,QuestionaireId
					,DateDue
					,DateAssigned
					,Comments
					,CreatedByUserId
					,IsAdhoc
					,AssignedCareProviderId
					,ProgramID
					,PatientProgramID
					)
				SELECT p.tKeyId
					,@i_TaskGeneralizedId
					,@dt_TaskDueDate
					,GETDATE()
					,@vc_Comments
					,@i_AppUserId
					,@b_IsAdhoc
					,@i_AssignedCareProviderId
					,@i_ManagedPopulationID
					,(SELECT MAX(PatientProgramId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
					  FROM PatientProgram pp
					  WHERE PP.PatientID = P.tKeyId
					  AND PP.ProgramID = @i_ManagedPopulationID	)PatientProgramId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientQuestionaire uqe
						WHERE uqe.PatientId = p.tKeyId
							AND uqe.QuestionaireId = @i_TaskGeneralizedId
							AND CONVERT(DATE, DateDue) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				SET @i_RowCnt = @@ROWCOUNT
			END
			ELSE
			BEGIN
				INSERT INTO PatientQuestionaire (
					PatientId
					,QuestionaireId
					,DateDue
					,DateTaken
					,DateAssigned
					,Comments
					,CreatedByUserId
					,IsAdhoc
					,AssignedCareProviderId
					,ProgramID
					,PatientProgramID
					)
				SELECT p.tKeyId
					,@i_TaskGeneralizedId
					,@dt_TaskCompletedDate
					,@dt_TaskCompletedDate
					,GETDATE()
					,@vc_Comments
					,@i_AppUserId
					,@b_IsAdhoc
					,@i_AssignedCareProviderId
					,@i_ManagedPopulationID
					,(SELECT MAX(PatientProgramId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
					  FROM PatientProgram pp
					  WHERE PP.PatientID = P.tKeyId
					  AND PP.ProgramID = @i_ManagedPopulationID	)PatientProgramId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientQuestionaire uqe
						WHERE uqe.PatientId = p.tKeyId
							AND uqe.QuestionaireId = @i_TaskGeneralizedId
							AND CONVERT(DATE, DateDue) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				INSERT INTO Task (
					PatientId
					,TaskTypeId
					,TaskDueDate
					,AssignedCareProviderId
					,Comments
					,TaskCompletedDate
					,TaskStatusId
					,IsAdhoc
					,CreatedByUserId
					,ProgramID
					,TypeID
					,PatientADTId
					)
				SELECT p.tKeyId
					,(
						SELECT TaskTypeId
						FROM TaskType
						WHERE TaskTypeName = @v_TaskTypeName
						)
					,@dt_TaskCompletedDate
					,@i_AssignedCareProviderId
					,@vc_Comments
					,@dt_TaskCompletedDate
					,@i_TaskStatusID
					,@b_IsAdhoc
					,@i_AppUserId
					,@i_ManagedPopulationID
					,@i_TaskGeneralizedId
					,(SELECT MAX(pp.PatientADTId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
					  FROM PatientProgram pp
					  WHERE PP.PatientID = P.tKeyId
					  AND PP.ProgramID = @i_ManagedPopulationID	)PatientADTId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM Task t
						WHERE t.PatientId = p.tKeyId
							AND t.TypeID = @i_TaskGeneralizedId
							AND CONVERT(DATE, t.TaskDueDate) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
							AND T.ProgramID = @i_ManagedPopulationID
						)
			END
		END
		/*
		IF @v_TaskTypeName = 'Schedule Encounter\Appointment'
		BEGIN
			IF @vc_IsSchduledType = 'S'
			BEGIN
				INSERT INTO PatientEncounters (
					PatientID
					,Comments
					,EncounterTypeId
					,StatusCode
					,CreatedByUserId
					,DateDue
					,IsAdhoc
					,CareTeamUserID
					,ProgramID
					)
				SELECT p.tKeyId
					,@vc_Comments
					,@i_TaskGeneralizedId
					,'A'
					,@i_AppUserId
					,@dt_TaskDueDate
					,@b_IsAdhoc
					,@i_AssignedCareProviderId
					,@i_ManagedPopulationID
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientEncounters ues
						WHERE ues.PatientID = p.tKeyId
							AND ues.EncounterTypeId = @i_TaskGeneralizedId
							AND CONVERT(DATE, DateDue) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				SET @i_RowCnt = @@ROWCOUNT
			END
			ELSE
			BEGIN
				INSERT INTO PatientEncounters (
					PatientID
					,Comments
					,EncounterTypeId
					,StatusCode
					,CreatedByUserId
					,DateDue
					,EncounterDate
					,IsAdhoc
					,CareTeamUserID
					,ProgramID
					)
				SELECT p.tKeyId
					,@vc_Comments
					,@i_TaskGeneralizedId
					,'A'
					,@i_AppUserId
					,@dt_TaskCompletedDate
					,@dt_TaskCompletedDate
					,@b_IsAdhoc
					,@i_AssignedCareProviderId
					,@i_ManagedPopulationID
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientEncounters ues
						WHERE ues.PatientID = p.tKeyId
							AND ues.EncounterTypeId = @i_TaskGeneralizedId
							AND CONVERT(DATE, DateDue) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				INSERT INTO Task (
					PatientId
					,TaskTypeId
					,TaskDueDate
					,AssignedCareProviderId
					,Comments
					,TaskCompletedDate
					,TaskStatusId
					,IsAdhoc
					,CreatedByUserId
					,ProgramID
					,TypeID
					)
				SELECT p.tKeyId
					,(
						SELECT TaskTypeId
						FROM TaskType
						WHERE TaskTypeName = @v_TaskTypeName
						)
					,@dt_TaskCompletedDate
					,@i_AssignedCareProviderId
					,@vc_Comments
					,@dt_TaskCompletedDate
					,@i_TaskStatusID
					,@b_IsAdhoc
					,@i_AppUserId
					,@i_ManagedPopulationID
					,@i_TaskGeneralizedId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM Task t
						WHERE t.PatientId = p.tKeyId
							AND t.TypeID = @i_TaskGeneralizedId
							AND CONVERT(DATE, t.TaskDueDate) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)
			END
		END
`		*/
		IF @v_TaskTypeName = 'Schedule Procedure'
		BEGIN
			IF @vc_IsSchduledType = 'S'
			BEGIN
				INSERT INTO PatientProcedureGroupTask (
					PatientID
					,CodeGroupingID
					,Commments
					,StatusCode
					,DueDate
					,CreatedByUserId
					,IsAdhoc
					,AssignedCareProviderId
					,ManagedPopulationID
					,PatientProgramID
					)
				SELECT p.tKeyId
					,@i_TaskGeneralizedId
					,@vc_Comments
					,'A'
					,@dt_TaskDueDate
					,@i_AppUserId
					,@b_IsAdhoc
					,@i_AssignedCareProviderId
					,@i_ManagedPopulationID
					,(SELECT MAX(PatientProgramId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
					  FROM PatientProgram pp
					  WHERE PP.PatientID = P.tKeyId
					  AND PP.ProgramID = @i_ManagedPopulationID	)PatientProgramId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientProcedureGroupTask ups
						WHERE ups.PatientID = p.tKeyId
							AND ups.CodeGroupingID = @i_TaskGeneralizedId
							AND CONVERT(DATE, DueDate) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				SET @i_RowCnt = @@ROWCOUNT
			END
			ELSE
			BEGIN
				INSERT INTO PatientProcedureGroupTask (
					PatientID
					,CodeGroupingID
					,Commments
					,StatusCode
					,DueDate
					,ProcedureGroupCompletedDate
					,CreatedByUserId
					,IsAdhoc
					,AssignedCareProviderId
					,ManagedPopulationID
					,PatientProgramID
					)
				SELECT p.tKeyId
					,@i_TaskGeneralizedId
					,@vc_Comments
					,'A'
					,@dt_TaskCompletedDate
					,@dt_TaskCompletedDate
					,@i_AppUserId
					,@b_IsAdhoc
					,@i_AssignedCareProviderId
					,@i_ManagedPopulationID
					,(SELECT MAX(PatientProgramId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
					  FROM PatientProgram pp
					  WHERE PP.PatientID = P.tKeyId
					  AND PP.ProgramID = @i_ManagedPopulationID	)PatientProgramId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientProcedureGroupTask ups
						WHERE ups.PatientID = p.tKeyId
							AND ups.CodeGroupingID = @i_TaskGeneralizedId
							AND CONVERT(DATE, DueDate) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				INSERT INTO Task (
					PatientId
					,TaskTypeId
					,TaskDueDate
					,AssignedCareProviderId
					,Comments
					,TaskCompletedDate
					,TaskStatusId
					,IsAdhoc
					,CreatedByUserId
					,ProgramID
					,TypeID
					,PatientADTId
					)
				SELECT p.tKeyId
					,(
						SELECT TaskTypeId
						FROM TaskType
						WHERE TaskTypeName = @v_TaskTypeName
						)
					,@dt_TaskCompletedDate
					,@i_AssignedCareProviderId
					,@vc_Comments
					,@dt_TaskCompletedDate
					,@i_TaskStatusID
					,@b_IsAdhoc
					,@i_AppUserId
					,@i_ManagedPopulationID
					,@i_TaskGeneralizedId
					,(SELECT MAX(PatientADTId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
					  FROM PatientProgram pp
					  WHERE PP.PatientID = P.tKeyId
					  AND PP.ProgramID = @i_ManagedPopulationID	)PatientADTId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM Task t
						WHERE t.PatientId = p.tKeyId
							AND t.TypeID = @i_TaskGeneralizedId
							AND CONVERT(DATE, t.TaskDueDate) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
							AND T.ProgramID = @i_ManagedPopulationID
						)
			END
		END
		/*
		IF @v_TaskTypeName = 'Immunization'
		BEGIN
			IF @vc_IsSchduledType = 'S'
			BEGIN
				INSERT INTO PatientImmunizations (
					ImmunizationID
					,PatientID
					,Comments
					,CreatedByUserId
					,StatusCode
					,DueDate
					,IsAdhoc
					,AssignedCareProviderId
					,ProgramID
					)
				SELECT @i_TaskGeneralizedId
					,p.tKeyId
					,@vc_Comments
					,@i_AppUserId
					,'A'
					,@dt_TaskDueDate
					,@b_IsAdhoc
					,@i_AssignedCareProviderId
					,@i_ManagedPopulationID
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientImmunizations uis
						WHERE uis.PatientID = p.tKeyId
							AND uis.ImmunizationID = @i_TaskGeneralizedId
							AND CONVERT(DATE, DueDate) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				SET @i_RowCnt = @@ROWCOUNT
			END
			ELSE
			BEGIN
				INSERT INTO PatientImmunizations (
					ImmunizationID
					,PatientID
					,Comments
					,CreatedByUserId
					,StatusCode
					,DueDate
					,IsAdhoc
					,AssignedCareProviderId
					,ImmunizationDate
					,ProgramID
					)
				SELECT @i_TaskGeneralizedId
					,p.tKeyId
					,@vc_Comments
					,@i_AppUserId
					,'A'
					,@dt_TaskCompletedDate
					,@b_IsAdhoc
					,@i_AssignedCareProviderId
					,@dt_TaskCompletedDate
					,@i_ManagedPopulationID
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientImmunizations uis
						WHERE uis.PatientID = p.tKeyId
							AND uis.ImmunizationID = @i_TaskGeneralizedId
							AND CONVERT(DATE, DueDate) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				INSERT INTO Task (
					PatientId
					,TaskTypeId
					,TaskDueDate
					,AssignedCareProviderId
					,Comments
					,TaskCompletedDate
					,TaskStatusId
					,IsAdhoc
					,CreatedByUserId
					,ProgramID
					,TypeID
					)
				SELECT p.tKeyId
					,(
						SELECT TaskTypeId
						FROM TaskType
						WHERE TaskTypeName = @v_TaskTypeName
						)
					,@dt_TaskCompletedDate
					,@i_AssignedCareProviderId
					,@vc_Comments
					,@dt_TaskCompletedDate
					,@i_TaskStatusID
					,@b_IsAdhoc
					,@i_AppUserId
					,@i_ManagedPopulationID
					,@i_TaskGeneralizedId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM Task t
						WHERE t.PatientId = p.tKeyId
							AND t.TypeID = @i_TaskGeneralizedId
							AND CONVERT(DATE, t.TaskDueDate) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)
			END
		END
		*/
		IF @v_TaskTypeName = 'Medication Prescription'
		BEGIN
			IF @vc_IsSchduledType = 'S'
			BEGIN
				INSERT INTO PatientDrugCodes (
					PatientID
					,DrugCodeId
					,StatusCode
					,Comments
					,CreatedByUserId
					,DatePrescribed
					,CareTeamUserID
					,IsAdhoc
					,ProgramID
					,PatientProgramID
					)
				SELECT p.tKeyId
					,@i_TaskGeneralizedId
					,'A'
					,@vc_Comments
					,@i_AppUserId
					,@dt_TaskDueDate
					,@i_AssignedCareProviderId
					,@b_IsAdhoc
					,@i_ManagedPopulationID
					,(SELECT MAX(PatientProgramId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
					  FROM PatientProgram pp
					  WHERE PP.PatientID = P.tKeyId
					  AND PP.ProgramID = @i_ManagedPopulationID	)PatientProgramId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientDrugCodes uds
						WHERE uds.PatientID = p.tKeyId
							AND uds.DrugCodeId = @i_TaskGeneralizedId
							AND CONVERT(DATE, DatePrescribed) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				SET @i_RowCnt = @@ROWCOUNT
			END
			ELSE
			BEGIN
				INSERT INTO PatientDrugCodes (
					PatientID
					,DrugCodeId
					,StatusCode
					,Comments
					,CreatedByUserId
					,DatePrescribed
					,CareTeamUserID
					,IsAdhoc
					,DateFilled
					,ProgramID
					,PatientProgramID
					)
				SELECT p.tKeyId
					,@i_TaskGeneralizedId
					,'A'
					,@vc_Comments
					,@i_AppUserId
					,@dt_TaskCompletedDate
					,@i_AssignedCareProviderId
					,@b_IsAdhoc
					,@dt_TaskCompletedDate
					,@i_ManagedPopulationID
					,(SELECT MAX(PatientProgramId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
					  FROM PatientProgram pp
					  WHERE PP.PatientID = P.tKeyId
					  AND PP.ProgramID = @i_ManagedPopulationID	)PatientProgramId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientDrugCodes uds
						WHERE uds.PatientID = p.tKeyId
							AND uds.DrugCodeId = @i_TaskGeneralizedId
							AND CONVERT(DATE, DatePrescribed) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				INSERT INTO Task (
					PatientId
					,TaskTypeId
					,TaskDueDate
					,AssignedCareProviderId
					,Comments
					,TaskCompletedDate
					,TaskStatusId
					,IsAdhoc
					,CreatedByUserId
					,ProgramID
					,TypeID
					,PatientADTId
					)
				SELECT p.tKeyId
					,(
						SELECT TaskTypeId
						FROM TaskType
						WHERE TaskTypeName = @v_TaskTypeName
						)
					,@dt_TaskCompletedDate
					,@i_AssignedCareProviderId
					,@vc_Comments
					,@dt_TaskCompletedDate
					,@i_TaskStatusID
					,@b_IsAdhoc
					,@i_AppUserId
					,@i_ManagedPopulationID
					,@i_TaskGeneralizedId
					,(SELECT MAX(PatientADTId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
					  FROM PatientProgram pp
					  WHERE PP.PatientID = P.tKeyId
					  AND PP.ProgramID = @i_ManagedPopulationID	)PatientADTId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM Task t
						WHERE t.PatientId = p.tKeyId
							AND t.TypeID = @i_TaskGeneralizedId
							AND CONVERT(DATE, t.TaskDueDate) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
							AND T.ProgramID = @i_ManagedPopulationID
						)
			END
		END
		/*
		IF @v_TaskTypeName = 'Schedule Health Risk Score'
		BEGIN
			IF @vc_IsSchduledType = 'S'
			BEGIN
				INSERT INTO PatientHealthStatusScore (
					PatientID
					,Comments
					,HealthStatusScoreId
					,DateDue
					,StatusCode
					,IsAdhoc
					,CreatedByUserId
					,AssignedCareProviderId
					,ProgramID
					)
				SELECT p.tKeyId
					,@vc_Comments
					,@I_TaskGeneralizedId
					,@dt_TaskDueDate
					,'A'
					,@b_IsAdhoc
					,@i_AppUserId
					,@i_AssignedCareProviderId
					,@i_ManagedPopulationID
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientHealthStatusScore uds
						WHERE uds.PatientID = p.tKeyId
							AND uds.HealthStatusScoreId = @i_TaskGeneralizedId
							AND CONVERT(DATE, DateDue) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				SET @i_RowCnt = @@ROWCOUNT
			END
			ELSE
			BEGIN
				INSERT INTO PatientHealthStatusScore (
					PatientID
					,Comments
					,HealthStatusScoreId
					,DateDue
					,StatusCode
					,IsAdhoc
					,CreatedByUserId
					,AssignedCareProviderId
					,DateDetermined
					,ProgramID
					)
				SELECT p.tKeyId
					,@vc_Comments
					,@I_TaskGeneralizedId
					,@dt_TaskCompletedDate
					,'A'
					,@b_IsAdhoc
					,@i_AppUserId
					,@i_AssignedCareProviderId
					,@dt_TaskCompletedDate
					,@i_ManagedPopulationID
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM PatientHealthStatusScore uds
						WHERE uds.PatientID = p.tKeyId
							AND uds.HealthStatusScoreId = @i_TaskGeneralizedId
							AND CONVERT(DATE, DateDue) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)

				INSERT INTO Task (
					PatientId
					,TaskTypeId
					,TaskDueDate
					,AssignedCareProviderId
					,Comments
					,TaskCompletedDate
					,TaskStatusId
					,IsAdhoc
					,CreatedByUserId
					,ProgramID
					,TypeID
					)
				SELECT p.tKeyId
					,(
						SELECT TaskTypeId
						FROM TaskType
						WHERE TaskTypeName = @v_TaskTypeName
						)
					,@dt_TaskCompletedDate
					,@i_AssignedCareProviderId
					,@vc_Comments
					,@dt_TaskCompletedDate
					,@i_TaskStatusID
					,@b_IsAdhoc
					,@i_AppUserId
					,@i_ManagedPopulationID
					,@i_TaskGeneralizedId
				FROM @t_PatientIdList p
				WHERE NOT EXISTS (
						SELECT 1
						FROM Task t
						WHERE t.PatientId = p.tKeyId
							AND t.TypeID = @i_TaskGeneralizedId
							AND CONVERT(DATE, t.TaskDueDate) = CONVERT(DATE, @dt_TaskDueDate)
							AND IsAdhoc = 1
						)
			END
		END
		*/
		INSERT INTO @tblTasks
		SELECT t.TaskId
			,t.TypeID
			,t.TaskTypeId
		FROM Task t
		INNER JOIN @t_PatientIdList p
			ON t.PatientId = p.tKeyId
		INNER JOIN TaskType te
			ON te.TaskTypeId = t.TaskTypeId
		WHERE t.TypeID = @i_TaskGeneralizedId
			AND t.Isadhoc = 1
			AND CONVERT(DATE, t.TaskDueDate) = CONVERT(DATE, @dt_TaskDueDate)
			AND t.TaskCompletedDate IS NULL
			AND te.TaskTypeName = @v_TaskTypeName

		IF @i_RowCnt > 0
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM @t_AdhocTaskSchduledAttempts
					)
			BEGIN
				INSERT INTO TaskRemainder (
					TaskId
					,CommunicationSequence
					,CommunicationTypeID
					,CommunicationAttemptDays
					,NoOfDaysBeforeTaskClosedIncomplete
					,CommunicationTemplateID
					,TaskTypeGeneralizedID
					,IsAdhoc
					,RemainderState
					)
				SELECT DISTINCT t.TaskID
					,tblc.CommunicationSequence
					,CASE 
						WHEN tblc.CommunicationTypeID = 0
							THEN NULL
						ELSE tblc.CommunicationTypeID
						END
					,CASE 
						WHEN tblc.CommunicationAttemptDays = 0
							THEN NULL
						ELSE tblc.CommunicationAttemptDays
						END
					,CASE 
						WHEN tblc.NoOfDaysBeforeTaskClosedIncomplete = 0
							THEN NULL
						ELSE tblc.NoOfDaysBeforeTaskClosedIncomplete
						END
					,CASE 
						WHEN tblc.TemplateNameID = 0
							THEN NULL
						ELSE tblc.TemplateNameID
						END
					,t.TypeID
					,1
					,tblc.RemainderState
				FROM @t_AdhocTaskSchduledAttempts tblc
				INNER JOIN @tblTasks t
					ON t.TypeID = tblc.TypeID
			END
			ELSE
			BEGIN
				INSERT INTO TaskRemainder (
					TaskId
					,CommunicationSequence
					,CommunicationTypeID
					,CommunicationAttemptDays
					,NoOfDaysBeforeTaskClosedIncomplete
					,CommunicationTemplateID
					,TaskTypeGeneralizedID
					,IsAdhoc
					,RemainderState
					)
				SELECT DISTINCT t.TaskID
					,tblc.CommunicationSequence
					,CASE 
						WHEN tblc.CommunicationTypeID = 0
							THEN NULL
						ELSE tblc.CommunicationTypeID
						END
					,CASE 
						WHEN tblc.CommunicationAttemptDays = 0
							THEN NULL
						ELSE tblc.CommunicationAttemptDays
						END
					,CASE 
						WHEN tblc.NoOfDaysBeforeTaskClosedIncomplete = 0
							THEN NULL
						ELSE tblc.NoOfDaysBeforeTaskClosedIncomplete
						END
					,CASE 
						WHEN tblc.CommunicationTemplateID = 0
							THEN NULL
						ELSE tblc.CommunicationTemplateID
						END
					,t.TypeID
					,1
					,tblc.RemainderState
				FROM TaskTypeCommunications tblc
				INNER JOIN @tblTasks t
					ON t.TaskTypeID = tblc.TaskTypeID
				WHERE tblc.TaskTypeGeneralizedID IS NULL
					AND tblc.StatusCode = 'A'
			END
		END
	END
	ELSE
	BEGIN
		-----Adhoc Manual task
		DECLARE @i_TaskTypeID INT

		SELECT @i_TaskTypeID = TaskTypeId
		FROM TaskType
		WHERE TaskTypeName = 'Ad-hoc Task'

		IF @vc_IsSchduledType = 'S'
		BEGIN
			INSERT INTO Task (
				PatientId
				,TaskTypeId
				,TaskDueDate
				,AssignedCareProviderId
				,Comments
				,TaskStatusId
				,ManualTaskName
				,IsAdhoc
				,CreatedByUserId
				,ProgramID
				,PatientADTId
				)
			SELECT p.tKeyId
				,@i_TaskTypeID
				,@dt_TaskDueDate
				,@i_AssignedCareProviderId
				,@vc_Comments
				,2
				,@vc_ManualTaskName
				,@b_IsAdhoc
				,@i_AppUserId
				,@i_ManagedPopulationID
				,(SELECT MAX(PatientADTId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
				  FROM PatientProgram pp
				  WHERE PP.PatientID = P.tKeyId
				  AND PP.ProgramID = @i_ManagedPopulationID	)PatientADTId
			FROM @t_PatientIdList p
			
			    	
			IF EXISTS (
					SELECT 1
					FROM @t_AdhocTaskSchduledAttempts
					)
			BEGIN
				INSERT INTO @tblTasks
				SELECT t.TaskId
					,isnull(t.TypeID, 0)
					,t.TaskTypeId
				FROM Task t
				INNER JOIN @t_PatientIdList p
					ON t.PatientId = p.tKeyId
				WHERE t.ManualTaskName = @vc_ManualTaskName
					AND t.Isadhoc = 1
					AND CONVERT(DATE, t.TaskDueDate) = CONVERT(DATE, @dt_TaskDueDate)
					AND t.TaskCompletedDate IS NULL

				INSERT INTO TaskRemainder (
					TaskId
					,CommunicationSequence
					,CommunicationTypeID
					,CommunicationAttemptDays
					,NoOfDaysBeforeTaskClosedIncomplete
					,CommunicationTemplateID
					,TaskTypeGeneralizedID
					,IsAdhoc
					,RemainderState
					)
				SELECT DISTINCT t.TaskID
					,tblc.CommunicationSequence
					,CASE 
						WHEN tblc.CommunicationTypeID = 0
							THEN NULL
						ELSE tblc.CommunicationTypeID
						END
					,CASE 
						WHEN tblc.CommunicationAttemptDays = 0
							THEN NULL
						ELSE tblc.CommunicationAttemptDays
						END
					,CASE 
						WHEN tblc.NoOfDaysBeforeTaskClosedIncomplete = 0
							THEN NULL
						ELSE tblc.NoOfDaysBeforeTaskClosedIncomplete
						END
					,CASE 
						WHEN tblc.TemplateNameID = 0
							THEN NULL
						ELSE tblc.TemplateNameID
						END
					,NULL
					,1
					,RemainderState
				FROM @t_AdhocTaskSchduledAttempts tblc
				INNER JOIN @tblTasks t
					ON t.TypeID = ISNULL(tblc.TypeID, 0)
			END
		END
		ELSE
		BEGIN
			INSERT INTO Task (
				PatientId
				,TaskTypeId
				,TaskDueDate
				,AssignedCareProviderId
				,Comments
				,TaskCompletedDate
				,TaskStatusId
				,ManualTaskName
				,IsAdhoc
				,CreatedByUserId
				,ProgramID
				,PatientADTId
				)
			SELECT p.tKeyId
				,@i_TaskTypeID
				,@dt_TaskCompletedDate
				,@i_AssignedCareProviderId
				,@vc_Comments
				,@dt_TaskCompletedDate
				,@i_TaskStatusID
				,@vc_ManualTaskName
				,@b_IsAdhoc
				,@i_AppUserId
				,@i_ManagedPopulationID
				,(SELECT MAX(PatientADTId)  /*It Will use to identify the AdhocTask for ADT ManagedPopulatioin as we can create Adhoc tasks for even the patient in ManagedPopulatioin or not */
				  FROM PatientProgram pp
				  WHERE PP.PatientID = P.tKeyId
				  AND PP.ProgramID = @i_ManagedPopulationID	)PatientADTId
			FROM @t_PatientIdList p
			
		END
	END

	IF (@l_TranStarted = 1) -- If transactions are there, then commit
	BEGIN
		SET @l_TranStarted = 0

		COMMIT TRANSACTION
	END
END TRY

---------------------------------------------------------------------------------------------------------------------     
BEGIN CATCH

		SELECT
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage

END CATCH
/* 
BEGIN CATCH
	-- Handle exception    
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH
 */

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_AdhocTask_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

