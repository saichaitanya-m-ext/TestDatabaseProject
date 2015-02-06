/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_CareProviderDashBoard_MissedOpportunity_Filter] 10926
Description   : This procedure is used to get data from Filter Tables
Created By    : KOMALA
Created Date  : 21-Nov-2012
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MissedOpportunity_Filter]
(
 @i_AppUserId KEYID

)
AS
BEGIN
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

                     
                     EXEC usp_TaskDueDates_Missed_Opportunity_DD @i_AppUserId
--------------------Program---------------------
                     SELECT DISTINCT
                         p.ProgramId
                        ,p.ProgramName
                        ,cm.ProviderID
                        INTO #Program
                     FROM
                         ProgramCareTeam pct WITH ( NOLOCK )
                     INNER JOIN CareTeamMembers cm WITH ( NOLOCK )
                         ON pct.CareTeamId = cm.CareTeamId
                     INNER JOIN CareTeam c WITH ( NOLOCK )
                         ON c.CareTeamId = pct.CareTeamId
                     INNER JOIN Program p WITH ( NOLOCK )
                         ON p.ProgramId = pct.ProgramId
                     WHERE
                         cm.ProviderID = @i_AppUserId
                         AND cm.StatusCode = 'A'
                         AND p.StatusCode = 'A'

                  SELECT
                   ProgramId,
                   Programname 
                  FROM #program

------------------------Careteam-----------------
					 SELECT 
					 pct.ProgramId,
					 c.CareTeamId,
					 c.CareTeamName
					  INTO #CareTeam
                     FROM
                         ProgramCareTeam pct WITH ( NOLOCK )
                     INNER JOIN #program P
                         ON P.ProgramID = pct.ProgramId
                     INNER JOIN CareTeam c WITH ( NOLOCK )
                         ON c.CareTeamId = pct.CareTeamId


                   SELECT 
					 ProgramId,
					 CareTeamId,
					 CareTeamName
					  FROM #CareTeam

         --------------Careteammember-------------           
                    SELECT 
					 c.CareTeamId,
					 ct.ProviderID AS CareteammemberID,
					 dbo.ufn_GetUserNameByID(ct.ProviderID) AS Careteammember
					 
                     FROM
                          #CareTeam c WITH ( NOLOCK )
                         INNER JOIN CareTeamMembers ct
                           ON c.CareTeamId = ct.CareTeamId
                    
         ------------------TaskType------------------           

                     SELECT DISTINCT
                         p.Programid,
                         TaskType.TaskTypeId
                        ,TaskType.TaskTypeName
                        ,TaskType.Description
                        
                       INTO #TASKTYPE 
                     FROM
                         CareTeamTaskRights WITH ( NOLOCK )
                     INNER JOIN TaskType WITH ( NOLOCK )
                         ON TaskType.TaskTypeId = CareTeamTaskRights.TaskTypeId
                     INNER JOIN #program p
                         ON p.providerid = CareTeamTaskRights.ProviderID
                     WHERE
                         CareTeamTaskRights.ProviderID = @i_AppUserId
                         AND TaskType.StatusCode = 'A'
                         AND CareTeamTaskRights.StatusCode = 'A'
                         
                         
         SELECT 
           Programid,
           TaskTypeId,
           TaskTypeName,
           Description
         FROM #TASKTYPE      
         
         --SELECT * FROM Task
         
        --------------TaskName----------------------- 
                  
        SELECT DISTINCT
             te.TaskTypeId,
             CONVERT(VARCHAR(10) , t.TypeID) TaskID
           --T.TaskId
           ,CONVERT(VARCHAR , Dbo.ufn_GetTypeNamesByTypeId(te.TaskTypeName , t.TypeID)) TaskName
           ,CONVERT(VARCHAR(10),DATEADD(DD , t.TerminationDays , t.TaskDueDate),101) AS TaskDueDate
         -- ,te.TaskTypeId
           ,CASE WHEN (SELECT TaskStatusText FROM TaskStatus WHERE TaskStatusId = ts.TaskStatusId) = 'Open'
                 THEN 'O'
                 WHEN (SELECT TaskStatusText FROM TaskStatus WHERE TaskStatusId = ts.TaskStatusId) IN ('Closed Complete','Closed InComplete','Pending For Claims')
                 THEN 'C'
                 END TaskStatus
           
        FROM
            Task t WITH ( NOLOCK )
           INNER JOIN TaskStatus ts
             ON ts.TaskStatusId = t.TaskStatusId
           INNER JOIN #TASKTYPE te WITH ( NOLOCK )
            ON te.TaskTypeId = t.TaskTypeId
            WHERE ts.TaskStatusText = 'Closed Incomplete'
            
     -------PCP----------------       
                                                
           SELECT 
              p.ProgramID,
              PP.ProviderID AS PCPID,
              dbo.ufn_GetUserNameByID(PP.ProviderID) AS PCPName
             FROM #PROGRAM P
            INNER JOIN PatientProgram PCT
              ON PCT.ProgramId = P.ProgramID
            INNER JOIN PatientPCP PP
              ON PP.PatientId =  PCT.PatientID 
              
              
              
           
           
           
           
                                                
                                                
                                                --INNER JOIN @tblTaskType tp
                                                --    ON tp.tKeyId = Te.TaskTypeId
                                                --INNER JOIN TaskStatus ts WITH ( NOLOCK )
                                                --    ON ts.TaskStatusId = t.TaskStatusId       
                         


      --                        SELECT DISTINCT
      --                            ctm.ProviderID AS UserID
      --                           ,Dbo.ufn_GetUserNameByID(ctm.ProviderID) AS CareTeamMemberName
      --                        FROM
      --                            CareTeamMembers ctm WITH ( NOLOCK )
      --                        INNER JOIN CareTeam ct WITH ( NOLOCK )
      --                            ON ctm.CareTeamId = ct.CareTeamId
      --                        INNER JOIN CareTeamMembers ctm1 with(nolock)
      --                            ON ctm1.CareTeamId = ct.CareTeamId    
      --                        WHERE
      --                            ctm.StatusCode = 'A'
      --                            AND CT.StatusCode = 'A'
      --                            AND ctm1.ProviderID = @i_AppUserId
                      
      --                        SELECT
      --                            @i_AppUserId UserId
      --                           ,Dbo.ufn_GetUserNameByID(@i_AppUserId) AS CareTeamMemberName
                        

             
					 --SELECT DISTINCT
      --                   TaskType.TaskTypeId
      --                  ,TaskType.TaskTypeName
      --                  ,TaskType.Description
      --               FROM
      --                   CareTeamTaskRights WITH ( NOLOCK )
      --               INNER JOIN @tblCareTeamMember ctm
      --                   ON ctm.tKeyId = CareTeamTaskRights.ProviderID   
      --               INNER JOIN @tb1Careteam c
      --                   ON c.tKeyId = CareTeamTaskRights.CareTeamId     
      --               INNER JOIN TaskType WITH ( NOLOCK )
      --                   ON TaskType.TaskTypeId = CareTeamTaskRights.TaskTypeId
      --               WHERE
      --                   TaskType.StatusCode = 'A'
               
           
      --                        SELECT DISTINCT
      --                            ct.CareTeamId
      --                           ,ct.CareTeamName
      --                        FROM
      --                            ProgramCareTeam pct WITH ( NOLOCK )
      --                        INNER JOIN @tblProgram tp
      --                            ON tp.tKeyId = pct.ProgramId
      --                        INNER JOIN CareTeam ct WITH ( NOLOCK )
      --                            ON ct.CareTeamId = pct.CareTeamId
      --                        WHERE
      --                            ct.StatusCode = 'A'

      --                        SELECT DISTINCT
      --                            ISNULL(pts.PCPId , pts.PCPId) PcpId
      --                        INTO
      --                            #Pcp
      --                        FROM
      --                            Task t WITH ( NOLOCK )
      --                        INNER JOIN @tblProgram p
      --                            ON t.ProgramID = p.tKeyId
      --                        INNER JOIN Patients pts WITH ( NOLOCK )
      --                            ON pts.PatientID = t.PatientId

      --                        SELECT
      --                            PCPID
      --                           ,Dbo.ufn_GetUserNameByID(PCPID) PcpName
      --                        FROM
      --                            #Pcp
      --                        WHERE
      --                            PCPID IS NOT NULL
                                  
      --                            SELECT
      --                            @i_AppUserId UserId
      --                           ,Dbo.ufn_GetUserNameByID(@i_AppUserId) AS CareTeamMemberName

                        
                                       
                                     
																 
      --                                 SELECT DISTINCT
      --                                     ctm.ProviderID AS UserID
      --                                    ,Dbo.ufn_GetUserNameByID(ctm.ProviderID) AS CareTeamMemberName
      --                                 FROM
      --                                     CareTeamMembers ctm WITH ( NOLOCK )
      --                                 INNER JOIN ( SELECT DISTINCT
      --                                                  ct.CareTeamId
      --                                              FROM
      --                                                  ProgramCareTeam pct WITH ( NOLOCK )
      --                                              INNER JOIN @tblProgram tp
      --                                                  ON tp.tKeyId = pct.ProgramId
      --                                              INNER JOIN CareTeam ct WITH ( NOLOCK )
      --                                                  ON ct.CareTeamId = pct.CareTeamId
      --                                              INNER JOIN @tb1Careteam ct1
      --                                                  ON ct.CareTeamId = ct1.tKeyId
      --                                              WHERE
      --                                                  ct.StatusCode = 'A'
      --                                            ) c
      --                                     ON c.CareTeamId = ctm.CareTeamId
      --                                 WHERE
      --                                     ctm.StatusCode = 'A'
      --                                  END
      --                                  ELSE
      --                                  BEGIN
						--					 SELECT
						--					  @i_AppUserId UserId
						--					 ,Dbo.ufn_GetUserNameByID(@i_AppUserId) AS CareTeamMemberName
      --                                  END   

                               
                                
      --                                          SELECT DISTINCT
      --                                               t.TypeID,
						--							 te.TaskTypeId,
						--							 te.TaskTypeName
      --                                             -- CONVERT(VARCHAR , te.TaskTypeId) + '-' + CONVERT(VARCHAR(10) , t.TypeID) TaskID
      --                                             --,CONVERT(VARCHAR , Dbo.ufn_GetTypeNamesByTypeId(te.TaskTypeName , t.TypeID)) TaskName
      --                                             --,te.TaskTypeId
      --                                             INTO #Task
      --                                          FROM
      --                                              Task t WITH ( NOLOCK )
      --                                          INNER JOIN @tblProgram p
      --                                              ON p.tKeyId = t.ProgramID
      --                                          INNER JOIN TaskType te WITH ( NOLOCK )
      --                                              ON te.TaskTypeId = t.TaskTypeId
      --                                          INNER JOIN @tblTaskType tp
      --                                              ON tp.tKeyId = Te.TaskTypeId
      --                                          INNER JOIN TaskStatus ts WITH ( NOLOCK )
      --                                              ON ts.TaskStatusId = t.TaskStatusId
      --                                          WHERE
      --                                              ts.TaskStatusText = 'Closed Incomplete'
      --                                              AND ( ( DATEDIFF(day , DATEADD(DD , t.TerminationDays , t.TaskDueDate) , getdate()) BETWEEN 0
      --                                                      AND REPLACE(@i_RemainderValue , '-' , '') )
      --                                                    OR @i_RemainderValue IS NULL
      --                                                  )
      --                                          SELECT 
      --                                            CONVERT(VARCHAR , t.TaskTypeId) + '-' + CONVERT(VARCHAR(10) , t.TypeID) TaskID
						--						 ,CONVERT(VARCHAR , Dbo.ufn_GetTypeNamesByTypeId(t.TaskTypeName , t.TypeID)) TaskName
						--						 ,t.TaskTypeId
						--						FROM #Task t         

      --                                    END
      --                           END
                            
                        
               
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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MissedOpportunity_Filter] TO [FE_rohit.r-ext]
    AS [dbo];

