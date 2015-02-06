
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_AssignmentTasks]  64
Description   : This procedure is to be used to ->  assign the tasks to the patients for
the following tasktypes:communications , questionnaires , PEM, CPT
Created By    : Rathnam  
Created Date  : 30-Oct-2012
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
02-Aug-2013 NagaBabu Added @d_GetDate as variable 
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_AssignmentTasks] (
	@i_AppUserId KEYID
	,@i_ProgramID1 KEYID = NULL
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

	DECLARE @v_Message VARCHAR(2000)
		,@d_GetDate DATE = DATEADD(DD, 29, GETDATE())

	BEGIN TRANSACTION

	SET @v_Message = 'DATE : ' + CONVERT(VARCHAR, GETDATE()) + ' - Creating the Tasks for : Procedure - '

	RAISERROR (
			@v_Message
			,0
			,1
			)
	WITH NOWAIT

	INSERT INTO PatientProcedureGroupTask (
		PatientID
		,CodeGroupingID
		,Commments
		,StatusCode
		,DueDate
		,CreatedByUserId
		,ManagedPopulationID
		,IsProgramTask
		,AssignedCareProviderId
		,PatientProgramID
		)
	SELECT DISTINCT ups.PatientID
		,ptb.GeneralizedID
		,'Auto Assignment Tasks'
		,'A'
		,CASE 
			WHEN (
					SELECT TOP 1 upc.DueDate
					FROM PatientProcedureGroupTask upc WITH (NOLOCK)
					WHERE upc.CodeGroupingID = ptb.GeneralizedID
						AND ManagedPopulationID = ptb.ProgramID
						AND upc.PatientID = ups.PatientID
						AND upc.PatientProgramID = ups.PatientProgramID
					ORDER BY upc.PatientProcedureGroupTaskID DESC
					) IS NOT NULL
				THEN DATEADD(DD, CASE 
							WHEN ptb.Frequency = 'D'
								THEN ptb.FrequencyNumber * 1
							WHEN ptb.Frequency = 'W'
								THEN ptb.FrequencyNumber * 7
							WHEN ptb.Frequency = 'M'
								THEN ptb.FrequencyNumber * 30
							WHEN ptb.Frequency = 'Y'
								THEN ptb.FrequencyNumber * 365
							END, (
							SELECT TOP 1 upc.DueDate
							FROM PatientProcedureGroupTask upc WITH (NOLOCK)
							WHERE upc.CodeGroupingID = ptb.GeneralizedID
								AND ManagedPopulationID = ptb.ProgramID
								AND upc.PatientID = ups.PatientID
								AND upc.PatientProgramID = ups.PatientProgramID
							ORDER BY upc.PatientProcedureGroupTaskID DESC
							))
			WHEN ISNULL(cl.IsADT, 0) = 1 AND tbpf.RecurrenceType = 'R'
				THEN ups.EnrollmentStartDate
			WHEN ISNULL(cl.IsADT, 0) = 1 AND tbpf.RecurrenceType = 'O'
				THEN DATEADD(DD, CASE 
							WHEN ptb.Frequency = 'D'
								THEN ptb.FrequencyNumber * 1
							WHEN ptb.Frequency = 'W'
								THEN ptb.FrequencyNumber * 7
							WHEN ptb.Frequency = 'M'
								THEN ptb.FrequencyNumber * 30
							WHEN ptb.Frequency = 'Y'
								THEN ptb.FrequencyNumber * 365
							END, (ups.EnrollmentStartDate))	
			WHEN ISNULL(cl.IsADT, 0) = 0
				AND (
					SELECT DATEDIFF(DD, MAX(DateOfService), GETDATE())
					FROM PatientProcedureCode ppc
					INNER JOIN PatientProcedureCodeGroup ppcg
						ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
					WHERE ppcg.CodeGroupingID = ptb.GeneralizedID
						AND ppc.PatientID = ups.PatientID
					) <= CASE 
					WHEN ptb.Frequency = 'D'
						THEN ptb.FrequencyNumber * 1
					WHEN ptb.Frequency = 'W'
						THEN ptb.FrequencyNumber * 7
					WHEN ptb.Frequency = 'M'
						THEN ptb.FrequencyNumber * 30
					WHEN ptb.Frequency = 'Y'
						THEN ptb.FrequencyNumber * 365
					END
				THEN DATEADD(DD, CASE 
							WHEN ptb.Frequency = 'D'
								THEN ptb.FrequencyNumber * 1
							WHEN ptb.Frequency = 'W'
								THEN ptb.FrequencyNumber * 7
							WHEN ptb.Frequency = 'M'
								THEN ptb.FrequencyNumber * 30
							WHEN ptb.Frequency = 'Y'
								THEN ptb.FrequencyNumber * 365
							END, (
							SELECT MAX(DateOfService)
							FROM PatientProcedureCode ppc
							INNER JOIN PatientProcedureCodeGroup ppcg
								ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
							WHERE ppcg.CodeGroupingID = ptb.GeneralizedID
								AND ppc.PatientID = ups.PatientID
							))
			ELSE CASE WHEN ups.EnrollmentStartDate IS NOT NULL THEN DATEADD(DD,29,ups.EnrollmentStartDate) ELSE  @d_GetDate END
			END
		,@i_AppUserId
		,ptb.ProgramID
		,1
		,ups.ProviderID
		,ups.PatientProgramID
	FROM ProgramPatientTaskConflict pptc WITH (NOLOCK)
	INNER JOIN PatientProgram ups WITH (NOLOCK)
		ON ups.PatientID = pptc.PatientUserID
	INNER JOIN ProgramTaskBundle ptb WITH (NOLOCK)
		ON ptb.ProgramTaskBundleID = pptc.ProgramTaskBundleId
			AND ptb.ProgramID = ups.ProgramId
	INNER JOIN TaskBundleProcedureFrequency tbpf
	    ON tbpf.TaskBundleId = ptb.TaskBundleID
	   AND tbpf.CodeGroupingId = ptb.GeneralizedID
	   AND tbpf.FrequencyNumber = ptb.FrequencyNumber
	   AND tbpf.Frequency = ptb.Frequency 		
	INNER JOIN Program p WITH (NOLOCK)
		ON p.ProgramID = ptb.ProgramID
	INNER JOIN PopulationDefinition cl WITH (NOLOCK)
		ON cl.PopulationDefinitionID = p.PopulationDefinitionID
	WHERE pptc.StatusCode = 'A'
		AND p.StatusCode = 'A'
		AND ptb.StatusCode = 'A'
		AND ups.StatusCode = 'A'
		AND (
			ups.ProgramId = @i_ProgramID1
			OR @i_ProgramID1 IS NULL
			)
		AND ups.EnrollmentEndDate IS NULL
		AND ups.EnrollmentStartDate IS NOT NULL
		--AND ups.IsCommunicated = 1 --Should Be enable this line
		AND ptb.TaskType = 'P'
		AND NOT EXISTS (
			SELECT 1
			FROM PatientProcedureGroupTask upc WITH (NOLOCK)
			WHERE upc.CodeGroupingID = ptb.GeneralizedID
				AND ((tbpf.RecurrenceType = 'R' AND  upc.ProcedureGroupCompletedDate IS NULL) OR (tbpf.RecurrenceType = 'O'))
				AND upc.ManagedPopulationID = ups.ProgramId
				AND upc.PatientID = ups.PatientID
				AND upc.IsProgramTask = 1
				AND upc.PatientProgramID = ups.PatientProgramID
			)

	UPDATE Task
	SET RemainderID = tr.ProgramTaskTypeCommunicationID
		,CommunicationTypeID = tr.CommunicationTypeID
		,CommunicationTemplateID = tr.CommunicationTemplateID
		,RemainderDays = tr.CommunicationAttemptDays
		,CommunicationSequence = tr.CommunicationSequence
		,TotalRemainderCount = (
			SELECT COUNT(*)
			FROM ProgramTaskTypeCommunication WITH (NOLOCK)
			WHERE ProgramTaskTypeCommunication.ProgramId = tr.ProgramID
				AND ProgramTaskTypeCommunication.GeneralizedID = tr.GeneralizedID
				AND ProgramTaskTypeCommunication.TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
			)
		,TerminationDays = CASE 
			WHEN TerminationDays IS NULL
				THEN tr.NoOfDaysBeforeTaskClosedInComplete
			ELSE TerminationDays
			END
		,AttemptedRemainderCount = 0
		,RemainderState = tr.RemainderState
		,NextRemainderDays = (
			SELECT TOP 1 ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete)
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
				AND CommunicationSequence > (
					SELECT MIN(CommunicationSequence)
					FROM ProgramTaskTypeCommunication
					WHERE ProgramID = tr.ProgramID
						AND GeneralizedID = tr.GeneralizedID
						AND TaskTypeID = tr.TaskTypeID
						AND StatusCode = 'A'
					)
			ORDER BY CommunicationSequence ASC
			)
		,NextRemainderState = (
			SELECT TOP 1 RemainderState
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
				AND CommunicationSequence > (
					SELECT MIN(CommunicationSequence)
					FROM ProgramTaskTypeCommunication
					WHERE ProgramID = tr.ProgramID
						AND GeneralizedID = tr.GeneralizedID
						AND TaskTypeID = tr.TaskTypeID
						AND StatusCode = 'A'
					)
			ORDER BY CommunicationSequence ASC
			)
	FROM ProgramTaskTypeCommunication tr WITH (NOLOCK)
	INNER JOIN TaskType ty
		ON ty.TaskTypeId = tr.TaskTypeID
	WHERE tr.ProgramId = Task.ProgramID
		AND tr.GeneralizedID = Task.TypeID
		AND tr.TaskTypeID = Task.TaskTypeId
		AND tr.CommunicationSequence = (
			SELECT MIN(CommunicationSequence)
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
			)
		AND Task.IsProgramTask = 1
		AND Task.IsBatchProgram = 1
		AND ty.TaskTypeName = 'Schedule Procedure'

	UPDATE Task
	SET IsBatchProgram = 0
	FROM TaskType
	WHERE TaskType.TaskTypeId = Task.TaskTypeId
		AND TaskTypeName = 'Schedule Procedure'
		AND Task.IsBatchProgram = 1

	COMMIT TRANSACTION

	BEGIN TRANSACTION

	SET @v_Message = 'DATE : ' + CONVERT(VARCHAR, GETDATE()) + ' - Creating the Tasks for : Questionnaire - '

	RAISERROR (
			@v_Message
			,0
			,1
			)
	WITH NOWAIT

	INSERT INTO PatientQuestionaire (
		PatientID
		,QuestionaireId
		,DateDue
		,DateAssigned
		,Comments
		,CreatedByUserId
		,ProgramId
		,IsProgramTask
		,AssignedCareProviderId
		,PatientProgramID
		)
	SELECT DISTINCT ups.PatientID
		,ptb.GeneralizedID
		,CASE 
			WHEN (
					SELECT TOP 1 uq.DateDue
					FROM PatientQuestionaire uq WITH (NOLOCK)
					WHERE uq.QuestionaireId = ptb.GeneralizedID
						AND ProgramId = ptb.ProgramID
						AND uq.IsEnrollment = 0
						AND uq.PatientID = pptc.PatientUserID
						AND uq.PatientProgramID = ups.PatientProgramID
					ORDER BY uq.PatientQuestionaireId DESC
					) IS NOT NULL
				THEN DATEADD(DD, CASE 
							WHEN ptb.Frequency = 'D'
								THEN ptb.FrequencyNumber * 1
							WHEN ptb.Frequency = 'W'
								THEN ptb.FrequencyNumber * 7
							WHEN ptb.Frequency = 'M'
								THEN ptb.FrequencyNumber * 30
							WHEN ptb.Frequency = 'Y'
								THEN ptb.FrequencyNumber * 365
							END, (
							SELECT TOP 1 uq.DateDue
							FROM PatientQuestionaire uq WITH (NOLOCK)
							WHERE uq.QuestionaireId = ptb.GeneralizedID
								AND ProgramId = ptb.ProgramID
								AND uq.IsEnrollment = 0
								AND uq.PatientID = pptc.PatientUserID
								AND uq.PatientProgramID = ups.PatientProgramID
							ORDER BY uq.PatientQuestionaireId DESC
							))
			WHEN ISNULL(cl.IsADT, 0) = 1 AND tbpf.RecurrenceType = 'R'
				THEN ups.EnrollmentStartDate
			WHEN ISNULL(cl.IsADT, 0) = 1 AND tbpf.RecurrenceType = 'O'
				THEN DATEADD(DD, CASE 
							WHEN ptb.Frequency = 'D'
								THEN ptb.FrequencyNumber * 1
							WHEN ptb.Frequency = 'W'
								THEN ptb.FrequencyNumber * 7
							WHEN ptb.Frequency = 'M'
								THEN ptb.FrequencyNumber * 30
							WHEN ptb.Frequency = 'Y'
								THEN ptb.FrequencyNumber * 365
							END, (ups.EnrollmentStartDate))
			ELSE CASE WHEN ups.EnrollmentStartDate IS NOT NULL THEN DATEADD(DD,29,ups.EnrollmentStartDate) ELSE  @d_GetDate END
			END
		,GETDATE()
		,'Auto Assignment Tasks'
		,@i_AppUserId
		,ptb.ProgramID
		,1
		,ups.ProviderID
		,ups.PatientProgramID
	FROM ProgramPatientTaskConflict pptc WITH (NOLOCK)
	INNER JOIN PatientProgram ups WITH (NOLOCK)
		ON ups.PatientID = pptc.PatientUserID
	INNER JOIN ProgramTaskBundle ptb WITH (NOLOCK)
		ON ptb.ProgramTaskBundleID = pptc.ProgramTaskBundleId
			AND ptb.ProgramID = ups.ProgramId
	INNER JOIN TaskBundleQuestionnaireFrequency tbpf
	    ON tbpf.TaskBundleId = ptb.TaskBundleID
	   AND tbpf.QuestionaireId = ptb.GeneralizedID
	   AND tbpf.FrequencyNumber = ptb.FrequencyNumber
	   AND tbpf.Frequency = ptb.Frequency		
	INNER JOIN Program p WITH (NOLOCK)
		ON p.ProgramID = ptb.ProgramID
	INNER JOIN PopulationDefinition cl WITH (NOLOCK)
		ON cl.PopulationDefinitionID = p.PopulationDefinitionID
	WHERE pptc.StatusCode = 'A'
		AND p.StatusCode = 'A'
		AND ptb.StatusCode = 'A'
		AND ups.StatusCode = 'A'
		AND (
			ups.ProgramId = @i_ProgramID1
			OR @i_ProgramID1 IS NULL
			)
		AND ups.EnrollmentEndDate IS NULL
		AND ups.EnrollmentStartDate IS NOT NULL
		--AND ups.UserID = 21
		--AND ups.IsCommunicated = 1 --Should Be enable this line
		AND ptb.TaskType = 'Q'
		AND NOT EXISTS (
			SELECT 1
			FROM PatientQuestionaire uq WITH (NOLOCK)
			WHERE uq.QuestionaireId = ptb.GeneralizedID
				AND ((tbpf.RecurrenceType = 'R' AND   uq.DateTaken IS NULL) OR (tbpf.RecurrenceType = 'O'))
				AND uq.ProgramId = ptb.ProgramID
				AND uq.PatientID = pptc.PatientUserID
				AND ISNULL(uq.IsEnrollment, 0) = 0
				AND uq.IsProgramTask = 1
				AND uq.PatientProgramID = ups.PatientProgramID
			)

	UPDATE Task
	SET RemainderID = tr.ProgramTaskTypeCommunicationID
		,CommunicationTypeID = tr.CommunicationTypeID
		,CommunicationTemplateID = tr.CommunicationTemplateID
		,RemainderDays = tr.CommunicationAttemptDays
		,CommunicationSequence = tr.CommunicationSequence
		,TotalRemainderCount = (
			SELECT COUNT(*)
			FROM ProgramTaskTypeCommunication WITH (NOLOCK)
			WHERE ProgramTaskTypeCommunication.ProgramId = tr.ProgramID
				AND ProgramTaskTypeCommunication.GeneralizedID = tr.GeneralizedID
				AND ProgramTaskTypeCommunication.TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
			)
		,TerminationDays = CASE 
			WHEN TerminationDays IS NULL
				THEN tr.NoOfDaysBeforeTaskClosedInComplete
			ELSE TerminationDays
			END
		,AttemptedRemainderCount = 0
		,RemainderState = tr.RemainderState
		,NextRemainderDays = (
			SELECT TOP 1 ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete)
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
				AND CommunicationSequence > (
					SELECT MIN(CommunicationSequence)
					FROM ProgramTaskTypeCommunication
					WHERE ProgramID = tr.ProgramID
						AND GeneralizedID = tr.GeneralizedID
						AND TaskTypeID = tr.TaskTypeID
						AND StatusCode = 'A'
					)
			ORDER BY CommunicationSequence ASC
			)
		,NextRemainderState = (
			SELECT TOP 1 RemainderState
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
				AND CommunicationSequence > (
					SELECT MIN(CommunicationSequence)
					FROM ProgramTaskTypeCommunication
					WHERE ProgramID = tr.ProgramID
						AND GeneralizedID = tr.GeneralizedID
						AND TaskTypeID = tr.TaskTypeID
						AND StatusCode = 'A'
					)
			ORDER BY CommunicationSequence ASC
			)
	FROM ProgramTaskTypeCommunication tr WITH (NOLOCK)
	INNER JOIN TaskType ty
		ON ty.TaskTypeId = tr.TaskTypeID
	WHERE tr.ProgramId = Task.ProgramID
		AND tr.GeneralizedID = Task.TypeID
		AND tr.TaskTypeID = Task.TaskTypeId
		AND tr.CommunicationSequence = (
			SELECT MIN(CommunicationSequence)
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
			)
		AND Task.IsProgramTask = 1
		AND Task.IsBatchProgram = 1
		AND ty.TaskTypeName = 'Questionnaire'

	UPDATE Task
	SET IsBatchProgram = 0
	FROM TaskType
	WHERE TaskType.TaskTypeId = Task.TaskTypeId
		AND TaskTypeName = 'Questionnaire'
		AND Task.IsBatchProgram = 1

	COMMIT TRANSACTION

	BEGIN TRANSACTION

	SET @v_Message = 'DATE : ' + CONVERT(VARCHAR, GETDATE()) + ' - Creating the Tasks for : OtherTask - '

	RAISERROR (
			@v_Message
			,0
			,1
			)
	WITH NOWAIT

	INSERT INTO PatientOtherTask (
		PatientID
		,AdhocTaskId
		,DateDue
		,Comments
		,CreatedByUserId
		,ProgramId
		,IsProgramTask
		,PatientProgramID
		)
	SELECT DISTINCT ups.PatientID
		,ptb.GeneralizedID
		,CASE 
			WHEN (
					SELECT TOP 1 uo.DateDue
					FROM PatientOtherTask uo WITH (NOLOCK)
					WHERE uo.AdhocTaskId = ptb.GeneralizedID
						AND ProgramId = ptb.ProgramID
						AND uo.PatientID = pptc.PatientUserID
						AND ups.PatientProgramID = uo.PatientProgramID
					ORDER BY uo.PatientOtherTaskId DESC
					) IS NOT NULL
				THEN DATEADD(DD, CASE 
							WHEN ptb.Frequency = 'D'
								THEN ptb.FrequencyNumber * 1
							WHEN ptb.Frequency = 'W'
								THEN ptb.FrequencyNumber * 7
							WHEN ptb.Frequency = 'M'
								THEN ptb.FrequencyNumber * 30
							WHEN ptb.Frequency = 'Y'
								THEN ptb.FrequencyNumber * 365
							END, (
							SELECT TOP 1 uo.DateDue
							FROM PatientOtherTask uo WITH (NOLOCK)
							WHERE uo.AdhocTaskId = ptb.GeneralizedID
								AND ProgramId = ptb.ProgramID
								AND uo.PatientID = pptc.PatientUserID
								AND ups.PatientProgramID = uo.PatientProgramID
							ORDER BY uo.PatientOtherTaskId DESC
							))
			WHEN ISNULL(cl.IsADT, 0) = 1 AND tbpf.RecurrenceType = 'R'
				THEN ups.EnrollmentStartDate
			WHEN ISNULL(cl.IsADT, 0) = 1 AND tbpf.RecurrenceType = 'O'
				THEN DATEADD(DD, CASE 
							WHEN ptb.Frequency = 'D'
								THEN ptb.FrequencyNumber * 1
							WHEN ptb.Frequency = 'W'
								THEN ptb.FrequencyNumber * 7
							WHEN ptb.Frequency = 'M'
								THEN ptb.FrequencyNumber * 30
							WHEN ptb.Frequency = 'Y'
								THEN ptb.FrequencyNumber * 365
							END, (ups.EnrollmentStartDate))
			ELSE CASE WHEN ups.EnrollmentStartDate IS NOT NULL THEN DATEADD(DD,29,ups.EnrollmentStartDate) ELSE  @d_GetDate END
			END
		,'Auto Assignment Tasks'
		,@i_AppUserId
		,ptb.ProgramID
		,1
		,ups.PatientProgramID
	FROM ProgramPatientTaskConflict pptc WITH (NOLOCK)
	INNER JOIN PatientProgram ups WITH (NOLOCK)
		ON ups.PatientID = pptc.PatientUserID
	INNER JOIN ProgramTaskBundle ptb WITH (NOLOCK)
		ON ptb.ProgramTaskBundleID = pptc.ProgramTaskBundleId
			AND ptb.ProgramID = ups.ProgramId
	INNER JOIN TaskBundleAdhocFrequency tbpf
	    ON tbpf.TaskBundleId = ptb.TaskBundleID
	   AND tbpf.AdhocTaskId = ptb.GeneralizedID
	   AND tbpf.FrequencyNumber = ptb.FrequencyNumber
	   AND tbpf.Frequency = ptb.Frequency 		
	INNER JOIN Program p WITH (NOLOCK)
		ON p.ProgramID = ptb.ProgramID
	INNER JOIN PopulationDefinition cl WITH (NOLOCK)
		ON cl.PopulationDefinitionID = p.PopulationDefinitionID
	WHERE pptc.StatusCode = 'A'
		AND p.StatusCode = 'A'
		AND ptb.StatusCode = 'A'
		AND ups.StatusCode = 'A'
		AND (
			ups.ProgramId = @i_ProgramID1
			OR @i_ProgramID1 IS NULL
			)
		AND ups.EnrollmentEndDate IS NULL
		AND ups.EnrollmentStartDate IS NOT NULL
		--AND ups.UserID = 21
		--AND ups.IsCommunicated = 1 --Should Be enable this line
		AND ptb.TaskType = 'O'
		AND NOT EXISTS (
			SELECT 1
			FROM PatientOtherTask uo WITH (NOLOCK)
			WHERE uo.AdhocTaskId = ptb.GeneralizedID
				AND ((tbpf.RecurrenceType = 'R' AND  uo.DateTaken IS NULL) OR (tbpf.RecurrenceType = 'O'))
				AND uo.ProgramId = ptb.ProgramID
				AND uo.PatientID = pptc.PatientUserID
				AND uo.IsProgramTask = 1
				AND uo.PatientProgramID = ups.PatientProgramID
			)

	UPDATE Task
	SET RemainderID = tr.ProgramTaskTypeCommunicationID
		,CommunicationTypeID = tr.CommunicationTypeID
		,CommunicationTemplateID = tr.CommunicationTemplateID
		,RemainderDays = tr.CommunicationAttemptDays
		,CommunicationSequence = tr.CommunicationSequence
		,TotalRemainderCount = (
			SELECT COUNT(*)
			FROM ProgramTaskTypeCommunication WITH (NOLOCK)
			WHERE ProgramTaskTypeCommunication.ProgramId = tr.ProgramID
				AND ProgramTaskTypeCommunication.GeneralizedID = tr.GeneralizedID
				AND ProgramTaskTypeCommunication.TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
			)
		,TerminationDays = CASE 
			WHEN TerminationDays IS NULL
				THEN tr.NoOfDaysBeforeTaskClosedInComplete
			ELSE TerminationDays
			END
		,AttemptedRemainderCount = 0
		,RemainderState = tr.RemainderState
		,NextRemainderDays = (
			SELECT TOP 1 ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete)
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
				AND CommunicationSequence > (
					SELECT MIN(CommunicationSequence)
					FROM ProgramTaskTypeCommunication
					WHERE ProgramID = tr.ProgramID
						AND GeneralizedID = tr.GeneralizedID
						AND TaskTypeID = tr.TaskTypeID
						AND StatusCode = 'A'
					)
			ORDER BY CommunicationSequence ASC
			)
		,NextRemainderState = (
			SELECT TOP 1 RemainderState
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
				AND CommunicationSequence > (
					SELECT MIN(CommunicationSequence)
					FROM ProgramTaskTypeCommunication
					WHERE ProgramID = tr.ProgramID
						AND GeneralizedID = tr.GeneralizedID
						AND TaskTypeID = tr.TaskTypeID
						AND StatusCode = 'A'
					)
			ORDER BY CommunicationSequence ASC
			)
	FROM ProgramTaskTypeCommunication tr WITH (NOLOCK)
	INNER JOIN TaskType ty
		ON ty.TaskTypeId = tr.TaskTypeID
	WHERE tr.ProgramId = Task.ProgramID
		AND tr.GeneralizedID = Task.TypeID
		AND tr.TaskTypeID = Task.TaskTypeId
		AND tr.CommunicationSequence = (
			SELECT MIN(CommunicationSequence)
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
			)
		AND Task.IsBatchProgram = 1
		AND Task.IsProgramTask = 1
		AND ty.TaskTypeName = 'Other Tasks'

	UPDATE Task
	SET IsBatchProgram = 0
	FROM TaskType
	WHERE TaskType.TaskTypeId = Task.TaskTypeId
		AND TaskTypeName = 'Other Tasks'
		AND Task.IsBatchProgram = 1

	COMMIT TRANSACTION

	BEGIN TRANSACTION

	SET @v_Message = 'DATE : ' + CONVERT(VARCHAR, GETDATE()) + ' - Creating the Tasks for : PEM - '

	RAISERROR (
			@v_Message
			,0
			,1
			)
	WITH NOWAIT

	INSERT INTO PatientEducationMaterial (
		PatientID
		,EducationMaterialID
		,DueDate
		,Comments
		,StatusCode
		,CreatedByUserId
		,ProgramID
		,IsProgramTask
		,ProviderID
		,PatientProgramID
		)
	SELECT DISTINCT ups.PatientID
		,ptb.GeneralizedID
		,ups.EnrollmentStartDate
		,'Auto Assignment Tasks'
		,'A'
		,@i_AppUserId
		,ptb.ProgramID
		,1
		,ups.ProviderID
		,ups.PatientProgramID
	FROM ProgramPatientTaskConflict pptc WITH (NOLOCK)
	INNER JOIN PatientProgram ups WITH (NOLOCK)
		ON ups.PatientID = pptc.PatientUserID
	INNER JOIN ProgramTaskBundle ptb WITH (NOLOCK)
		ON ptb.ProgramTaskBundleID = pptc.ProgramTaskBundleId
			AND ptb.ProgramID = ups.ProgramId
	INNER JOIN Program p WITH (NOLOCK)
		ON p.ProgramID = ptb.ProgramID
	INNER JOIN PopulationDefinition cl WITH (NOLOCK)
		ON cl.PopulationDefinitionID = p.PopulationDefinitionID
	WHERE pptc.StatusCode = 'A'
		AND p.StatusCode = 'A'
		AND ptb.StatusCode = 'A'
		AND ups.StatusCode = 'A'
		AND (
			ups.ProgramId = @i_ProgramID1
			OR @i_ProgramID1 IS NULL
			)
		AND ups.EnrollmentEndDate IS NULL
		AND ups.EnrollmentStartDate IS NOT NULL
		--AND ups.UserID = 21
		--AND ups.IsCommunicated = 1 --Should Be enable this line
		AND ptb.TaskType = 'E'
		AND NOT EXISTS (
			SELECT 1
			FROM PatientEducationMaterial pem WITH (NOLOCK)
			WHERE pem.EducationMaterialID = ptb.GeneralizedID
				AND pem.ProgramId = ptb.ProgramID
				AND pem.PatientID = pptc.PatientUserID
				AND pem.IsProgramTask = 1
				AND pem.PatientProgramID = ups.PatientProgramID
			)

	INSERT INTO PatientEducationMaterialLibrary (
		PatientEducationMaterialID
		,LibraryId
		,CreatedByUserId
		)
	SELECT DISTINCT pem.PatientEducationMaterialID
		,tblLibraryId.LibraryId
		,@i_AppUserId
	FROM EducationMaterialLibrary tblLibraryId
	INNER JOIN PatientEducationMaterial pem
		ON pem.EducationMaterialID = tblLibraryId.EducationMaterialID
	INNER JOIN Task
		ON Task.PatientTaskID = pem.PatientEducationMaterialID
	INNER JOIN TaskType
		ON TaskType.TaskTypeId = Task.TaskTypeId
	WHERE Task.IsBatchProgram = 1
		AND TaskType.TaskTypeName = 'Patient Education Material'
		AND NOT EXISTS (
			SELECT 1
			FROM PatientEducationMaterialLibrary WITH (NOLOCK)
			WHERE PatientEducationMaterialID = pem.PatientEducationMaterialID
				AND LibraryId = tblLibraryId.LibraryId
			)

	UPDATE Task
	SET RemainderID = tr.ProgramTaskTypeCommunicationID
		,CommunicationTypeID = tr.CommunicationTypeID
		,CommunicationTemplateID = tr.CommunicationTemplateID
		,RemainderDays = tr.CommunicationAttemptDays
		,CommunicationSequence = tr.CommunicationSequence
		,TotalRemainderCount = (
			SELECT COUNT(*)
			FROM ProgramTaskTypeCommunication WITH (NOLOCK)
			WHERE ProgramTaskTypeCommunication.ProgramId = tr.ProgramID
				AND ProgramTaskTypeCommunication.GeneralizedID = tr.GeneralizedID
				AND ProgramTaskTypeCommunication.TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
			)
		,TerminationDays = CASE 
			WHEN TerminationDays IS NULL
				THEN tr.NoOfDaysBeforeTaskClosedInComplete
			ELSE TerminationDays
			END
		,AttemptedRemainderCount = 0
		,RemainderState = tr.RemainderState
		,NextRemainderDays = (
			SELECT TOP 1 ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete)
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
				AND CommunicationSequence > (
					SELECT MIN(CommunicationSequence)
					FROM ProgramTaskTypeCommunication
					WHERE ProgramID = tr.ProgramID
						AND GeneralizedID = tr.GeneralizedID
						AND TaskTypeID = tr.TaskTypeID
						AND StatusCode = 'A'
					)
			ORDER BY CommunicationSequence ASC
			)
		,NextRemainderState = (
			SELECT TOP 1 RemainderState
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
				AND CommunicationSequence > (
					SELECT MIN(CommunicationSequence)
					FROM ProgramTaskTypeCommunication
					WHERE ProgramID = tr.ProgramID
						AND GeneralizedID = tr.GeneralizedID
						AND TaskTypeID = tr.TaskTypeID
						AND StatusCode = 'A'
					)
			ORDER BY CommunicationSequence ASC
			)
	FROM ProgramTaskTypeCommunication tr WITH (NOLOCK)
	INNER JOIN TaskType ty
		ON tr.TaskTypeID = ty.TaskTypeId
	WHERE tr.ProgramId = Task.ProgramID
		AND tr.GeneralizedID = Task.TypeID
		AND tr.TaskTypeID = Task.TaskTypeId
		AND tr.CommunicationSequence = (
			SELECT MIN(CommunicationSequence)
			FROM ProgramTaskTypeCommunication
			WHERE ProgramID = tr.ProgramID
				AND GeneralizedID = tr.GeneralizedID
				AND TaskTypeID = tr.TaskTypeID
				AND StatusCode = 'A'
			)
		AND ty.TaskTypeName = 'Patient Education Material'
		AND Task.IsProgramTask = 1
		AND Task.IsBatchProgram = 1

	UPDATE Task
	SET IsBatchProgram = 0
	FROM TaskType
	WHERE TaskType.TaskTypeId = Task.TaskTypeId
		AND TaskTypeName = 'Patient Education Material'
		AND Task.IsBatchProgram = 1

	UPDATE Task
	SET AssignedCareProviderId = PatientProgram.ProviderID
	FROM PatientProgram
	WHERE PatientProgram.ProgramId = Task.ProgramID
		AND PatientProgram.PatientID = Task.PatientID
		AND Task.AssignedCareProviderId IS NULL

	COMMIT TRANSACTION
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_AssignmentTasks] TO [FE_rohit.r-ext]
    AS [dbo];

