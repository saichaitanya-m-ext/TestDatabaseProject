
/*                  
------------------------------------------------------------------------------                  
Procedure Name: usp_CareProviderDashBoard_MyTasksByPatientID  23,226585,NULL,23      
Description   : This procedure is used to get the open tasks select by patientID             
Created By    : Rathnam                  
Created Date  : 28-Oct-2010                  
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY  BY   DESCRIPTION       
07-Jan-2013 NagaBabu Modified derivation for IsAdhoc Field in resultset       
02-Feb-2013 Praveen Added parameter @i_IsShortList to get top 5 records based on condition      
25-July-2013 Rathnam added PatientTaskID GeneralizedID  
20-02-2014 Rathnam commented the assigned careprovider functionality as we need to get the tasks based on tasktypes     
------------------------------------------------------------------------------       
*/
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyTasksByPatientID] (
	@i_AppUserId KEYID
	,@i_PatientUserID KEYID
	,@i_TaskID KEYID = NULL
	,@t_CareTeamMemberId TTYPEKEYID READONLY
	,@i_IsShortList KeyID = NULL
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

    	CREATE TABLE #Program (ProgramID INT,ADTType VARCHAR(1))

	INSERT INTO #Program (ProgramID,ADTType)
	SELECT DISTINCT p.ProgramId,ADTtype
	FROM ProgramCareTeam pct WITH (NOLOCK)
	INNER JOIN CareTeamMembers ctm WITH (NOLOCK)
		ON ctm.CareTeamID = pct.CareTeamID
	INNER JOIN Program p WITH (NOLOCK)
		ON p.ProgramId = pct.ProgramId
	INNER JOIN PopulationDefinition PD
	     ON p.PopulationDefinitionID = PD.PopulationDefinitionID
	WHERE ctm.ProviderID = @i_AppUserId
		AND ctm.StatusCode = 'A';
		
	CREATE TABLE #tblCareTeamMember (ProviderID INT)

	IF NOT EXISTS (
			SELECT 1
			FROM @t_CareTeamMemberId
			)
	BEGIN
	  IF EXISTS (SELECT 1 FROM CareTeamMembers ctm WHERE ctm.ProviderID = @i_AppUserId AND ctm.IsCareTeamManager = 1)
		BEGIN /* This condition is for Caremanager who comes from Patientdashboard task page*/
		   INSERT INTO #tblCareTeamMember
		   SELECT DISTINCT ctm.ProviderID FROM CareTeamMembers ctm
		   INNER JOIN ProgramCareTeam pct
		   ON ctm.CareTeamId = pct.CareTeamId
		   INNER JOIN #Program p
		   ON p.ProgramID = pct.ProgramId
		   WHERE ctm.StatusCode = 'A'
		END 
	  ELSE
		BEGIN
		    INSERT INTO #tblCareTeamMember
		    SELECT @i_AppUserId
		END
	END
	ELSE
	BEGIN
		INSERT INTO #tblCareTeamMember
		SELECT tKeyId
		FROM @t_CareTeamMemberId
	END

	DECLARE @tTaskRights TABLE (TaskTypeID INT)

	INSERT INTO @tTaskRights
	SELECT DISTINCT TaskType.TaskTypeId
	FROM CareTeamTaskRights WITH (NOLOCK)
	INNER JOIN TaskType WITH (NOLOCK)
		ON TaskType.TaskTypeId = CareTeamTaskRights.TaskTypeId
	INNER JOIN #tblCareTeamMember
		ON #tblCareTeamMember.ProviderID = CareTeamTaskRights.ProviderID
	WHERE TaskType.StatusCode = 'A'
		AND CareTeamTaskRights.StatusCode = 'A'


	;WITH cteTask
	AS (
		SELECT DISTINCT t.Taskid
			,t.TaskTypeId
			,ISNULL(ty.TaskTypeName, 'Manual Task') TaskTypeName
			,t.TaskDueDate DateDue
			,cte.CommunicationType NextCommunicationType
			,t.AttemptedRemainderCount Attempts
			,t.RemainderDays CommunicationAttemptedDays
			,t.TerminationDays NoOfDaysBeforeTaskClosedIncomplete
			,t.RemainderID TaskTypeCommunicationID
			,t.CommunicationSequence
			,cte.CommunicationTypeID CommunicationTyepID
			,CASE 
				WHEN ISNULL(t.TerminationDays, 0) <> 0
					THEN DATEADD(DD, t.TerminationDays, t.TaskDueDate)
				WHEN ISNULL(t.RemainderDays, 0) <> 0
					AND RemainderState = 'B'
					THEN DATEADD(DD, - t.RemainderDays, t.TaskDueDate)
				WHEN ISNULL(t.RemainderDays, 0) <> 0
					AND RemainderState = 'A'
					THEN DATEADD(DD, t.RemainderDays, t.TaskDueDate)
				ELSE t.TaskDuedate
				END NextContactedDate
			,CASE 
				WHEN ISNULL(t.TerminationDays, 0) <> 0
					THEN DATEADD(DD, t.TerminationDays, t.TaskDueDate)
				END TaskTerminationDate
			,t.TypeID
			,ISNULL(dbo.ufn_GetTypeNamesByTypeId(ty.TaskTypeName, t.TypeID), t.ManualTaskName) TypeName
			,0 IsCareGap
			,CASE 
				WHEN IsEnrollment = 1
					THEN 'False'
				WHEN IsAdhoc = 0
					AND ISNULL(IsProgramTask, 0) = 1
					THEN 'False'
				WHEN IsAdhoc = 1
					THEN 'True'
				WHEN ISNULL(IsAdhoc, 0) = 0
					AND ISNULL(IsProgramTask, 0) = 0
					THEN 'True'
				ELSE NULL
				END AS IsAdhoc
			,t.Comments
			,t.CommunicationTemplateID
			,ct.TemplateName
			,t.TaskCompletedDate
			,t.PatientId PatientUserId
			,t.PatientTaskID GeneralizedID
			,t.TotalRemainderCount TotalFutureTasks
			,DATEDIFF(DAY, CASE 
					WHEN ISNULL(t.TerminationDays, 0) <> 0
						THEN DATEADD(DD, t.TerminationDays, t.TaskDueDate)
					WHEN ISNULL(t.RemainderDays, 0) <> 0
						AND RemainderState = 'B'
						THEN DATEADD(DD, - t.RemainderDays, t.TaskDueDate)
					WHEN ISNULL(t.RemainderDays, 0) <> 0
						AND RemainderState = 'A'
						THEN DATEADD(DD, t.RemainderDays, t.TaskDueDate)
					ELSE t.TaskDuedate
					END, GETDATE()) DaysLate
			,CASE 
				WHEN ISNULL(t.NextRemainderDays, 0) <> 0
					AND t.NextRemainderState = 'B'
					THEN DATEADD(DD, - t.NextRemainderDays, t.TaskDueDate)
				WHEN ISNULL(t.NextRemainderDays, 0) <> 0
					AND t.NextRemainderState = 'A'
					THEN DATEADD(DD, t.NextRemainderDays, t.TaskDueDate)
				END RemainderNextContactedDate,
		CASE WHEN P.ADTType IS NOT NULL THEN [dbo].[ufn_PatientADTstatus](t.PatientID, p.ADTtype) ELSE NULL END AS ADTStatus
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'AdmitDate',t.PatientADTId) 
								  ELSE NULL
							 END AS AdmitDate,
		CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'Facility',t.PatientADTId) 
								  ELSE NULL
							 END AS FacilityName					 
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'LastDischargedate',t.PatientADTId) 
								  ELSE NULL
							 END AS LastDischargeDate
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'LastFacility',t.PatientADTId) 
								  ELSE NULL
							 END AS LastFacilityName		
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'NoOfDays',t.PatientADTId) 
								  ELSE NULL
							 END AS NumberOfDays	
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'Dischargedate',t.PatientADTId) 
								  ELSE NULL
							 END AS DischargeDate
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'Facility',t.PatientADTId) 
								  ELSE NULL
							 END AS DisChargeFacilityName		
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'DischargedTo',t.PatientADTId) 
								  ELSE NULL
							 END AS DischargedTo
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'AdmitDate',t.PatientADTId) 
								  ELSE NULL
							 END AS DisChargeAdmitDate
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'InPatientDays',t.PatientADTId) 
								  ELSE NULL
							 END AS InpatientDays					 					 					 			 					 				 			 					 
				FROM Task t WITH (NOLOCK)
		INNER JOIN #Program p
			ON t.ProgramID = p.ProgramID
		--INNER JOIN #tblCareTeamMember ctm
		--	ON ctm.ProviderID = t.AssignedCareProviderId
		INNER JOIN TaskType ty WITH (NOLOCK)
			ON t.TaskTypeId = ty.TaskTypeId
		INNER JOIN @tTaskRights ty1
			ON ty1.TaskTypeID = ty.TaskTypeId
		INNER JOIN TaskStatus ts WITH (NOLOCK)
			ON ts.TaskStatusId = t.TaskStatusId
		LEFT JOIN CommunicationType cte WITH (NOLOCK)
			ON cte.CommunicationTypeId = t.CommunicationTypeID
		LEFT JOIN CommunicationTemplate ct WITH (NOLOCK)
			ON ct.CommunicationTemplateId = t.CommunicationTemplateID
		WHERE ts.TaskStatusText = 'Open'
			AND t.PatientId = @i_PatientUserID
		
		UNION
		
		SELECT t.Taskid
			,t.TaskTypeId
			,ISNULL(ty.TaskTypeName, 'Manual Task') TaskTypeName
			,t.TaskDueDate DateDue
			,NULL AS NextCommunicationType
			,t.AttemptedRemainderCount Attempts
			,NULL CommunicationAttemptedDays
			,NULL AS NoOfDaysBeforeTaskClosedIncomplete
			,NULL TaskTypeCommunicationID
			,NULL AS CommunicationSequence
			,NULL AS CommunicationTyepID
			,NULL AS NextContactedDate
			,NULL TaskTerminationDate
			,t.TypeID
			,ISNULL(dbo.ufn_GetTypeNamesByTypeId(ty.TaskTypeName, t.TypeID), t.ManualTaskName) TypeName
			,0 IsCareGap
			,CASE 
				WHEN IsEnrollment = 1
					THEN 'False'
				WHEN IsAdhoc = 0
					AND ISNULL(IsProgramTask, 0) = 1
					THEN 'False'
				WHEN IsAdhoc = 1
					THEN 'True'
				WHEN ISNULL(IsAdhoc, 0) = 0
					AND ISNULL(IsProgramTask, 0) = 0
					THEN 'True'
				ELSE NULL
				END AS IsAdhoc
			,t.Comments
			,NULL CommunicationTemplateID
			,NULL TemplateName
			,t.TaskCompletedDate
			,t.PatientId PatientUserId
			,t.PatientTaskID GeneralizedID
			,t.TotalRemainderCount TotalFutureTasks
			,0 DaysLate
			,NULL RemainderNextContactedDate
			,CASE WHEN P.ADTType IS NOT NULL THEN [dbo].[ufn_PatientADTstatus](t.PatientID, p.ADTtype) ELSE NULL END AS ADTStatus
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'AdmitDate',t.PatientADTId) 
								  ELSE NULL
							 END AS AdmitDate,
		CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'Facility',t.PatientADTId) 
								  ELSE NULL
							 END AS FacilityName					 
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'LastDischargedate',t.PatientADTId) 
								  ELSE NULL
							 END AS LastDischargeDate
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'LastFacility',t.PatientADTId) 
								  ELSE NULL
							 END AS LastFacilityName		
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'NoOfDays',t.PatientADTId) 
								  ELSE NULL
							 END AS NumberOfDays	
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'Dischargedate',t.PatientADTId) 
								  ELSE NULL
							 END AS DischargeDate
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'Facility',t.PatientADTId) 
								  ELSE NULL
							 END AS DisChargeFacilityName		
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'DischargedTo',t.PatientADTId) 
								  ELSE NULL
							 END AS DischargedTo
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'AdmitDate',t.PatientADTId) 
								  ELSE NULL
							 END AS DisChargeAdmitDate
		,CASE WHEN p.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](t.PatientID, 'InPatientDays',t.PatientADTId) 
								  ELSE NULL
							 END AS InpatientDays
		FROM Task t WITH (NOLOCK)
		INNER JOIN #Program p
			ON t.ProgramID = p.ProgramID
		--INNER JOIN #tblCareTeamMember ctm
		--	ON ctm.ProviderID = t.AssignedCareProviderId
		INNER JOIN TaskType ty WITH (NOLOCK)
			ON t.TaskTypeId = ty.TaskTypeId
		INNER JOIN @tTaskRights ty1
			ON ty1.TaskTypeID = ty.TaskTypeId
		INNER JOIN TaskStatus ts WITH (NOLOCK)
			ON ts.TaskStatusId = t.TaskStatusId
		WHERE ts.TaskStatusText = 'Closed Complete'
			AND CONVERT(DATE, t.TaskCompletedDate) >= CONVERT(DATE, GETDATE())
			AND t.PatientId = @i_PatientUserID
			AND t.TotalRemainderCount IS NOT NULL
		)
	SELECT *
	INTO #tblTaskSortOrder
	FROM cteTask
	ORDER BY DaysLate DESC

	--SELECT * FROM #tblTaskSortOrder  
	IF (@i_IsShortList IS NULL)
	BEGIN
		SELECT DaysLate
			,TaskId
			,TasktypeId
			,TaskTypeName
			,DateDue
			,NextCommunicationType
			,CASE 
				WHEN ISNULL(TotalFutureTasks, 0) = ISNULL(Attempts, 0)
					THEN ISNULL(Attempts, 0)
				ELSE ISNULL(Attempts, 0) + 1
				END Attempts
			,CommunicationTemplateID
			,CommunicationAttemptedDays
			,NoOfDaysBeforeTaskClosedIncomplete
			,TaskTypeCommunicationID
			,CommunicationSequence
			,CommunicationTyepID
			,CASE 
				WHEN TaskTerminationDate IS NOT NULL
					THEN NULL
				ELSE NextContactedDate
				END NextContactedDate
			,TaskTerminationDate
			,TypeID
			,TypeName
			,IsCareGap
			,IsAdhoc
			,Comments
			,TemplateName
			,TaskCompletedDate
			,PatientUserID
			,GeneralizedID
			,ISNULL(TotalFutureTasks, 0) TotalFutureTasks
			,RemainderNextContactedDate
			,CASE 
				WHEN LEN(TemplateName) > 10
					THEN SUBSTRING(TemplateName, 1, 8) + '...'
				ELSE TemplateName
				END TemplateShortName
			,CASE 
				WHEN LEN(TaskTypeName) > 20
					THEN SUBSTRING(TaskTypeName, 1, 20) + '...'
				ELSE TaskTypeName
				END TaskTypeShortName
				,ADTStatus
				,AdmitDate
				,FacilityName
				,LastDischargeDate
				,LastFacilityName
				,NumberOfDays
				,DischargeDate
				,DisChargeFacilityName
				,DischargedTo
				,DisChargeAdmitDate
				,InpatientDays
		FROM #tblTaskSortOrder
		WHERE TaskId = @i_TaskID
		
		UNION ALL
		
		SELECT DaysLate
			,TaskId
			,TasktypeId
			,TaskTypeName
			,DateDue
			,NextCommunicationType
			,CASE 
				WHEN ISNULL(TotalFutureTasks, 0) = ISNULL(Attempts, 0)
					THEN ISNULL(Attempts, 0)
				ELSE ISNULL(Attempts, 0) + 1
				END Attempts
			,CommunicationTemplateID
			,CommunicationAttemptedDays
			,NoOfDaysBeforeTaskClosedIncomplete
			,TaskTypeCommunicationID
			,CommunicationSequence
			,CommunicationTyepID
			,CASE 
				WHEN TaskTerminationDate IS NOT NULL
					THEN NULL
				ELSE NextContactedDate
				END NextContactedDate
			,TaskTerminationDate
			,TypeID
			,TypeName
			,IsCareGap
			,IsAdhoc
			,Comments
			,TemplateName
			,TaskCompletedDate
			,PatientUserID
			,GeneralizedID
			,ISNULL(TotalFutureTasks, 0) TotalFutureTasks
			,RemainderNextContactedDate
			,CASE 
				WHEN LEN(TemplateName) > 10
					THEN SUBSTRING(TemplateName, 1, 8) + '...'
				ELSE TemplateName
				END TemplateShortName
			,CASE 
				WHEN LEN(TaskTypeName) > 20
					THEN SUBSTRING(TaskTypeName, 1, 20) + '...'
				ELSE TaskTypeName
				END TaskTypeShortName
				,ADTStatus
					,AdmitDate
				,FacilityName
				,LastDischargeDate
				,LastFacilityName
				,NumberOfDays
				,DischargeDate
				,DisChargeFacilityName
				,DischargedTo
				,DisChargeAdmitDate
				,InpatientDays
		FROM #tblTaskSortOrder
		WHERE (
				TaskId <> @i_TaskID
				OR @i_TaskID IS NULL
				)
			AND DaysLate = 0
		
		UNION ALL
		
		SELECT DaysLate
			,TaskId
			,TasktypeId
			,TaskTypeName
			,DateDue
			,NextCommunicationType
			,CASE 
				WHEN ISNULL(TotalFutureTasks, 0) = ISNULL(Attempts, 0)
					THEN ISNULL(Attempts, 0)
				ELSE ISNULL(Attempts, 0) + 1
				END Attempts
			,CommunicationTemplateID
			,CommunicationAttemptedDays
			,NoOfDaysBeforeTaskClosedIncomplete
			,TaskTypeCommunicationID
			,CommunicationSequence
			,CommunicationTyepID
			,CASE 
				WHEN TaskTerminationDate IS NOT NULL
					THEN NULL
				ELSE NextContactedDate
				END NextContactedDate
			,TaskTerminationDate
			,TypeID
			,TypeName
			,IsCareGap
			,IsAdhoc
			,Comments
			,TemplateName
			,TaskCompletedDate
			,PatientUserID
			,GeneralizedID
			,ISNULL(TotalFutureTasks, 0) TotalFutureTasks
			,RemainderNextContactedDate
			,CASE 
				WHEN LEN(TemplateName) > 10
					THEN SUBSTRING(TemplateName, 1, 8) + '...'
				ELSE TemplateName
				END TemplateShortName
			,CASE 
				WHEN LEN(TaskTypeName) > 20
					THEN SUBSTRING(TaskTypeName, 1, 20) + '...'
				ELSE TaskTypeName
				END TaskTypeShortName
				,ADTStatus
				,AdmitDate
				,FacilityName
				,LastDischargeDate
				,LastFacilityName
				,NumberOfDays
				,DischargeDate
				,DisChargeFacilityName
				,DischargedTo
				,DisChargeAdmitDate
				,InpatientDays
		FROM #tblTaskSortOrder
		WHERE (
				TaskId <> @i_TaskID
				OR @i_TaskID IS NULL
				)
			AND DaysLate <> 0
	END
	ELSE
	BEGIN
		SELECT TOP 5 *
		FROM (
			SELECT DaysLate
				,TaskId
				,TasktypeId
				,TaskTypeName
				,DateDue
				,NextCommunicationType
				,CASE 
					WHEN ISNULL(TotalFutureTasks, 0) = ISNULL(Attempts, 0)
						THEN ISNULL(Attempts, 0)
					ELSE ISNULL(Attempts, 0) + 1
					END Attempts
				,CommunicationTemplateID
				,CommunicationAttemptedDays
				,NoOfDaysBeforeTaskClosedIncomplete
				,TaskTypeCommunicationID
				,CommunicationSequence
				,CommunicationTyepID
				,CASE 
					WHEN TaskTerminationDate IS NOT NULL
						THEN NULL
					ELSE NextContactedDate
					END NextContactedDate
				,TaskTerminationDate
				,TypeID
				,TypeName
				,IsCareGap
				,IsAdhoc
				,Comments
				,TemplateName
				,TaskCompletedDate
				,PatientUserID
				,GeneralizedID
				,ISNULL(TotalFutureTasks, 0) TotalFutureTasks
				,RemainderNextContactedDate
				,CASE 
					WHEN LEN(TemplateName) > 10
						THEN SUBSTRING(TemplateName, 1, 8) + '...'
					ELSE TemplateName
					END TemplateShortName
				,CASE 
					WHEN LEN(TaskTypeName) > 20
						THEN SUBSTRING(TaskTypeName, 1, 20) + '...'
					ELSE TaskTypeName
					END TaskTypeShortName
					,ADTStatus
					,AdmitDate
				,FacilityName
				,LastDischargeDate
				,LastFacilityName
				,NumberOfDays
				,DischargeDate
				,DisChargeFacilityName
				,DischargedTo
				,DisChargeAdmitDate
				,InpatientDays
			FROM #tblTaskSortOrder
			WHERE TaskId = @i_TaskID
			
			UNION ALL
			
			SELECT DaysLate
				,TaskId
				,TasktypeId
				,TaskTypeName
				,DateDue
				,NextCommunicationType
				,CASE 
					WHEN ISNULL(TotalFutureTasks, 0) = ISNULL(Attempts, 0)
						THEN ISNULL(Attempts, 0)
					ELSE ISNULL(Attempts, 0) + 1
					END Attempts
				,CommunicationTemplateID
				,CommunicationAttemptedDays
				,NoOfDaysBeforeTaskClosedIncomplete
				,TaskTypeCommunicationID
				,CommunicationSequence
				,CommunicationTyepID
				,CASE 
					WHEN TaskTerminationDate IS NOT NULL
						THEN NULL
					ELSE NextContactedDate
					END NextContactedDate
				,TaskTerminationDate
				,TypeID
				,TypeName
				,IsCareGap
				,IsAdhoc
				,Comments
				,TemplateName
				,TaskCompletedDate
				,PatientUserID
				,GeneralizedID
				,ISNULL(TotalFutureTasks, 0) TotalFutureTasks
				,RemainderNextContactedDate
				,CASE 
					WHEN LEN(TemplateName) > 10
						THEN SUBSTRING(TemplateName, 1, 8) + '...'
					ELSE TemplateName
					END TemplateShortName
				,CASE 
					WHEN LEN(TaskTypeName) > 20
						THEN SUBSTRING(TaskTypeName, 1, 20) + '...'
					ELSE TaskTypeName
					END TaskTypeShortName
					,ADTStatus
						,AdmitDate
				,FacilityName
				,LastDischargeDate
				,LastFacilityName
				,NumberOfDays
				,DischargeDate
				,DisChargeFacilityName
				,DischargedTo
				,DisChargeAdmitDate
				,InpatientDays
			FROM #tblTaskSortOrder
			WHERE (
					TaskId <> @i_TaskID
					OR @i_TaskID IS NULL
					)
				AND DaysLate = 0
			
			UNION ALL
			
			SELECT DaysLate
				,TaskId
				,TasktypeId
				,TaskTypeName
				,DateDue
				,NextCommunicationType
				,CASE 
					WHEN ISNULL(TotalFutureTasks, 0) = ISNULL(Attempts, 0)
						THEN ISNULL(Attempts, 0)
					ELSE ISNULL(Attempts, 0) + 1
					END Attempts
				,CommunicationTemplateID
				,CommunicationAttemptedDays
				,NoOfDaysBeforeTaskClosedIncomplete
				,TaskTypeCommunicationID
				,CommunicationSequence
				,CommunicationTyepID
				,CASE 
					WHEN TaskTerminationDate IS NOT NULL
						THEN NULL
					ELSE NextContactedDate
					END NextContactedDate
				,TaskTerminationDate
				,TypeID
				,TypeName
				,IsCareGap
				,IsAdhoc
				,Comments
				,TemplateName
				,TaskCompletedDate
				,PatientUserID
				,GeneralizedID
				,ISNULL(TotalFutureTasks, 0) TotalFutureTasks
				,RemainderNextContactedDate
				,CASE 
					WHEN LEN(TemplateName) > 10
						THEN SUBSTRING(TemplateName, 1, 8) + '...'
					ELSE TemplateName
					END TemplateShortName
				,CASE 
					WHEN LEN(TaskTypeName) > 20
						THEN SUBSTRING(TaskTypeName, 1, 20) + '...'
					ELSE TaskTypeName
					END TaskTypeShortName
					,ADTStatus
						,AdmitDate
				,FacilityName
				,LastDischargeDate
				,LastFacilityName
				,NumberOfDays
				,DischargeDate
				,DisChargeFacilityName
				,DischargedTo
				,DisChargeAdmitDate
				,InpatientDays
			FROM #tblTaskSortOrder
			WHERE (
					TaskId <> @i_TaskID
					OR @i_TaskID IS NULL
					)
				AND DaysLate <> 0
			) AS uniontable
	END

	SELECT COUNT(TaskId) AS PendingForClaims
	FROM Task
	INNER JOIN #Program tp
		ON TASK.ProgramID = TP.ProgramID
	INNER JOIN TaskStatus
		ON TaskStatus.TaskStatusId = Task.TaskStatusId
	WHERE TaskStatus.TaskStatusText = 'Pending For Claims'
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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyTasksByPatientID] TO [FE_rohit.r-ext]
    AS [dbo];

