/*
-----------------------------------------------------------------------------------
Procedure Name: usp_CareProviderDashBoard_CareManagement_Temp @i_AppUserId=2,@v_TabName='ALL'
Description   : This procedure is going to be used for displaying data related to 
				Care management (Analytics 3 report)
Created By    : Rathnam
Created Date  : 18-Jan-2013
-----------------------------------------------------------------------------------     
Log History   :
DD-MM-YYYY  BY   DESCRIPTION
09/07/2013:Santosh Changed the name 'Program Enrollment' to 'Managed Population Enrollment'
31/7/2013:Santosh added the column Isenrollment in the resultset
05-Aug-2013 NagaBabu Modified percentages to show the taskstatus and taskattempts
22/08/2013:Santosh added the filter isenrollment
19-02-2014 Rathnam commented the assigned careprovider functionality as we need to get the tasks based on tasktypes
-----------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_CareManagement] (
	@i_AppUserId KEYID
	,@t_ProgramID TTYPEKEYID READONLY
	,@v_TabName VARCHAR(350)
	,@t_TaskTypeID TTYPEKEYID READONLY
	,@t_CareTeamMembers TTYPEKEYID READONLY
	,@t_PrimaryCarePhysician TTYPEKEYID READONLY
	,@t_tblTaskTypeIDAndTypeID TBLTASKTYPEANDTYPEID READONLY
	,@v_DueDate KEYID = NULL
	)
AS
BEGIN TRY
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
			FROM @t_CareTeamMembers
			)
	BEGIN
		INSERT INTO #tblCareTeamMember
		SELECT @i_AppUserId
	END
	ELSE
	BEGIN
		INSERT INTO #tblCareTeamMember
		SELECT DISTINCT tKeyId
		FROM @t_CareTeamMembers
	END
	*/
	CREATE TABLE #Program (ProgramID INT)

	INSERT INTO #Program
	SELECT DISTINCT tKeyId
	FROM @t_ProgramID

	CREATE TABLE #TaskType (TaskTypeID INT)

	INSERT INTO #TaskType
	SELECT tKeyId
	FROM @t_TaskTypeID
	
	CREATE TABLE #tblTask (
		TaskID INT
		,PatientUserID INT
		,TaskStatusText VARCHAR(50)
		,AttemptStatus INT
		,TypeID INT
		,TaskTypeName VARCHAR(150)
		,ISenrollment BIT
		,TaskTypeID INT
		)

	DECLARE @v_Select VARCHAR(MAX)
		,@v_WhereClause VARCHAR(MAX) = ''
		,@v_JoinClause VARCHAR(MAX) = ''
		,@v_SQL VARCHAR(MAX) = ''
		,@v_TabName1 VARCHAR(500)

	SET @v_TabName1 = @v_TabName

	IF @v_TabName = 'Managed Population Enrollment'
	BEGIN
		SET @v_TabName = ' (''Questionnaire'' , ''Communications'')  '
		SET @v_WhereClause = ' WHERE ty.TaskTypeName IN ' + @v_TabName + ''
		SET @v_WhereClause = @v_WhereClause + '  AND ISNULL(t.IsEnrollment,0) = 1 '
	END
	ELSE
		IF @v_TabName = 'All'
		BEGIN
			SET @v_TabName = @v_TabName --+ ISNULL(' ',0)  
		END
		ELSE
		BEGIN
			SET @v_WhereClause = ' WHERE ty.TaskTypeName = ''' + @v_TabName + ''''
			SET @v_WhereClause = @v_WhereClause + '  AND ISNULL(t.IsEnrollment,0) = 0 '
		END

	SET @v_Select = '
			INSERT INTO #tblTask
            SELECT DISTINCT
                t.TaskId
               ,t.PatientID
               ,ts.TaskStatusText
               ,ISNULL(AttemptedRemainderCount , 0) AttemptStatus
               ,t.TypeID
               ,ty.TaskTypeName
               ,t.IsEnrollment
               ,t.TaskTypeID
            FROM
                Task t WITH(NOLOCK)
            INNER JOIN #Program pr
                ON pr.ProgramID = t.ProgramID
		  INNER JOIN #TaskType ty1
			 ON ty1.TaskTypeID = t.TaskTypeID
            INNER JOIN TaskType ty WITH(NOLOCK)
                ON t.TaskTypeId = ty.TaskTypeId
            INNER JOIN TaskStatus ts WITH(NOLOCK)
                ON ts.TaskStatusId = t.TaskStatusId '

			 /* INNER JOIN #tblCareTeamMember ctm
			 ON ctm.ProviderID = t.AssignedCareProviderId
			 
			 INNER JOIN CareTeamTaskRights ctr WITH(NOLOCK)
			 ON ctr.ProviderID = ctm.ProviderID 
			 AND ctr.TaskTypeID = t.TaskTypeID
			 */


	IF EXISTS (
			SELECT 1
			FROM @t_PrimaryCarePhysician
			)
	BEGIN
		CREATE TABLE #PCP (PCPID INT)

		INSERT INTO #PCP
		SELECT tKeyId
		FROM @t_PrimaryCarePhysician

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
		SELECT ttt.TaskTypeID
			,ttt.TypeID
		INTO #tblTaskTypeIDAndTypeID
		FROM @t_tblTaskTypeIDAndTypeID ttt

		SET @v_JoinClause = @v_JoinClause + ' INNER JOIN #tblTaskTypeIDAndTypeID  
                               ON #tblTaskTypeIDAndTypeID.TaskTypeID = t.TaskTypeID  
                               AND #tblTaskTypeIDAndTypeID.TypeID = t.TypeID  
                               '
	END

	/*
			IF EXISTS (SELECT 1 FROM @t_CareTeamMembers)
			BEGIN
			    CREATE TABLE #CTM
			    (
			    CareTeamUserid INT
			    )
			    INSERT INTO #CTM
			    SELECT tKeyId FROM @t_CareTeamMembers
				SET @v_WhereClause = @v_WhereClause + 
				' AND EXISTS (SELECT 1 FROM CareTeamTaskRights ctm with(nolock) INNER JOIN #CTM c ON c.CareTeamUserid = ctm.UserId WHERE ctm.TaskTypeId = ty.TaskTypeID ) '
			END
			*/
	IF @v_DueDate IS NOT NULL
	BEGIN
		SET @v_WhereClause = @v_WhereClause + ' AND (
					( ts.TaskStatusText = ''Open'' AND 
					  DATEDIFF(DAY , CASE  
                                         WHEN ISNULL(t.TerminationDays , 0) <> 0 THEN DATEADD(DD , t.TerminationDays , t.TaskDueDate)  
                                         WHEN ISNULL(t.RemainderDays , 0) <> 0  
                                         AND RemainderState = ''B'' THEN DATEADD(DD , -t.RemainderDays , t.TaskDueDate)  
                                         WHEN ISNULL(t.RemainderDays , 0) <> 0  
                                         AND RemainderState = ''A'' THEN DATEADD(DD , t.RemainderDays , t.TaskDueDate)  
                                         ELSE t.TaskDuedate  
                                    END , getdate()) BETWEEN ' + CONVERT(VARCHAR(10), @v_DueDate) + 
			' AND 0 
                    )  
                    OR
                    (
						ts.TaskStatusText = ''Closed complete'' AND 
						DATEDIFF(DAY , t.TaskCompletedDate , getdate()) BETWEEN 0 AND ' + CONVERT(VARCHAR(10), @v_DueDate) + ' 
                    
                    ) 
                    
                    OR
                    (
						ts.TaskStatusText = ''Closed Incomplete'' AND 
						DATEDIFF(DD,  DATEADD(DD , t.TerminationDays , t.TaskDueDate),GETDATE()) BETWEEN 0 AND ' + CONVERT(VARCHAR(10), REPLACE(@v_DueDate, '-', '')) + '
                    )
                                               
                   )'
	END

	SET @v_SQL = @v_Select + ISNULL(@v_JoinClause, '') + ISNULL(@v_WhereClause, '')

	PRINT @v_SQL

	EXEC (@v_SQL)
	--select * from #tblTask

	CREATE TABLE #tblTotal (
		NAME VARCHAR(200)
		,PatientCount VARCHAR(10)
		,Scheduled VARCHAR(10)
		,[Open] VARCHAR(10)
		,ClosedComplete VARCHAR(10)
		,ClosedIncomplete VARCHAR(10)
		,Scheduled1 VARCHAR(10)
		,[Open1] VARCHAR(10)
		,ClosedComplete1 VARCHAR(10)
		,ClosedIncomplete1 VARCHAR(10)
		,FirstAttempt VARCHAR(10)
		,SecondAttempt VARCHAR(10)
		,ThirdOrMoreAttempts VARCHAR(10)
		,TabRowId VARCHAR(10)
		,TaskTypeName VARCHAR(200)
		,Isenrollment BIT
		)

	INSERT INTO #tblTotal
	SELECT CASE 
			WHEN @v_TabName1 = 'Managed Population Enrollment'
				THEN x.TaskTypeName + ' - ' + dbo.ufn_GetTypeNamesByTypeId(x.TaskTypeName, x.TypeID)
			ELSE dbo.ufn_GetTypeNamesByTypeId(x.TaskTypeName, x.TypeID)
			END NAME
		--,x.TaskTypeName
		,(
			SELECT COUNT(DISTINCT PatientUserID)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
			AND t.TaskTypeID = x.TaskTypeID
			AND T.ISenrollment = X.ISenrollment
			) AS PatientCount
		,(
			SELECT COUNT(1)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
				AND t.TaskStatusText = 'Scheduled'
				AND t.TaskTypeID = x.TaskTypeID
				AND T.ISenrollment = X.ISenrollment
			) AS Scheduled
		,(
			SELECT COUNT(1)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
				AND t.TaskStatusText = 'Open'
				AND t.TaskTypeID = x.TaskTypeID
				AND T.ISenrollment = X.ISenrollment
			) AS "Open"
		,(
			SELECT COUNT(1)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
				AND t.TaskStatusText = 'Closed Complete'
				AND t.TaskTypeID = x.TaskTypeID
				AND T.ISenrollment = X.ISenrollment
			) AS ClosedComplete
		,(
			SELECT COUNT(1)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
				AND t.TaskStatusText = 'Closed Incomplete'
				AND t.TaskTypeID = x.TaskTypeID
				AND T.ISenrollment = X.ISenrollment
			) AS ClosedIncomplete
		,(
			SELECT COUNT(1)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
				AND t.TaskStatusText = 'Scheduled'
				AND t.TaskTypeID = x.TaskTypeID
				AND T.ISenrollment = X.ISenrollment
			) AS Scheduled1
		,(
			SELECT COUNT(1)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
				AND t.TaskStatusText = 'Open'
				AND t.TaskTypeID = x.TaskTypeID
				AND T.ISenrollment = X.ISenrollment
			) AS "Open1"
		,(
			SELECT COUNT(1)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
				AND t.TaskStatusText = 'Closed Complete'
				AND t.TaskTypeID = x.TaskTypeID
				AND T.ISenrollment = X.ISenrollment
			) AS ClosedComplete1
		,(
			SELECT COUNT(1)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
				AND t.TaskStatusText = 'Closed Incomplete'
				AND t.TaskTypeID = x.TaskTypeID
				AND T.ISenrollment = X.ISenrollment
			) AS ClosedIncomplete1
		,(
			SELECT COUNT(1)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
				AND t.TaskStatusText = 'Open'
				AND t.TaskTypeID = x.TaskTypeID
				AND t.AttemptStatus = 1
				AND T.ISenrollment = X.ISenrollment
			) AS FirstAttempt
		,(
			SELECT COUNT(1)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
				AND t.TaskStatusText = 'Open'
				AND t.TaskTypeID = x.TaskTypeID
				AND t.AttemptStatus = 2
				AND T.ISenrollment = X.ISenrollment
			) AS SecondAttempt
		,(
			SELECT COUNT(1)
			FROM #tblTask t
			WHERE t.TypeID = x.TypeID
				AND t.TaskStatusText = 'Open'
				AND t.TaskTypeID = x.TaskTypeID
				AND t.AttemptStatus >= 3
				AND T.ISenrollment = X.ISenrollment
			) AS ThirdOrMoreAttempts
		,x.TypeID TabRowId
		,x.TaskTypeName
		,x.ISenrollment
	FROM (
		SELECT DISTINCT TypeID
			,TaskTypeName
			,isenrollment
			,TaskTypeID
		FROM #tblTask
		) x;

	WITH cteCareManagement
	AS (
		SELECT NAME
			,
			--TaskTypeName,
			PatientCount
			,Scheduled
			,"Open" AS [Open]
			,ClosedComplete
			,ClosedIncomplete
			,Scheduled1
			,"Open1" AS [Open1]
			,ClosedComplete1
			,ClosedIncomplete1
			,CEILING(FirstAttempt) AS FirstAttempt
			,SecondAttempt
			,ThirdOrMoreAttempts
			,TabRowId
			,TaskTypeName
			,ISenrollment
		FROM #tblTotal
		
		UNION
		
		SELECT 'ZZGrandTotal'
			,CONVERT(VARCHAR(10), SUM(CONVERT(INT, PatientCount)))
			,CONVERT(VARCHAR(10), SUM(CONVERT(INT, Scheduled)))
			,CONVERT(VARCHAR(10), SUM(CONVERT(INT, "open")))
			,CONVERT(VARCHAR(10), SUM(CONVERT(INT, ClosedComplete)))
			,CONVERT(VARCHAR(10), SUM(CONVERT(INT, ClosedIncomplete)))
			,0 --CONVERT(VARCHAR(10),SUM(CONVERT(INT,Scheduled1)))
			,0 --,CONVERT(VARCHAR(10),SUM(CONVERT(INT,"open1"))),
			,0 --CONVERT(VARCHAR(10),SUM(CONVERT(INT,ClosedComplete1)))
			,0 --CONVERT(VARCHAR(10),SUM(CONVERT(INT,ClosedIncomplete1)))
			,CEILING(CONVERT(VARCHAR(10), SUM(CONVERT(INT, FirstAttempt))))
			,CONVERT(VARCHAR(10), SUM(CONVERT(INT, SecondAttempt)))
			,CONVERT(VARCHAR(10), SUM(CONVERT(INT, ThirdOrMoreAttempts)))
			,''
			,'' AS TaskTypeName
			,'' AS ISenrollment
		FROM #tblTotal
		
		UNION
		
		SELECT 'ZZZGrandPercentage'
			,' '
			,CAST(CAST(CAST(SUM(CAST(Scheduled AS INT)) AS DECIMAL(10, 2)) * 100 / CAST(NULLIF(SUM(CAST(Scheduled AS INT)) + SUM(CAST([Open] AS INT)) + SUM(CAST(ClosedComplete AS INT)) + SUM(CAST(ClosedIncomplete AS INT)), 0) AS DECIMAL(10, 2)) AS DECIMAL(10, 2)) AS VARCHAR)
			,CAST(CAST(CAST(SUM(CAST([Open] AS INT)) AS DECIMAL(10, 2)) * 100 / CAST(NULLIF(SUM(CAST([Open] AS INT)) + SUM(CAST(Scheduled AS INT)) + SUM(CAST(ClosedComplete AS INT)) + SUM(CAST(ClosedIncomplete AS INT)), 0) AS DECIMAL(10, 2)) AS DECIMAL(10, 2)) AS VARCHAR)
			,CAST(CAST(CAST(SUM(CAST(ClosedComplete AS INT)) AS DECIMAL(10, 2)) * 100 / CAST(NULLIF(SUM(CAST(ClosedComplete AS INT)) + SUM(CAST([Open] AS INT)) + SUM(CAST(Scheduled AS INT)) + SUM(CAST(ClosedIncomplete AS INT)) , 0) AS DECIMAL(10, 2)) AS DECIMAL(10, 2)) AS VARCHAR)
			,CAST(CAST(CAST(SUM(CAST(ClosedIncomplete AS INT)) AS DECIMAL(10, 2)) * 100 / CAST(NULLIF(SUM(CAST(ClosedIncomplete AS INT)) + SUM(CAST([Open] AS INT)) + SUM(CAST(ClosedComplete AS INT)) + SUM(CAST(Scheduled AS INT)) , 0) AS DECIMAL(10, 2)) AS DECIMAL(10, 2)) AS VARCHAR)
			,0 --CAST(CAST(CAST(SUM(CAST(Scheduled1 AS INT)) AS DECIMAL(10,2))* 100/CAST(NULLIF(SUM(CAST(Scheduled AS INT))+SUM(CAST([Open] AS INT))+SUM(CAST(ClosedComplete AS INT))+SUM(CAST(ClosedIncomplete AS INT ))+SUM(CAST(FirstAttempt AS INT))+SUM(CAST(SecondAttempt AS INT))+SUM(CAST(ThirdOrMoreAttempts AS INT)),0) AS DECIMAL(10,2)) AS DECIMAL(10,2)) AS VARCHAR)
			,0 --,CAST(CAST(CAST(SUM(CAST([Open1] AS INT)) AS DECIMAL(10,2)) * 100/CAST(NULLIF(SUM(CAST([Open]  AS INT))+SUM(CAST(Scheduled AS INT))+SUM(CAST(ClosedComplete AS INT))+SUM(CAST(ClosedIncomplete AS INT ))+SUM(CAST(FirstAttempt AS INT))+SUM(CAST(SecondAttempt AS INT))+SUM(CAST(ThirdOrMoreAttempts AS INT)),0) AS DECIMAL(10,2))  AS DECIMAL(10,2)) AS VARCHAR)
			,0 --CAST(CAST(CAST(SUM(CAST(ClosedComplete1 AS INT)) AS DECIMAL(10,2)) * 100/CAST(NULLIF(SUM(CAST(ClosedComplete AS INT))+SUM(CAST([Open] AS INT))+SUM(CAST(Scheduled AS INT))+SUM(CAST(ClosedIncomplete AS INT ))+SUM(CAST(FirstAttempt AS INT))+SUM(CAST(SecondAttempt AS INT))+SUM(CAST(ThirdOrMoreAttempts AS INT)),0)AS DECIMAL(10,2)) AS DECIMAL(10,2)) AS VARCHAR)
			,0 --CAST(CAST(CAST(SUM(CAST(ClosedIncomplete1 AS INT)) AS DECIMAL(10,2)) * 100/CAST(NULLIF(SUM(CAST(ClosedIncomplete AS INT))+SUM(CAST([Open] AS INT))+SUM(CAST(ClosedComplete AS INT))+SUM(CAST(Scheduled AS INT ))+SUM(CAST(FirstAttempt AS INT))+SUM(CAST(SecondAttempt AS INT))+SUM(CAST(ThirdOrMoreAttempts AS INT)),0)AS DECIMAL(10,2)) AS DECIMAL(10,2)) AS VARCHAR)
			
			--,
			----,ISNULL(
			--		CAST(
			--			CAST(
			--				--CAST(SUM(CAST(FirstAttempt AS INT)) AS DECIMAL(10, 2))-- * 100
			--				--/ 
			--				--CAST(NULLIF(
			--				--SUM(CAST(ThirdOrMoreAttempts AS INT)) 
			--				--+ 
			--				--SUM(CAST(FirstAttempt AS INT)) 
			--				--+ 
			--				--SUM(CAST(SecondAttempt AS INT)) 
			--				--, 0) AS DECIMAL(10, 2)) 
			--				'0'
			--				AS MOney)
			--			AS VARCHAR(10))
			--		--,0.00)
			
			,ISNULL(CAST(CAST(CAST(SUM(CAST(FirstAttempt AS INT)) AS DECIMAL(10, 2)) * 100 / CAST(NULLIF(SUM(CAST(FirstAttempt AS INT)) + SUM(CAST(SecondAttempt AS INT)) + SUM(CAST(ThirdOrMoreAttempts AS INT)), 0) AS DECIMAL(10, 2)) AS DECIMAL(10, 2)) AS NUMERIC(10,2)),0)
			,ISNULL(CAST(CAST(CAST(SUM(CAST(SecondAttempt AS INT)) AS DECIMAL(10, 2)) * 100 / CAST(NULLIF(SUM(CAST(SecondAttempt AS INT)) + SUM(CAST(FirstAttempt AS INT)) + SUM(CAST(ThirdOrMoreAttempts AS INT)), 0) AS DECIMAL(10, 2)) AS DECIMAL(10, 2)) AS VARCHAR(10)),0.00)
			,ISNULL(CAST(CAST(CAST(SUM(CAST(ThirdOrMoreAttempts AS INT)) AS DECIMAL(10, 2)) * 100 / CAST(NULLIF(SUM(CAST(ThirdOrMoreAttempts AS INT)) + SUM(CAST(FirstAttempt AS INT)) + SUM(CAST(SecondAttempt AS INT)) , 0) AS DECIMAL(10, 2)) AS DECIMAL(10, 2)) AS VARCHAR(10)),0.00)
			,' '
			,'' AS TaskTypeName
			,'' AS ISenrollment
		FROM #tblTotal
		)
	SELECT *,CAST(FirstAttempt AS INT),ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
	FROM cteCareManagement
	--where Name is not null
	ORDER BY NAME
	
	
	
	
	SELECT COUNT(DISTINCT PatientUserID) PatientCount
	FROM #tblTask
END TRY

------------------------------------------------------------------------------------------------------
BEGIN CATCH
	-- Handle exception        
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
	
	select error_message()

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_CareManagement] TO [FE_rohit.r-ext]
    AS [dbo];

