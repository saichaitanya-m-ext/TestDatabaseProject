/*          
--------------------------------------------------------------------------------------------------------------          
Procedure Name: [dbo].[usp_CareProviderDashBoard_MissedOpporunity] 23 
Description   : This procedure is to get the recent tasks by patientid to the respective careteammembers     
Created By    : Rathnam       
Created Date  : 17-Jan-2013
---------------------------------------------------------------------------------------------------------------          
Log History   :           
DD-Mon-YYYY  BY  DESCRIPTION 
22-Feb-2013 Rathnam added #tblCareTeamMember temp table and join for getting the related provider tasks
20-02-2014 Rathnam commented the assigned careprovider functionality as we need to get the tasks based on tasktypes   
----------------------------------------------------------------------------------------------------------------      
 */  
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MissedOpportunity]
(
 @i_AppUserId KEYID
,@t_ProgramID TTYPEKEYID READONLY
,@t_TaskTypeID TTYPEKEYID READONLY --> Displays the list of Task types based on login user task rights
,@t_PCPID TTYPEKEYID READONLY --> PCP information 
,@i_ReminderValue INT = NULL
,@t_tblTaskTypeIDAndTypeID TBLTASKTYPEANDTYPEID READONLY --,@t_TaskName TTYPEKEYID READONLY
,@t_CareTeamMemberId TTYPEKEYID READONLY
)
AS
BEGIN TRY
      SET NOCOUNT ON        
-- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

    /* 
    CREATE TABLE #tblCareTeamMember
     (
        ProviderID INT
     )
      IF NOT EXISTS ( SELECT
                          1
                      FROM
                          @t_CareTeamMemberId )
         BEGIN

               INSERT INTO
                   #tblCareTeamMember
                   SELECT
                       @i_AppUserId
         END
      ELSE
         BEGIN
               INSERT INTO
                   #tblCareTeamMember 
                   SELECT
                       tKeyId
                   FROM
                       @t_CareTeamMemberId
         END
     */
      CREATE TABLE #TotalMissedOpprtunities
     (
        TaskID INT
       ,PatientID INT
       ,ProgramID INT
	)


      CREATE TABLE #Program
     (
        ProgramID INT
     )
      INSERT INTO
          #Program
          SELECT
              tKeyId
          FROM
              @t_ProgramID

      CREATE TABLE #TaskType
     (
        TaskTypeID INT
     )
      INSERT INTO
          #TaskType
          SELECT tKeyId FROM @t_TaskTypeID
		  	
      DECLARE
              @v_Select VARCHAR(MAX) = ''
             ,@v_WhereClause VARCHAR(MAX) = ''
             ,@v_JoinClause VARCHAR(MAX) = ''
             ,@v_SQL VARCHAR(MAX) = ''

      SET @v_WhereClause = ' WHERE ts.TaskStatusText = ''Closed Incomplete'' '

      IF @i_ReminderValue IS NOT NULL
         BEGIN
               SET @i_ReminderValue = REPLACE(@i_ReminderValue , '-' , '')
               SET @v_WhereClause = @v_WhereClause + ' AND DATEDIFF(DD,  DATEADD(DD , t.TerminationDays , t.TaskDueDate),GETDATE()) BETWEEN 0 AND ' + CONVERT(VARCHAR(10) , @i_ReminderValue)
         END

      SET @v_Select = ' INSERT INTO #TotalMissedOpprtunities
          SELECT
               t.taskid
              ,t.Patientid
              ,t.ProgramID
          FROM
              Task t WITH(NOLOCK)
          INNER JOIN #Program pr
              ON t.ProgramID = pr.ProgramID
          INNER JOIN #TaskType ty
              ON ty.TaskTypeID = t.TaskTypeId     
          INNER JOIN TaskStatus ts WITH(NOLOCK)
              ON ts.TaskStatusId = t.TaskStatusId 
          
              '


      IF EXISTS ( SELECT
                      1
                  FROM
                      @t_PCPID )
         BEGIN
               CREATE TABLE #PCP
              (
                 PCPID INT
              )

               INSERT INTO
                   #PCP
                   SELECT
                       tKeyId
                   FROM
                       @t_PCPID

               SET @v_JoinClause = ' 
						INNER JOIN PatientPCP pcp  WITH(NOLOCK)
                          ON pcp.PatientID = t.PatientID
                          INNER JOIN #PCP    
                               ON #PCP.PCPID = pcp.ProviderID
               
							'
         END

      IF EXISTS ( SELECT
                      1
                  FROM
                      @t_tblTaskTypeIDAndTypeID )
         BEGIN
         

               SELECT
                   ttt.TaskTypeID
                  ,ttt.TypeID
               INTO
                   #tblTaskTypeIDAndTypeID
               FROM
                   @t_tblTaskTypeIDAndTypeID ttt

               SET @v_JoinClause = @v_JoinClause + ' INNER JOIN #tblTaskTypeIDAndTypeID  
                               ON #tblTaskTypeIDAndTypeID.TaskTypeID = ty.TaskTypeID  
                               AND #tblTaskTypeIDAndTypeID.TypeID = t.TypeID  
                               '
         END


      SET @v_SQL = @v_Select + ISNULL(@v_JoinClause,'') + ISNULL(@v_WhereClause,'')
      
      PRINT @v_SQL
      
      EXEC ( @v_SQL )

      SELECT
          t.Patientid
         ,p.ProgramID
         ,p.ProgramName
         ,COUNT(1) cnt
      INTO
          #PrgPatients
      FROM
          #TotalMissedOpprtunities t
      INNER JOIN Program p WITH(NOLOCK)
          ON p.ProgramId = t.ProgramID
      GROUP BY
          t.Patientid
        ,p.ProgramId
        ,p.ProgramName


      SELECT DISTINCT
          p.FullName AS PatientName
         ,( SELECT
                COUNT(1)
            FROM
                #TotalMissedOpprtunities t
            WHERE
                t.Patientid = p.PatientID
          ) AS MissedOpportunity
         ,p.PatientID
         ,STUFF(( SELECT
                      ', ' + mp.ProgramName + '(' + CONVERT(VARCHAR(5) , mp.cnt) + ')'
                  FROM
                      #PrgPatients mp
                  WHERE
                      mp.Patientid = p.PatientID
                  FOR
                      XML PATH('')
                ) , 1 , 2 , '') AS ManagedPopulation
         ,dbo.ufn_GetUserNameByID(p.PCPId) PCPName
         ,STUFF(( SELECT DISTINCT
                      ', ' + ct.CareTeamName
                  FROM
                      ProgramCareTeam pct WITH(NOLOCK)
                  INNER JOIN #PrgPatients t
                      ON t.ProgramId = pct.ProgramId
                  INNER JOIN CareTeam ct WITH(NOLOCK)
                      ON ct.CareTeamId = pct.CareTeamId
                  WHERE
                      t.PatientID = p.PatientID
                  FOR
                      XML PATH('')
                ) , 1 , 2 , '') AS CareTeamName
         ,( SELECT
                MAX(DateOfService) EncounterDate
            FROM
                vw_PatientEncounter WITH(NOLOCK)
            WHERE
                vw_PatientEncounter.PatientID = p.PatientID
          ) AS LastPCPVisit
         ,( SELECT
                MAX(t1.AttemptedContactDate) AttemptedContactDate
            FROM
                TaskAttempts t1 WITH(NOLOCK)
            INNER JOIN CommunicationType WITH(NOLOCK)
                ON CommunicationType.CommunicationTypeId = t1.CommunicationTypeId
            INNER JOIN #TotalMissedOpprtunities t2
                ON t1.TaskID = t2.TaskID    
            WHERE
                t2.Patientid = p.PatientID
                AND CommunicationType.CommunicationType = 'Phone Call'
          ) AS LastPhoneCall
         ,( SELECT
                MAX(DateOfService) EncounterDate
            FROM
                vw_PatientEncounter WITH(NOLOCK)
            WHERE
                vw_PatientEncounter.PatientID = p.PatientID
             AND CodeGroupingName IN ('ED','Acute Inpatient')   
          ) AS LastEncounter
         /*
         ,( SELECT TOP 1
                Comments
            FROM
                PatientEncounters WITH(NOLOCK)
            WHERE
                PatientEncounters.PatientID = p.PatientID
          ) AS ReasonForVisit
          */
          ,'' AS  ReasonForVisit
      FROM
          Patients p WITH ( NOLOCK )
      INNER JOIN ( SELECT DISTINCT
                       Patientid
                   FROM
                       #TotalMissedOpprtunities Tms
                 ) p1
          ON p1.Patientid = p.PatientID
           select * from #TotalMissedOpprtunities
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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MissedOpportunity] TO [FE_rohit.r-ext]
    AS [dbo];

