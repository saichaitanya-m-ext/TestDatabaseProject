
/*             
------------------------------------------------------------------------------              
Procedure Name: usp_CareProviderDashBoard_MyTasksByPatientID  23,226585,NULL,23  
Description   : This procedure is used to get the open tasks select by patientID         
Created By    : Komala             
Created Date  : 28-Oct-2010              
------------------------------------------------------------------------------              
Log History   :               
DD-MM-YYYY  BY   DESCRIPTION   
08-Jan-2012 Nagababu Added @t_DueDate as Input parameter and implemented the functionality  
22-Feb-2013 Rathnam added #tblCareTeamMember temp table and join for getting the related provider tasks    
23-APR-2013 prathyusha modified the SP for filter the patients by TaskName.  
25-July-2013 Rathnam removed the condition and placed the program name  
20-August-2013 Santosh Converted the datetime columns TaskDueDate,MissedOppertunityDates to date
20-02-2014 Rathnam commented the assigned careprovider functionality as we need to get the tasks based on tasktypes 
------------------------------------------------------------------------------   
[usp_CareProviderDashBoard_MissedOpprtunityByPatientID]  
*/
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MissedOpportunityByPatientID] (
	@i_AppUserId KEYID,
	@i_PatientUserID KEYID,
	@t_ProgramID TTYPEKEYID READONLY,
	@t_TaskTypeID TTYPEKEYID READONLY --> Displays the list of Task types based on login user task rights  
	,
	@t_PCPID TTYPEKEYID READONLY --> PCP information   
	,
	@i_ReminderValue INT = NULL,
	@t_tblTaskTypeIDAndTypeID TBLTASKTYPEANDTYPEID READONLY --,@t_TaskName TTYPEKEYID READONLY  
	,
	@t_CareTeamMemberId TTYPEKEYID READONLY
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	-- Check if valid Application User ID is passed          
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.',
				17,
				1,
				@i_AppUserId
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
	CREATE TABLE #TotalMissedOpprtunities (
		TaskID INT,
		PatientID INT,
		ProgramID INT
		)

	CREATE TABLE #Program (ProgramID INT)

	INSERT INTO #Program
	SELECT tKeyId
	FROM @t_ProgramID

	CREATE TABLE #TaskType (TaskTypeID INT)

	INSERT INTO #TaskType
	SELECT tKeyId
	FROM @t_TaskTypeID

	DECLARE @v_Select VARCHAR(MAX) = '',
		@v_WhereClause VARCHAR(MAX) = '',
		@v_JoinClause VARCHAR(MAX) = '',
		@v_SQL VARCHAR(MAX) = ''

	SET @v_WhereClause = ' WHERE ts.TaskStatusText = ''Closed Incomplete''  AND t.PatientID = ' + CONVERT(VARCHAR(20), @i_PatientUserID)

	IF @i_ReminderValue IS NOT NULL
	BEGIN
		SET @i_ReminderValue = REPLACE(@i_ReminderValue, '-', '')
		SET @v_WhereClause = @v_WhereClause + ' AND DATEDIFF(DD,  DATEADD(DD , t.TerminationDays , t.TaskDueDate),GETDATE()) BETWEEN 0 AND ' + CONVERT(VARCHAR(10), @i_ReminderValue)
	END

	SET @v_Select = ' INSERT INTO #TotalMissedOpprtunities  
          SELECT  
              t.taskid  
              ,t.PatientID  
              ,t.ProgramID  
             
          FROM  
              Task t WITH(NOLOCK)  
          INNER JOIN #Program pr  
              ON t.ProgramID = pr.ProgramID  
          INNER JOIN #TaskType ty  
              ON ty.TaskTypeID = t.TaskTypeId                 INNER JOIN TaskStatus ts WITH(NOLOCK)  
              ON ts.TaskStatusId = t.TaskStatusId   
          
              '

	IF EXISTS (
			SELECT 1
			FROM @t_PCPID
			)
	BEGIN
		CREATE TABLE #PCP (PCPID INT)

		INSERT INTO #PCP
		SELECT tKeyId
		FROM @t_PCPID

		SET @v_JoinClause = '
						INNER JOIN PatientPCP pcp  WITH(NOLOCK)
                          ON pcp.PatientID = t.PatientID
                          INNER JOIN #PCP   
                               ON #PCP.PCPID = pcp.ProviderID 
       '
	END

	IF EXISTS (
			SELECT 1
			FROM @t_tblTaskTypeIDAndTypeID
			)
	BEGIN
		SELECT ttt.TaskTypeID,
			ttt.TypeID
		INTO #tblTaskTypeIDAndTypeID
		FROM @t_tblTaskTypeIDAndTypeID ttt

		SET @v_JoinClause = @v_JoinClause + ' INNER JOIN #tblTaskTypeIDAndTypeID    
                               ON #tblTaskTypeIDAndTypeID.TaskTypeID = ty.TaskTypeID    
                               AND #tblTaskTypeIDAndTypeID.TypeID = t.TypeID    
                               '
	END

	SET @v_SQL = @v_Select + ISNULL(@v_JoinClause, '') + ISNULL(@v_WhereClause, '')

	PRINT @v_SQL

	EXEC (@v_SQL)

	SELECT t.TaskId,
		p.ProgramName,
		TaskTypeName AS TaskType,
		ISNULL(dbo.ufn_GetTypeNamesByTypeId(ty.TaskTypeName, t5.TypeID), t5.ManualTaskName) AS TaskName,
		CONVERT(VARCHAR(20), CAST(t5.TaskDuedate AS DATE), 101) AS TaskDueDate,
		CASE 
			WHEN ISNULL(t5.TerminationDays, 0) <> 0
				THEN CONVERT(VARCHAR(20), (DATEADD(DAY, t5.TerminationDays, CAST(t5.TaskDueDate AS DATE))), 101)
					--CAST(DATEADD(Day , t5.TerminationDays ,CAST(CONVERT(DATE,t5.TaskDueDate,101)AS VARCHAR(20)) ) AS VARCHAR(20))
			ELSE CONVERT(VARCHAR(20), cast(t5.TaskDuedate AS DATE), 101)
			END MissedOpprunityDate
	FROM #TotalMissedOpprtunities t
	INNER JOIN Program p WITH (NOLOCK) ON p.ProgramId = t.ProgramID
	INNER JOIN Task t5 ON t5.TaskId = t.TaskID
	INNER JOIN TaskType ty WITH (NOLOCK) ON ty.TaskTypeId = t5.TaskTypeId
	ORDER BY t5.TaskDuedate DESC
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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MissedOpportunityByPatientID] TO [FE_rohit.r-ext]
    AS [dbo];

