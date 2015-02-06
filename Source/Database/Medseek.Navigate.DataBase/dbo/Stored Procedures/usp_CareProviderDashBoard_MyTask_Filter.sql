
/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_CareProviderDashBoard_MyTask_Filter]10926  
Description   : This procedure is used to get data from Filter Tables  
Created By    : Rathnam  
Created Date  : 21-Nov-2012  
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION
08/09/2013 Santosh modiifed the careteammember filter according to the careteams of the appuserid
08/12/2013 Santosh added Parameter @tblCareteams to the SP 
19-2-2014 Rathnam Implimented the task rights functionality for the careteamMembers and Managers
------------------------------------------------------------------------------          
*/
-- [usp_CareProviderDashBoard_MyTask_Filter] 10941,1,'MISSEDOPPORTUNITIES'
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyTask_Filter] --8589202  
	(@i_AppUserId KEYID
	,@b_IsManager BIT
	,@v_PageType VARCHAR(100) --"MYTASK","MISSEDOPPORTUNITIES","CAREMANAGEMENTREPORT"
	
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

		
		IF @v_PageType = 'MISSEDOPPORTUNITIES'
		EXEC usp_TaskDueDates_Missed_Opportunity_DD @i_AppUserId
		ELSE
		EXEC usp_TaskDueDates_Select_DD @i_AppUserId
		
		
		SELECT DISTINCT p.ProgramId
			,p.ProgramName
		INTO #Program	
		FROM ProgramCareTeam pct WITH (NOLOCK)
		INNER JOIN CareTeamMembers cm WITH (NOLOCK)
			ON pct.CareTeamId = cm.CareTeamId
		INNER JOIN CareTeam c WITH (NOLOCK)
			ON c.CareTeamId = pct.CareTeamId
		INNER JOIN Program p WITH (NOLOCK)
			ON p.ProgramId = pct.ProgramId
		WHERE cm.ProviderID = @i_AppUserId
			AND cm.StatusCode = 'A'
			AND p.StatusCode = 'A'
			and c.StatusCode = 'A'
		
		SELECT * FROM #Program
		------------------------Careteam-----------------
		SELECT DISTINCT
		     pct.ProgramId
			,c.CareTeamId
			,c.CareTeamName
		FROM ProgramCareTeam pct WITH (NOLOCK)
		INNER JOIN CareTeamMembers ctm
		    ON ctm.CareTeamId = pct.CareTeamId
		INNER JOIN #Program P
			ON P.ProgramID = pct.ProgramId
		INNER JOIN CareTeam c WITH (NOLOCK)
			ON c.CareTeamId = pct.CareTeamId
		WHERE c.StatusCode = 'A'	
		AND ctm.ProviderID = @i_AppUserId

		CREATE TABLE #Ttype
		(
		
		 Programid int
		,CareteammemberID int
		,TaskTypeId int
		,TaskTypeName varchar(100)
		,Description varchar(100)
		)
		--------------Careteammember, TaskType & TaskName -------------  
		IF ISNULL(@b_IsManager,0) = 0
			BEGIN
				SELECT null CareTeamId , @i_AppUserId CareteammemberID, dbo.ufn_GetUserNameByID(@i_AppUserId) AS Careteammember
				
				INSERT INTO #Ttype
				SELECT DISTINCT NULL ProgramId
				    ,@i_AppUserId CareProviderID
					,TaskType.TaskTypeId
					,TaskType.TaskTypeName
					,TaskType.Description
				FROM CareTeamTaskRights cttr WITH (NOLOCK)
				INNER JOIN CareTeamMembers ctm WITH (NOLOCK)
				ON ctm.CareTeamId = cttr.CareTeamId
				INNER JOIN TaskType WITH (NOLOCK)
					ON TaskType.TaskTypeId = cttr.TaskTypeId
				WHERE cttr.ProviderID = @i_AppUserId
					AND TaskType.StatusCode = 'A'
					AND cttr.StatusCode = 'A'
				
				SELECT Programid
					,CareteammemberID ProviderID
					,TaskTypeId
					,TaskTypeName
					,Description
				FROM #Ttype
					
				SELECT DISTINCT t1.TaskTypeId
					,CONVERT(VARCHAR(10), t.TypeID) TaskID
					,CONVERT(VARCHAR, Dbo.ufn_GetTypeNamesByTypeId(t1.TaskTypeName, t.TypeID)) TaskName
					,CONVERT(VARCHAR(10), DATEADD(DD, t.TerminationDays, t.TaskDueDate), 101) AS TaskDueDate
					,CASE 
						WHEN ts.TaskStatusText IN (
								'Closed Incomplete'
								,'Pending For Claims'
								)
							THEN 'C'
						WHEN ts.TaskStatusText = 'Open'
							THEN 'O'
						END AS TaskStatus
				FROM Task t WITH (NOLOCK)
				INNER JOIN TaskStatus ts
					ON ts.TaskStatusId = t.TaskStatusId	
				INNER JOIN #Ttype t1
				ON t1.TaskTypeId = t.TaskTypeId
				INNER JOIN #Program p
				ON p.ProgramID = t.ProgramID	
				WHERE ((ts.TaskStatusText = 'Closed Incomplete' AND @v_PageType = 'MISSEDOPPORTUNITIES') OR @v_PageType <> 'MISSEDOPPORTUNITIES')
			END
		ELSE
		    BEGIN     
		    --SELECT 1
				SELECT DISTINCT
					 c.CareTeamId,
					 ctm.ProviderID CareteammemberID,
					 dbo.ufn_GetUserNameByID(ctm.ProviderID) AS Careteammember,
					 p.ProgramId
				into #Members	 
				FROM ProgramCareTeam pct WITH (NOLOCK)
				INNER JOIN CareTeamMembers ctm
				    ON ctm.CareTeamId = pct.CareTeamId
				INNER JOIN CareTeamMembers ctm1
				    ON ctm1.CareTeamId = pct.CareTeamId    
				INNER JOIN #Program P
					ON P.ProgramID = pct.ProgramId
				INNER JOIN CareTeam c WITH (NOLOCK)
					ON c.CareTeamId = pct.CareTeamId
				WHERE c.StatusCode = 'A'
				AND ctm.StatusCode = 'A'
				AND ctm1.ProviderID = @i_AppUserId
				
				SELECT DISTINCT CareTeamId,
				CareteammemberID,
				Careteammember
				FROM #Members
				
				INSERT INTO #Ttype
				SELECT DISTINCT p.Programid
					,p.CareteammemberID ProviderID
					,TaskType.TaskTypeId
					,TaskType.TaskTypeName
					,TaskType.Description
				FROM CareTeamTaskRights WITH (NOLOCK)
				INNER JOIN TaskType WITH (NOLOCK)
					ON TaskType.TaskTypeId = CareTeamTaskRights.TaskTypeId
				INNER JOIN #Members p
					ON p.CareteammemberID = CareTeamTaskRights.ProviderID
				WHERE 
					TaskType.StatusCode = 'A'
					AND CareTeamTaskRights.StatusCode = 'A'
					
				SELECT Programid
					,CareteammemberID ProviderID
					,TaskTypeId
					,TaskTypeName
					,Description
				FROM #Ttype
				
				IF @v_PageType = 'CareManagementReport'
				BEGIN
				
				SELECT TaskTypeId,CAST(TaskTypeId AS VARCHAR)+ ' - ' + TypeID AS TaskID,CONVERT(VARCHAR, Dbo.ufn_GetTypeNamesByTypeId(TaskTypeName, TypeID)) TaskName,TaskDueDate,TaskStatus FROM (
				SELECT DISTINCT te.TaskTypeId
					,CONVERT(VARCHAR(10), t.TypeID) TypeID 
					,te.TaskTypeName
					,CONVERT(VARCHAR(10), DATEADD(DD, t.TerminationDays, t.TaskDueDate), 101) AS TaskDueDate
					,CASE 
						WHEN ts.TaskStatusText IN (
								'Closed Incomplete'
								,'Pending For Claims'
								)
							THEN 'C'
						WHEN ts.TaskStatusText = 'Open'
							THEN 'O'
						END AS TaskStatus
				FROM Task t WITH (NOLOCK)
				INNER JOIN TaskStatus ts
					ON ts.TaskStatusId = t.TaskStatusId
				INNER JOIN #Ttype te WITH (NOLOCK)
					ON te.TaskTypeId = t.TaskTypeId
				WHERE t.ProgramID = te.Programid
				AND ((ts.TaskStatusText = 'Closed Incomplete' AND @v_PageType = 'MISSEDOPPORTUNITIES') OR @v_PageType <> 'MISSEDOPPORTUNITIES'))T
				
				
				
				END
				ELSE
				BEGIN
				
				SELECT TaskTypeId,TypeID AS TaskID,CONVERT(VARCHAR, Dbo.ufn_GetTypeNamesByTypeId(TaskTypeName, TypeID)) TaskName,TaskDueDate,TaskStatus FROM (
				SELECT DISTINCT te.TaskTypeId
					,CONVERT(VARCHAR(10), t.TypeID) TypeID 
					,te.TaskTypeName
					,CONVERT(VARCHAR(10), DATEADD(DD, t.TerminationDays, t.TaskDueDate), 101) AS TaskDueDate
					,CASE 
						WHEN ts.TaskStatusText IN (
								'Closed Incomplete'
								,'Pending For Claims'
								)
							THEN 'C'
						WHEN ts.TaskStatusText = 'Open'
							THEN 'O'
						END AS TaskStatus
				FROM Task t WITH (NOLOCK)
				INNER JOIN TaskStatus ts
					ON ts.TaskStatusId = t.TaskStatusId
				INNER JOIN #Ttype te WITH (NOLOCK)
					ON te.TaskTypeId = t.TaskTypeId
				WHERE t.ProgramID = te.Programid
				AND ((ts.TaskStatusText = 'Closed Incomplete' AND @v_PageType = 'MISSEDOPPORTUNITIES') OR @v_PageType <> 'MISSEDOPPORTUNITIES'))T
				
				END
			END
		-------PCP----------------       
		
		SELECT ProgramID,PCPID,dbo.ufn_GetUserNameByID(PCPID) AS PCPName FROM(     
		SELECT DISTINCT p.ProgramID
			,PP.ProviderID AS PCPID
		FROM #PROGRAM P
		INNER JOIN PatientProgram PCT
			ON PCT.ProgramId = P.ProgramID
		INNER JOIN PatientPCP PP
			ON PP.PatientId = PCT.PatientID
		WHERE ISNULL(pp.IslatestPCP, 0) = 1)T
			
	END TRY

	-------------------------------------------------------------------------------     
	BEGIN CATCH
		-- Handle exception          
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyTask_Filter] TO [FE_rohit.r-ext]
    AS [dbo];

