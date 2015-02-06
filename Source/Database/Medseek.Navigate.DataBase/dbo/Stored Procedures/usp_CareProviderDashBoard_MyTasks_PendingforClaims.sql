
/*          
--------------------------------------------------------------------------------------------------------------          
Procedure Name: [dbo].[usp_CareProviderDashBoard_MyTasks_PendingforClaims]23,11,20  
Description   : This procedure is to get the recent tasks by patientid to the respective careteammembers     
Created By    : Rathnam       
Created Date  : 14-Nov-2012    
---------------------------------------------------------------------------------------------------------------          
Log History   :           
DD-Mon-YYYY  BY  DESCRIPTION   
20-02-2014 Rathnam commented the assigned careprovider functionality as we need to get the tasks based on tasktypes
----------------------------------------------------------------------------------------------------------------      
 */
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyTasks_PendingforClaims] (
	@i_AppUserId KEYID
	,@i_StartRowIndex INT = 1 --> RowStart Index  
	,@i_EndRowIndex INT = 10 --> End Row Index  
	,@i_RemainderCount INT = NULL --> Not using this parameter
	,@t_ProgramList TTYPEKEYID READONLY --> Managed Population which are mapped from the managed population screen to the particular careteam  
	--,@t_MeasureRangeList TYPEIDANDNAME READONLY --> Measures List based on Program Filter  
	,@v_Duedate VARCHAR(5) = NULL --> Not Using  
	,@t_TaskTypeID TTYPEKEYID READONLY --> Displays the list of Task types based on login user task rights  
	,@t_PCPID TTYPEKEYID READONLY --> PCP information   
	,@t_tblTaskTypeIDAndTypeID TBLTASKTYPEANDTYPEID READONLY --> it will vary the data based on tasktype  
	,@t_CareTeamMemberId TTYPEKEYID READONLY
	,@b_IsAdhoc BIT = 0 --> Adhoc tasks filter purpose  
	,@b_IsCareGap BIT = 0 --> Caregap tasks for filter purpose  
	,@v_SortBy VARCHAR(50) = NULL --> custom sorting the data from the application   
	,@v_SortType VARCHAR(5) = NULL --> ASC, DESC  
	,@tblFilter FILTER READONLY --> Custom filter from the application like Contains, equalto etc..  
	,@v_TaskStatus VARCHAR(1) = NULL --> This for filtering the This weeks task, This month tasks, Complete today tasks. 'O'-- Open Tasks, 'C'-- Complete Tasks  
	,@i_ReminderValue INT = NULL --> This for filtering the This weeks task, This month tasks, Complete today tasks. 'O'-- Open Tasks, 'C'-- Complete Tasks from the TaskDuedate table  
	,@i_PatientUserID INT = NULL --> This is for filtering the completed tasks when user hit the drill down in the application
	,@vc_ADTStatus VARCHAR(20) = NULL  --> Discharge,ReAdmission,Admit
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
	
	
	/*
	CREATE TABLE #tblCareTeamMember (ProviderID INT)

	IF NOT EXISTS (
			SELECT 1
			FROM @t_CareTeamMemberId
			)
	BEGIN
		INSERT INTO #tblCareTeamMember
		SELECT @i_AppUserId
	END
	ELSE
	BEGIN
		INSERT INTO #tblCareTeamMember
		SELECT tKeyId
		FROM @t_CareTeamMemberId
	END
*/
CREATE TABLE #Program (
		ProgramID INT
		,ProgramName VARCHAR(200)
		,ADTtype VARCHAR(1)
		)

	IF @vc_ADTStatus IS NOT NULL
	BEGIN
		INSERT INTO #Program
		SELECT p.ProgramId
			,p.ProgramName
			,pd.ADTtype
		FROM @t_ProgramList tp
		INNER JOIN Program p
			ON tp.tKeyId = p.ProgramId
		INNER JOIN PopulationDefinition pd
			ON pd.PopulationDefinitionID = p.PopulationDefinitionID
		WHERE pd.IsADT = 1
			AND ((pd.ADTtype = 
					  CASE 
						WHEN @vc_ADTStatus = 'Discharge' THEN 'D'
						WHEN @vc_ADTStatus IN ('Admit','ReAdmission') THEN 'A'
					  END
					AND @vc_ADTStatus <> 'OnlyADT'
				 )
				 OR (
					pd.ADTtype IN ('D','A')AND @vc_ADTStatus = 'OnlyADT'
					)
				)
	END
	ELSE
	BEGIN
		INSERT INTO #Program
		SELECT p.ProgramId
			,p.ProgramName
			,pd.ADTtype
		FROM @t_ProgramList tp
		INNER JOIN Program p
			ON tp.tKeyId = p.ProgramId
		INNER JOIN PopulationDefinition pd
			ON pd.PopulationDefinitionID = p.PopulationDefinitionID	
	END


	CREATE TABLE #tblTaskTypeID (TaskTypeID INT)

	INSERT INTO #tblTaskTypeID
	SELECT tKeyId TaskTypeID
	FROM @t_TaskTypeID t
	INNER JOIN TaskType ty WITH (NOLOCK) ON t.tKeyId = ty.TaskTypeId
	WHERE ty.TaskTypeName = 'Schedule Procedure'

	CREATE TABLE #tblTask (
		ID INT IDENTITY(1, 1)
		,PatientId INT
		,TaskID INT
		)

	DECLARE @v_SQL VARCHAR(MAX)
		,@v_WhereClause VARCHAR(MAX) = ' WHERE ts.TaskStatusText IN ( ''Pending For Claims'') '
		,@v_JoinClause VARCHAR(MAX) = ''
	DECLARE @i_PCPCnt INT
		,@i_Customfilter INT

	SELECT @i_PCPCnt = 1
	FROM @t_PCPID

	SELECT @i_Customfilter = 1
	FROM @tblFilter

	IF @i_PCPCnt IS NOT NULL
		OR @i_Customfilter IS NOT NULL
		OR @v_SortBy IS NOT NULL
	BEGIN
		SET @v_SQL = '  
						  INSERT INTO #tblTask  
						  SELECT   
							   p.PatientId  
								 ,t.TaskID  
						   FROM   
						   Task t WITH(NOLOCK)  
						  INNER JOIN Patients p  WITH ( NOLOCK )
									 ON p.PatientId = t.PatientId  
								 INNER JOIN #Program pm  
						   ON pm.ProgramID = t.ProgramID       
						  INNER JOIN TaskStatus ts WITH(NOLOCK)  
						   ON ts.TaskStatusId = t.TaskStatusId  
						  INNER JOIN #tblTaskTypeID ty1  
						   ON ty1.TaskTypeID = t.TaskTypeId 
						 
					   '
	END
	ELSE
	BEGIN
		SET @v_SQL = '  
						  INSERT INTO #tblTask  
						  SELECT   
							   t.PatientId  
								 ,t.TaskID  
						  FROM   
						   Task t WITH(NOLOCK) 
						   INNER JOIN Patients p  WITH ( NOLOCK )
									 ON p.PatientId = t.PatientId   
							INNER JOIN #Program pm  
						   ON pm.ProgramID = t.ProgramID       
						  INNER JOIN TaskStatus ts WITH(NOLOCK)  
						   ON ts.TaskStatusId = t.TaskStatusId  
						  INNER JOIN #tblTaskTypeID ty1  
						   ON ty1.TaskTypeID = t.TaskTypeId 
						 
					   '
	END

	IF @i_PCPCnt IS NOT NULL
	BEGIN
		SELECT tKeyId PCPID
		INTO #PCPID
		FROM @t_PCPID pcp

		SET @v_JoinClause = @v_JoinClause + '    
                         INNER JOIN PatientPCP pcp  WITH(NOLOCK)
                          ON pcp.PatientID = t.PatientID
                          INNER JOIN #PCPID    
                               ON #PCPID.PCPID = pcp.ProviderID    '
	END

	IF EXISTS (
			SELECT 1
			FROM @t_tblTaskTypeIDAndTypeID
			)
	BEGIN
		SELECT ttt.TaskTypeID
			,ttt.TypeID
		INTO #tblTaskTypeIDAndTypeID
		FROM @t_tblTaskTypeIDAndTypeID ttt

		SET @v_JoinClause = @v_JoinClause + ' INNER JOIN #tblTaskTypeIDAndTypeID  
                               ON #tblTaskTypeIDAndTypeID.TaskTypeID = ty1.TaskTypeID  
                               AND #tblTaskTypeIDAndTypeID.TypeID = t.TypeID  
                               '
	END

	
	IF @b_IsAdhoc = 1
	BEGIN
		SET @v_WhereClause = @v_WhereClause + ' AND (ISNULL(t.Isadhoc,0) = 1 OR (ISNULL(t.IsEnrollment,0)=0 AND ISNULL(t.Isadhoc,0) = 0 AND ISNULL(t.IsProgramTask,0) = 0))'
	END

	IF @b_IsCareGap = 1
	BEGIN
		SET @v_WhereClause = @v_WhereClause + ' AND t.IsCareGap = 1 '
	END

	IF @i_PatientUserID IS NOT NULL
	BEGIN
		SET @v_WhereClause = @v_WhereClause + ' AND t.PatientID  = ' + CONVERT(VARCHAR(20), @i_PatientUserID)
	END

	IF @i_Customfilter IS NOT NULL --> Custom filter in the application Grid  
	BEGIN
		DECLARE @v_MemberNum VARCHAR(15)
			,@v_FullName VARCHAR(50)
			,@v_PhoneNumberPrimary VARCHAR(10)
			,@v_CallTimePreference VARCHAR(50)
			,@v_Age VARCHAR(3)
			,@v_Sex VARCHAR(3)
			,@v_TaskDueDate VARCHAR(20)
			,@v_TaskTypeName VARCHAR(100)
			,@v_ProgramName VARCHAR(100)
			,@v_PcpName VARCHAR(100)
			,@v_TypeName VARCHAR(100)

		SELECT @v_MemberNum = FilterValue
		FROM @tblFilter
		WHERE ColumnName = 'MemberNum'
			AND Sno = 1

		SELECT @v_FullName = FilterValue
		FROM @tblFilter
		WHERE ColumnName = 'FullName'
			AND Sno = 1

		SELECT @v_PhoneNumberPrimary = FilterValue
		FROM @tblFilter
		WHERE ColumnName = 'PhoneNumberPrimary'
			AND Sno = 1

		SELECT @v_CallTimePreference = FilterValue
		FROM @tblFilter
		WHERE ColumnName = 'CallTimePreference'
			AND Sno = 1

		SELECT @v_Age = FilterValue
		FROM @tblFilter
		WHERE ColumnName = 'Age'
			AND Sno = 1

		SELECT @v_Sex = FilterValue
		FROM @tblFilter
		WHERE ColumnName = 'Gender'
			AND Sno = 1

		SELECT @v_TaskDueDate = FilterValue
		FROM @tblFilter
		WHERE ColumnName = 'TaskDueDate'
			AND Sno = 1

		SELECT @v_TaskTypeName = FilterValue
		FROM @tblFilter
		WHERE ColumnName = 'TaskTypeName'
			AND Sno = 1

		SELECT @v_ProgramName = FilterValue
		FROM @tblFilter
		WHERE ColumnName = 'programname'
			AND Sno = 1

		SELECT @v_PcpName = FilterValue
		FROM @tblFilter
		WHERE ColumnName = 'PCPName'
			AND Sno = 1

		SELECT @v_TypeName = FilterValue
		FROM @tblFilter
		WHERE ColumnName = 'TypeName'
			AND Sno = 1

		IF @v_MemberNum <> ''
		BEGIN
			SET @v_WhereClause = @v_WhereClause + ' AND (p.MemberNum LIKE ''%' + @v_MemberNum + '%'') '
		END

		IF @v_FullName <> ''
		BEGIN
			SET @v_WhereClause = @v_WhereClause + ' AND (p.FullName LIKE ''%' + @v_FullName + '%'') '
		END

		IF @v_PhoneNumberPrimary <> ''
		BEGIN
			SET @v_WhereClause = @v_WhereClause + ' AND (p.PhoneNumberPrimary LIKE ''%' + @v_PhoneNumberPrimary + '%'') '
		END

		IF @v_CallTimePreference <> ''
		BEGIN
			SET @v_JoinClause = @v_JoinClause + ' INNER JOIN CallTimePreference ctp WITH(NOLOCK)  
																ON ctp.CallTimePreferenceId = p.CallTimePreferenceId '
			SET @v_WhereClause = @v_WhereClause + ' AND (ctp.CallTimeName LIKE ''%' + @v_CallTimePreference + '%'') '
		END

		IF @v_Age <> ''
			AND ISNUMERIC(@v_Age) = 1
		BEGIN
			SET @v_WhereClause = @v_WhereClause + ' AND (p.Age = ''' + @v_Age + ''') '
		END

		IF @v_Sex <> ''
		BEGIN
			SET @v_WhereClause = @v_WhereClause + ' AND (p.Gender = ''' + @v_Sex + ''') '
		END

		IF @v_TaskDueDate <> ''
			AND ISDATE(@v_TaskDueDate) = 1
		BEGIN
			SET @v_WhereClause = @v_WhereClause + ' AND (t.TaskDueDate = ' + @v_TaskDueDate + ') '
		END

		IF @v_TaskTypeName <> ''
		BEGIN
			SET @v_JoinClause = @v_JoinClause + ' INNER JOIN TaskType te WITH(NOLOCK)  
                ON te.TaskTypeID = t.TaskTypeID '
			SET @v_WhereClause = @v_WhereClause + ' AND (te.TaskTypeName LIKE %''' + @v_TaskTypeName + '%'') '
		END

		IF @v_TypeName <> ''
		BEGIN
			SET @v_JoinClause = @v_JoinClause + ' INNER JOIN TaskType te WITH(NOLOCK)  
                ON te.TaskTypeID = t.TaskTypeID '
			SET @v_WhereClause = @v_WhereClause + ' AND (dbo.ufn_GetTypeNamesByTypeId(te.TaskTypeName , t.TypeID) LIKE %' + @v_TypeName + '%) '
		END

		IF @v_ProgramName <> ''
		BEGIN
			SET @v_WhereClause = @v_WhereClause + ' AND (pm.ProgramName LIKE %''' + @v_ProgramName + '%'') '
		END

		IF @v_PcpName <> ''
		BEGIN
			SET @v_WhereClause = @v_WhereClause + ' AND ([dbo].[ufn_GetPCPName](p.PatientID) LIKE %''' + @v_PcpName + '%'') '
		END
		
		IF @vc_ADTStatus = 'ReAdmission'
		BEGIN
			SET @v_JoinClause = @v_JoinClause + ' INNER JOIN PatientADT padt WITH(NOLOCK)    
                ON padt.PatientID = t.PatientID  ' 
			SET @v_WhereClause = @v_WhereClause + ' AND COALESCE(EventDischargedate,MessageDischargedate,VisitDischargedate) IS NOT NULL AND ISNULL(IsReadmit,0) = 1 ' 
		END
	END

	DECLARE @v_OrderByClause VARCHAR(4000) = ''

	IF @v_SortBy IS NOT NULL
	BEGIN
		IF @v_SortBy = 'MemberNum'
		BEGIN
			SET @v_OrderByClause = ' ORDER BY p.MemberNum ' + ISNULL(@v_SortType, '')
		END

		IF @v_SortBy = 'FullName'
		BEGIN
			SET @v_OrderByClause = ' ORDER BY p.FullName ' + ISNULL(@v_SortType, '')
		END

		IF @v_SortBy = 'PhoneNumberPrimary'
		BEGIN
			SET @v_OrderByClause = ' ORDER BY p.PrimaryPhoneNumber ' + ISNULL(@v_SortType, '')
		END

		IF @v_SortBy = 'Age'
		BEGIN
			SET @v_OrderByClause = ' ORDER BY p.Age ' + ISNULL(@v_SortType, '')
		END

		IF @v_SortBy = 'Gender'
		BEGIN
			SET @v_OrderByClause = ' ORDER BY p.Gender ' + ISNULL(@v_SortType, '')
		END

		IF @v_SortBy = 'TaskDueDate'
		BEGIN
			SET @v_OrderByClause = ' ORDER BY t.TaskDueDate ' + ISNULL(@v_SortType, '')
		END

		IF @v_SortBy = 'programname'
		BEGIN
			SET @v_OrderByClause = ' ORDER BY pm.programname ' + ISNULL(@v_SortType, '')
		END
	END
	ELSE
	BEGIN
		SET @v_OrderByClause = ' ORDER BY t.TaskCompletedDate DESC'
	END

	SET @v_SQL = @v_SQL + ISNULL(@v_JoinClause, '') + ISNULL(@v_WhereClause, '') + isnull(@v_OrderByClause, '')

	PRINT @v_SQL

	EXEC (@v_SQL)

	IF @i_PatientUserID IS NULL
	BEGIN
		

		CREATE TABLE #tblPriorityTasks (
			ID INT IDENTITY(1, 1)
			,TaskID INT
			,PatientId INT
			);

		WITH CTE (
			COl1
			,DuplicateCount
			)
		AS (
			SELECT PatientID
				,ROW_NUMBER() OVER (
					PARTITION BY PatientiD ORDER BY ID
					) AS DuplicateCount
			FROM #tblTask
			)
		DELETE
		FROM CTE
		WHERE DuplicateCount > 1

		INSERT INTO #tblPriorityTasks
		SELECT TaskId
			,PatientID
		FROM #tblTask t1
		ORDER BY ID ASC

		SELECT DISTINCT 4 AS SortID
			,'' DaysLate
			,t.TaskID
			,p.PatientID UserId
			,(SELECT COUNT(t.taskid)
						FROM Task t WITH (NOLOCK)
						INNER JOIN #Program pm
							ON pm.ProgramID = t.ProgramID
						INNER JOIN TaskStatus ts WITH (NOLOCK)
							ON ts.TaskStatusId = t.TaskStatusId
						INNER JOIN #tblTaskTypeID ty1
							ON ty1.TaskTypeID = t.TaskTypeId
						--INNER JOIN #tblCareTeamMember ctm
						--	ON ctm.ProviderID = t.AssignedCareProviderId
						WHERE t.PatientId = p.PatientID
							AND ts.TaskStatusId = 2) AS TaskCount
			 --added for time being as per dev
			,p.MemberNum
			,p.FullName
			,p.Age
			,p.Gender
			,p.CallTimeName CallTimePreference
			,p.PrimaryPhoneNumber PhoneNumber
			,t.TaskDueDate
			,CONVERT(VARCHAR, ISNULL(t.AttemptedRemainderCount, 0)) + '$$' + ISNULL(CONVERT(VARCHAR(10), t.LastAttemptDate, 101), '') AttemptsAndLastDate
			,'Schedule Procedure' TaskTypeName
			,'Schedule P...' TaskTypeShortName --Added by praveen for time beeing
			,0 IsCareGap
			,t.AssignedCareProviderID
			,dbo.ufn_GetUserNameByID(p.PCPId) PCPName
			,t.IsAdhoc
			,dbo.ufn_GetTypeNamesByTypeId('Schedule Procedure', t.TypeID) TypeName
			,'' AS CommunicationType
			,'' AttemptsDate
			,tp.ProgramName AssignmentName
			,CASE WHEN tp.ADTtype IS NOT NULL THEN CASE WHEN @vc_ADTStatus = 'ReAdmission' THEN [dbo].[ufn_PatientADTstatus](p.PatientID, tp.ADTtype) 
											    WHEN @vc_ADTStatus IS NULL AND tp.ADTtype = 'A' then 'Admit'
											    WHEN @vc_ADTStatus IS NULL AND tp.ADTtype = 'D' then 'Discharge'
											    ELSE @vc_ADTStatus  
										        END	    
						  ELSE NULL
					 END AS ADTStatus
			,CASE WHEN tp.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'AdmitDate',t.PatientADTId) 
						  ELSE NULL
					 END AS AdmitDate
			,CASE WHEN tp.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'Facility',t.PatientADTId) 
						  ELSE NULL
					 END AS FacilityName
			,CASE WHEN tp.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'LastDischargedate',t.PatientADTId) 
						  ELSE NULL
					 END AS LastDischargeDate
			,CASE WHEN tp.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'LastFacility',t.PatientADTId) 
						  ELSE NULL
					 END AS LastFacilityName
			,CASE WHEN tp.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'NoOfDays',t.PatientADTId) 
						  ELSE NULL
					 END AS NumberOfDays
			,CASE WHEN tp.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'Dischargedate',t.PatientADTId) 
						  ELSE NULL
					 END AS DischargeDate
			,CASE WHEN tp.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'Facility',t.PatientADTId) 
						  ELSE NULL
					 END AS DisChargeFacilityName
			,CASE WHEN tp.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'DischargedTo',t.PatientADTId) 
						  ELSE NULL
					 END AS DischargedTo
			,CASE WHEN tp.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'AdmitDate',t.PatientADTId) 
						  ELSE NULL
					 END AS DisChargeAdmitDate
			,CASE WHEN tp.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'InPatientDays',t.PatientADTId) 
						  ELSE NULL
					 END AS InpatientDays
		FROM Task t WITH (NOLOCK)
		INNER JOIN Patients p WITH (NOLOCK) ON p.PatientID = t.PatientID
		INNER JOIN #tblPriorityTasks TPT ON TPT.TaskID = T.TaskId
		INNER JOIN #Program tp ON tp.ProgramId = t.ProgramID
		WHERE ID BETWEEN @i_StartRowIndex
				AND @i_EndRowIndex
		--AND ([dbo].[ufn_PatientADTstatus](p.PatientID) = @vc_ADTStatus OR @vc_ADTStatus IS NULL	)	

		SELECT COUNT(TaskId) AS TotalCount
		FROM #tblPriorityTasks
		
	END
	ELSE
	BEGIN
		SELECT DISTINCT '' DaysLate
			,t.TaskId
			,0 AS TasktypeId
			,'Schedule Procedure' TaskTypeName
			,'Schedule P...' TaskTypeShortName --Added by praveen for time beeing
			,t.TaskDueDate DateDue
			,'' NextCommunicationType
			,CASE 
				WHEN ISNULL(TotalRemainderCount, 0) = ISNULL(t.AttemptedRemainderCount, 0)
					THEN ISNULL(t.AttemptedRemainderCount, 0)
				ELSE ISNULL(t.AttemptedRemainderCount, 0) + 1
				END Attempts
			,'' CommunicationTemplateID
			,'' CommunicationAttemptedDays
			,'' NoOfDaysBeforeTaskClosedIncomplete
			,'' TaskTypeCommunicationID
			,'' CommunicationSequence
			,'' CommunicationTyepID
			,'' NextContactedDate
			,'' TaskTerminationDate
			,t.TypeID
			,ISNULL(dbo.ufn_GetTypeNamesByTypeId('Schedule Procedure', t.TypeID), t.ManualTaskName) TypeName
			,'False' IsCareGap
			,CASE 
				WHEN isnull(t.IsEnrollment, 0) = 1
					THEN 0
				WHEN isnull(t.IsProgramTask, 0) = 1
					THEN 0
				WHEN isnull(t.IsAdhoc, 0) = 0
					AND ISNULL(t.IsProgramTask, 0) = 1
					THEN 0
				WHEN isnull(t.IsAdhoc, 0) = 1
					THEN 1
				WHEN ISNULL(t.IsAdhoc, 0) = 0
					AND ISNULL(t.IsProgramTask, 0) = 0
					THEN 1
				ELSE NULL
				END AS IsAdhoc
			,t.Comments
			,'' TemplateName
			,'' TemplateShortName --Added by praveen for time beeing
			,t.TaskCompletedDate
			,t.PatientID PatientUserID
			,'' GeneralizedID
			,ISNULL(TotalRemainderCount, 0) TotalFutureTasks
			,'' RemainderNextContactedDate 
			,CASE WHEN pg.ADTtype IS NOT NULL THEN CASE WHEN @vc_ADTStatus = 'ReAdmission' THEN [dbo].[ufn_PatientADTstatus](p.PatientID, pg.ADTtype) 
											    WHEN @vc_ADTStatus IS NULL AND pg.ADTtype = 'A' then 'Admit'
											    WHEN @vc_ADTStatus IS NULL AND pg.ADTtype = 'D' then 'Discharge'
											    ELSE @vc_ADTStatus  
										        END	    
						  ELSE NULL
					 END AS ADTStatus
			,CASE WHEN pg.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'AdmitDate',t.PatientADTId) 
						  ELSE NULL
					 END AS AdmitDate
			,CASE WHEN pg.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'Facility',t.PatientADTId) 
						  ELSE NULL
					 END AS FacilityName
			,CASE WHEN pg.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'LastDischargedate',t.PatientADTId) 
						  ELSE NULL
					 END AS LastDischargeDate
			,CASE WHEN pg.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'LastFacility',t.PatientADTId) 
						  ELSE NULL
					 END AS LastFacilityName
			,CASE WHEN pg.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'NoOfDays',t.PatientADTId) 
						  ELSE NULL
					 END AS NumberOfDays
			,CASE WHEN pg.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'Dischargedate',t.PatientADTId) 
						  ELSE NULL
					 END AS DischargeDate
			,CASE WHEN pg.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'Facility',t.PatientADTId) 
						  ELSE NULL
					 END AS DisChargeFacilityName
			,CASE WHEN pg.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'DischargedTo',t.PatientADTId) 
						  ELSE NULL
					 END AS DischargedTo
			,CASE WHEN pg.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'AdmitDate',t.PatientADTId) 
						  ELSE NULL
					 END AS DisChargeAdmitDate
			,CASE WHEN pg.ADTtype IS NOT NULL THEN [dbo].[ufn_PatientADTPopup](p.PatientID, 'InPatientDays',t.PatientADTId) 
						  ELSE NULL
					 END AS InpatientDays 
		FROM Task t WITH (NOLOCK)
		INNER JOIN #tblTask p WITH (NOLOCK) ON p.PatientID = t.PatientID
			AND t.TaskId = p.TaskID
		INNER JOIN #Program pg
			ON t.ProgramID = pg.ProgramID	
		--AND ([dbo].[ufn_PatientADTstatus](p.PatientID) = @vc_ADTStatus OR @vc_ADTStatus IS NULL	)		
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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyTasks_PendingforClaims] TO [FE_rohit.r-ext]
    AS [dbo];

