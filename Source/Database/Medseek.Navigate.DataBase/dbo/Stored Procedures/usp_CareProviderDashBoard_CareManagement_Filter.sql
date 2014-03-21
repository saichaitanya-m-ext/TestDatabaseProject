/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_CareProviderDashBoard_CareManagement_Filter] 23
Description   : This procedure is used to get data from Filter Tables
Created By    : Santosh
Created Date  : 25-Jul-2013
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
30/07/2013:Santosh modified the table type @tblTaskType from ttypekeyid to tblTaskTypeAndTypeID
21/08/2013:Mohan added PCP Id and CareTeam Members select 
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_CareManagement_Filter]
(
 @i_AppUserId KEYID
,@tblProgram TTYPEKEYID READONLY
,@tblTaskType dbo.tblTaskTypeAndTypeID READONLY
,@tb1Careteam TTYPEKEYID READONLY  
,@i_RemainderValue INT = NULL
,@tblCareTeamMember TTYPEKEYID READONLY
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

            IF NOT EXISTS ( SELECT 1 FROM @tblProgram ) AND NOT EXISTS (SELECT 1 FROM @tblCareTeamMember)
               BEGIN
                     
                     EXEC usp_TaskDueDates_Missed_Opportunity_DD @i_AppUserId

                     SELECT DISTINCT
                         p.ProgramId
                        ,p.ProgramName
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



                     SELECT DISTINCT
                         c.CareTeamId
                        ,c.CareTeamName
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
                         
                           SELECT DISTINCT
                                  ISNULL(pts.PCPId , pts.PCPId) PcpId
                                  ,Dbo.ufn_GetUserNameByID(pts.PCPId) As PcpName
                        
                              FROM
                                  Task t WITH ( NOLOCK )
                              INNER JOIN Program p WITH ( NOLOCK )
									ON p.ProgramId = t.ProgramId
                              INNER JOIN Patients pts WITH ( NOLOCK )
									ON pts.PatientID = t.PatientId
							  INNER JOIN ProgramCareTeam PCT 
							        ON P.ProgramId = PCT.ProgramId
							  INNER JOIN CareTeamMembers CTM 
							        ON PCT.CareTeamId = CTM.CareTeamId
								WHERE
								CTM.ProviderID = @i_AppUserId
								AND
								 p.StatusCode = 'A'
								


                     SELECT DISTINCT
                         TaskType.TaskTypeId
                        ,TaskType.TaskTypeName
                        ,TaskType.Description
                     FROM
                         CareTeamTaskRights WITH ( NOLOCK )
                     INNER JOIN TaskType WITH ( NOLOCK )
                         ON TaskType.TaskTypeId = CareTeamTaskRights.TaskTypeId
                     WHERE
                         ProviderID = @i_AppUserId
                         AND TaskType.StatusCode = 'A'
                         AND CareTeamTaskRights.StatusCode = 'A'


                     IF EXISTS ( SELECT 1
                                 FROM
                                     CareTeamMembers WITH ( NOLOCK )
                                 WHERE
                                     ProviderID = @i_AppUserId
                                     AND IsCareTeamManager = 1
                                     AND StatusCode = 'A' )
                        BEGIN
                              SELECT DISTINCT
                                  ctm.ProviderID AS UserID
                                 ,Dbo.ufn_GetUserNameByID(ctm.ProviderID) AS CareTeamMemberName
                              FROM
                                  CareTeamMembers ctm WITH ( NOLOCK )
                              INNER JOIN CareTeam ct WITH ( NOLOCK )
                                  ON ctm.CareTeamId = ct.CareTeamId
                              INNER JOIN CareTeamMembers ctm1 with(nolock)
                                  ON ctm1.CareTeamId = ct.CareTeamId    
                              WHERE
                                  ctm.StatusCode = 'A'
                                  AND CT.StatusCode = 'A'
                                  AND ctm1.ProviderID = @i_AppUserId
                        END
                     ELSE
                        BEGIN
                              SELECT
                                  @i_AppUserId UserId
                                 ,Dbo.ufn_GetUserNameByID(@i_AppUserId) AS CareTeamMemberName
                        END

               END
               ELSE IF NOT EXISTS ( SELECT 1 FROM @tblProgram ) AND EXISTS (SELECT 1 FROM @tblCareTeamMember) AND EXISTS ( SELECT 1 FROM @tb1Careteam )
               BEGIN
					 SELECT DISTINCT
                         TaskType.TaskTypeId
                        ,TaskType.TaskTypeName
                        ,TaskType.Description
                     FROM
                         CareTeamTaskRights WITH ( NOLOCK )
                     INNER JOIN @tblCareTeamMember ctm
                         ON ctm.tKeyId = CareTeamTaskRights.ProviderID   
                     INNER JOIN @tb1Careteam c
                         ON c.tKeyId = CareTeamTaskRights.CareTeamId     
                     INNER JOIN TaskType WITH ( NOLOCK )
                         ON TaskType.TaskTypeId = CareTeamTaskRights.TaskTypeId
                     WHERE
                         TaskType.StatusCode = 'A'
                         AND CareTeamTaskRights.StatusCode = 'A'
               END
            ELSE
               BEGIN
                     IF EXISTS ( SELECT 1 FROM @tblProgram ) AND NOT EXISTS ( SELECT 1 FROM @tblTaskType ) AND NOT EXISTS ( SELECT 1 FROM @tb1Careteam )
                        BEGIN
                              SELECT DISTINCT
                                  ct.CareTeamId
                                 ,ct.CareTeamName
                              FROM
                                  ProgramCareTeam pct WITH ( NOLOCK )
                              INNER JOIN @tblProgram tp
                                  ON tp.tKeyId = pct.ProgramId
                              INNER JOIN CareTeam ct WITH ( NOLOCK )
                                  ON ct.CareTeamId = pct.CareTeamId
                              INNER JOIN CareTeamMembers CTM 
                                  ON pct.CareTeamId = CTM.CareTeamId
                              WHERE
                                  ct.StatusCode = 'A'
                                  AND CTM.ProviderID = @i_AppUserId

                              SELECT DISTINCT
                                  ISNULL(pts.PCPId , pts.PCPId) PcpId
                              INTO
                                  #Pcp
                              FROM
                                  Task t WITH ( NOLOCK )
                              INNER JOIN @tblProgram p
                                  ON t.ProgramID = p.tKeyId
                              INNER JOIN Patients pts WITH ( NOLOCK )
                                  ON pts.PatientID = t.PatientId

                              SELECT
                                  PCPID
                                 ,Dbo.ufn_GetUserNameByID(PCPID) PcpName
                              FROM
                                  #Pcp
                              WHERE
                                  PCPID IS NOT NULL
                              ORDER BY Dbo.ufn_GetUserNameByID(PCPID)
                              
                                  
                                  SELECT
                                  @i_AppUserId UserId
                                 ,Dbo.ufn_GetUserNameByID(@i_AppUserId) AS CareTeamMemberName

                        END
                     ELSE
                        BEGIN
                              IF EXISTS (SELECT 1 FROM @tblProgram) AND NOT EXISTS ( SELECT 1 FROM @tblTaskType ) AND EXISTS ( SELECT 1 FROM @tb1Careteam )
                                 BEGIN
                                       
                                        IF EXISTS ( SELECT 1
															 FROM
																 CareTeamMembers WITH ( NOLOCK )
															 WHERE
																 ProviderID = @i_AppUserId
																 AND IsCareTeamManager = 1
																 AND StatusCode = 'A' )
										BEGIN						 
                                       SELECT DISTINCT
                                           ctm.ProviderID AS UserID
                                          ,Dbo.ufn_GetUserNameByID(ctm.ProviderID) AS CareTeamMemberName
                                       FROM
                                           CareTeamMembers ctm WITH ( NOLOCK )
                                       INNER JOIN ( SELECT DISTINCT
                                                        ct.CareTeamId
                                                    FROM
                                                        ProgramCareTeam pct WITH ( NOLOCK )
                                                    INNER JOIN @tblProgram tp
                                                        ON tp.tKeyId = pct.ProgramId
                                                    INNER JOIN CareTeam ct WITH ( NOLOCK )
                                                        ON ct.CareTeamId = pct.CareTeamId
                                                    INNER JOIN @tb1Careteam ct1
                                                        ON ct.CareTeamId = ct1.tKeyId
                                                    WHERE
                                                        ct.StatusCode = 'A'
                                                  ) c
                                           ON c.CareTeamId = ctm.CareTeamId
                                       WHERE
                                           ctm.StatusCode = 'A'
                                        END
                                        ELSE
                                        BEGIN
											 SELECT
											  @i_AppUserId UserId
											 ,Dbo.ufn_GetUserNameByID(@i_AppUserId) AS CareTeamMemberName
                                        END   

                                 END
                              ELSE
                                 BEGIN
                                       IF EXISTS ( SELECT 1 FROM @tblProgram ) AND EXISTS ( SELECT 1 FROM @tblTaskType )AND EXISTS (SELECT 1 FROM @tblCareTeamMember)
                                          BEGIN
                                                SELECT DISTINCT
                                                     t.TypeID,
													 te.TaskTypeId,
													 te.TaskTypeName
                                                   -- CONVERT(VARCHAR , te.TaskTypeId) + '-' + CONVERT(VARCHAR(10) , t.TypeID) TaskID
                                                   --,CONVERT(VARCHAR , Dbo.ufn_GetTypeNamesByTypeId(te.TaskTypeName , t.TypeID)) TaskName
                                                   --,te.TaskTypeId
                                                   INTO #Task
                                                FROM
                                                    Task t WITH ( NOLOCK )
                                                INNER JOIN @tblProgram p
                                                    ON p.tKeyId = t.ProgramID
                                                INNER JOIN TaskType te WITH ( NOLOCK )
                                                    ON te.TaskTypeId = t.TaskTypeId
                                                INNER JOIN @tblTaskType tp
                                                    ON tp.TaskTypeId = Te.TaskTypeId
                                                INNER JOIN TaskStatus ts WITH ( NOLOCK )
                                                    ON ts.TaskStatusId = t.TaskStatusId
                                                    INNER JOIN @tblCareTeamMember CTM
                                                    ON CTM.tKeyId=t.AssignedCareProviderId
                                                WHERE
                                                
                                                     ( ( DATEDIFF(day , DATEADD(DD , t.TerminationDays , t.TaskDueDate) , getdate()) BETWEEN 0
                                                            AND REPLACE(@i_RemainderValue , '-' , '') )
                                                          OR @i_RemainderValue IS NULL
                                                        )
                                                    --AND (( EXISTS (SELECT 1 FROM @tblTaskType WHERE TypeID = 1 AND t.IsEnrollment = 1 )) OR ( EXISTS (SELECT 1 FROM @tblTaskType WHERE TypeID = 0 AND t.IsEnrollment = 0 )))   
                                                    AND EXISTS (SELECT 1 FROM @tblTaskType WHERE ((TypeID = 1 AND t.IsEnrollment = 1) OR (TypeID = 0 AND t.IsEnrollment = 0) ))
                                                SELECT 
                                                  CONVERT(VARCHAR , t.TaskTypeId) + '-' + CONVERT(VARCHAR(10) , t.TypeID) TaskID
												 ,CONVERT(VARCHAR , Dbo.ufn_GetTypeNamesByTypeId(t.TaskTypeName , t.TypeID)) TaskName
												 ,t.TaskTypeId
												FROM #Task t         

                                          END
                                 END
                            
                        END
               END
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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_CareManagement_Filter] TO [FE_rohit.r-ext]
    AS [dbo];

