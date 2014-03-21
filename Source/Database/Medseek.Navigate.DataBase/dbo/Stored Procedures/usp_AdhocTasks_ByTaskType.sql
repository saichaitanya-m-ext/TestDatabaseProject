
/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_AdhocTasks_ByTaskType]   
Description   : This procedure is used to Select The AdhocTasks based on TaskType And   
                Schduled or  completed  
Created By    : Rathnam  
Created Date  : 05-Nov-2012  
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY    
19-Mar-2013 P.V.P.Mohan changed Table names for userProgram,UserDrugCodesUserHealthStatusScore,UserProcedureCodes,  
   UserEncounters,UserQuestionaire and Modified PatientID in place of UserID  
----------------------------------------------------------------------------------  
*/  
CREATE PROCEDURE [dbo].[usp_AdhocTasks_ByTaskType]  
(  
 @i_AppUserId KEYID  
,@t_PatientIdList TTYPEKEYID READONLY  
,@v_TaskTypeName VARCHAR(250)  
,@vc_IsSchduledType VARCHAR(1) = NULL  
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
  
   DECLARE @i_TaskTypeID INT  
   SELECT @i_TaskTypeID = TaskTypeId FROM TaskType WHERE TaskTypeName =  @v_TaskTypeName  
            IF @v_TaskTypeName = 'Managed Population Enrollment'  
               BEGIN  
                     SELECT DISTINCT  
                         p.ProgramId  
                        ,P.ProgramName  
                     FROM  
                         ProgramCareTeam  pct WITH(NOLOCK)  
                     INNER JOIN CareTeamMembers cm WITH(NOLOCK)  
                         ON pct.CareTeamId = cm.CareTeamId  
                     INNER JOIN CareTeam c WITH(NOLOCK)  
                         ON c.CareTeamId = pct.CareTeamId  
                     INNER JOIN Program p WITH(NOLOCK)  
                         ON p.ProgramId = pct.ProgramId  
                     WHERE  
                         --cm.UserId = @i_AppUserId  
                         --AND  
                          cm.StatusCode = 'A'  
                         AND p.StatusCode = 'A'  
               END  
            ELSE  
               BEGIN  
                     IF @v_TaskTypeName <> 'Ad-hoc Task'  
                        BEGIN  
                              IF @vc_IsSchduledType = 'S' AND @v_TaskTypeName <> 'Life Style Goal\Activity Follow Up'  
                                 BEGIN  
            --IF @v_TaskTypeName = 'Medication Titration'  
            --BEGIN  
            --SET @v_TaskTypeName = 'Questionnaire'  
            --END  
              
                                       SELECT DISTINCT  
											@i_TaskTypeID TaskTypeID   
                                          ,CONVERT(VARCHAR(20) , ts.TaskDueDate , 101) AS DueDate  
                                          ,dbo.ufn_GetTypeNamesByTypeId(tt.TaskTypeName , ts.TypeID) AS TaskTypeName  
                                          ,Dbo.ufn_GetUserNameByID(ts.AssignedCareProviderId) AS AssignedTo  
                                          ,CASE  
                                                WHEN( SELECT  
                                                          COUNT(*)  
                                                      FROM  
                                                          TaskRemainder tr WITH(NOLOCK)  
                                                      WHERE  
                                                          tr.TaskId = ts.TaskId  
                                                    ) = 0 THEN NULL  
                                                ELSE( SELECT  
                                                          COUNT(*)  
                                                      FROM  
                                                          TaskRemainder tr WITH(NOLOCK)  
                                                      WHERE  
                                                          tr.TaskId = ts.TaskId  
                                                    )  
                                           END AS Attempts  
                                          ,ts.TypeID AS TaskTypeGeneralizedID  
                                       FROM  
                                           Task(NOLOCK) ts  
                                       INNER JOIN @t_PatientIdList p  
                                           ON p.tKeyId = ts.PatientId  
                                       INNER JOIN TaskStatus tss WITH(NOLOCK)  
                                           ON ts.TaskStatusId = tss.TaskStatusId  
                                       INNER JOIN TaskType tt WITH(NOLOCK)  
                                           ON ts.TaskTypeId = tt.TaskTypeId  
                                       WHERE  
                                           tt.TaskTypeName = @v_TaskTypeName  
                                           AND tss.TaskStatusText IN ( 'Open' , 'Scheduled' )  
                                           AND ts.Isadhoc = 1  
                                          
                                       ORDER BY  
                                           2  
                                 END  
                              ELSE  
                                 BEGIN  
                                       IF @v_TaskTypeName = 'Life Style Goal\Activity Follow Up'  
                                          BEGIN  
  
                                                SELECT DISTINCT  
                                                     @i_TaskTypeID TaskTypeID  
                                                   ,lsg.LifeStyleGoal GoalName  
                                                   ,CONVERT(VARCHAR(20) , pg.StartDate , 101) AS StartDate  
                                                   ,CONVERT(VARCHAR , pg.DurationTimeline) + CASE pg.DurationUnits  
                                                                                               WHEN 'D' THEN ' Days'  
                                                                                               WHEN 'W' THEN ' Weeks'  
                                                                                               WHEN 'M' THEN ' Months'  
                                                                                               WHEN 'Q' THEN ' Quarters'  
                                                                                               WHEN 'Y' THEN ' Years'  
                                                                                               ELSE ''  
                                                                                             END Duration  
                                                   ,pg.Comments AS Comments  
                                                   ,CASE pg.GoalStatus  
                                                      WHEN 'C' THEN 'Complete'  
                                                      WHEN 'D' THEN 'Discontinue'  
                                                      WHEN 'I' THEN 'In-progress'  
                                                    END AS GoalStatus  
                                                   ,CASE  
                                                         WHEN( SELECT  
                                                                   COUNT(*)  
                                                               FROM  
                                                                   TaskRemainder tr WITH(NOLOCK)  
                                                               WHERE  
                                                                   tr.TaskId = t.TaskId  
                                                             ) = 0 THEN NULL  
                                                         ELSE( SELECT  
                                                                COUNT(*)  
                                                               FROM  
                                                                   TaskRemainder tr WITH(NOLOCK)  
                                                               WHERE  
                                                                   tr.TaskId = t.TaskId  
                                                             )  
                                                    END AS Attempts  
                                                   ,Dbo.ufn_GetUserNameByID(pg.AssignedCareProviderId) AS AssignedTo  
                                                   ,pg.LifeStyleGoalId  
                                                     
                                                FROM  
                                                    PatientGoal pg WITH(NOLOCK)  
                                                INNER JOIN Task t WITH(NOLOCK)  
                                                    ON t.PatientTaskID = pg.PatientGoalId  
                                                INNER JOIN @t_PatientIdList p  
                                                    ON p.tKeyId = pg.PatientId  
                                                INNER JOIN LifeStyleGoals lsg WITH(NOLOCK)  
                                                    ON lsg.LifeStyleGoalId = pg.LifeStyleGoalId  
                                                INNER JOIN TaskType ty
                                                    ON ty.TaskTypeId = t.TaskTypeId    
                                                WHERE  
                                                    pg.GoalCompletedDate IS NULL  
                                                    AND pg.IsAdhoc = 1  
                                                    AND pg.StatusCode = 'A' 
                                                    AND t.TypeID = lsg.LifeStyleGoalId 
                                                    AND ty.TaskTypeName = 'Life Style Goal\Activity Follow Up'  
                                                ORDER BY  
                                                    GoalName  
                                          END  
  
                                       IF @v_TaskTypeName IN ( 'Questionnaire' , 'Medication Titration' )  
                                          BEGIN  
                                                SELECT DISTINCT  
                                                    @i_TaskTypeID TaskTypeID  
                                                   ,CONVERT(VARCHAR(20) , uqe.DateTaken , 101) AS DateCompleted  
                                                   ,q.QuestionaireName AS TaskTypeName  
                                                   ,uqe.Comments AS Comments  
                                                   ,Dbo.ufn_GetUserNameByID(uqe.AssignedCareProviderId) AS AssignedTo  
                                                FROM  
                                                    PatientQuestionaire uqe WITH(NOLOCK)  
                                                INNER JOIN @t_PatientIdList p   
                                                    ON p.tKeyId = uqe.PatientId  
                                                INNER JOIN Questionaire q WITH(NOLOCK)  
                                                    ON uqe.QuestionaireId = q.QuestionaireId  
                                                WHERE  
                                                    uqe.DateTaken IS NOT NULL  
                                                    AND uqe.IsAdhoc = 1  
                                                ORDER BY  
                                                    TaskTypeName  
                                          END  
										/*
                                       IF @v_TaskTypeName = 'Schedule Encounter\Appointment'  
                                          BEGIN  
                                                SELECT DISTINCT  
													@i_TaskTypeID TaskTypeID  
                                                   ,CONVERT(VARCHAR(20) , ues.EncounterDate , 101) AS DateCompleted  
                                                   ,et.Name AS TaskTypeName  
                                                   ,ues.Comments AS Comments  
												   ,Dbo.ufn_GetUserNameByID(ues.CareTeamUserID) AS AssignedTo  
                                                FROM  
                                                    PatientEncounters ues WITH(NOLOCK)  
                                                INNER JOIN @t_PatientIdList p  
                                                    ON p.tKeyId = ues.PatientId  
                                                INNER JOIN EncounterType et WITH(NOLOCK)  
                                                    ON ues.EncounterTypeId = et.EncounterTypeId  
                                                WHERE  
                                                    ues.EncounterDate IS NOT NULL  
                                                    AND ues.IsAdhoc = 1  
                                                ORDER BY  
                                                    TaskTypeName  
                                          END  
                                          */
                                       IF @v_TaskTypeName = 'Schedule Procedure'  
  
                                          BEGIN  
                                                SELECT DISTINCT  
													@i_TaskTypeID TaskTypeID  
                                                   ,CONVERT(VARCHAR(20) , upc.ProcedureGroupCompletedDate , 101) AS DateCompleted  
                                                   ,csp.CodeGroupingName AS TaskTypeName  
                                                   ,upc.Commments AS Comments  
                                                   ,Dbo.ufn_GetUserNameByID(upc.AssignedCareProviderId) AS AssignedTo  
                                                FROM  
                                                    PatientProcedureGroupTask upc WITH(NOLOCK)  
                                                INNER JOIN @t_PatientIdList p  
                                                    ON upc.PatientID = p.tKeyId  
                                                INNER JOIN CodeGrouping csp WITH(NOLOCK)  
                                                    ON upc.CodeGroupingID = csp.CodeGroupingID  
                                                WHERE  
                                                    upc.ProcedureGroupCompletedDate IS NOT NULL  
                                                    AND upc.IsAdhoc = 1  
                                                ORDER BY  
                                                    TaskTypeName  
                                          END  
                                       /*
                                       IF @v_TaskTypeName = 'Immunization'  
                                          BEGIN  
                                                SELECT DISTINCT  
													 @i_TaskTypeID TaskTypeID  
                                                   ,CONVERT(VARCHAR(20) , ui.ImmunizationDate , 101) AS DateCompleted  
                                                   ,IM.Name AS TaskTypeName  
                                                   ,ui.Comments AS Comments  
                                                   ,Dbo.ufn_GetUserNameByID(ui.AssignedCareProviderId) AS AssignedTo  
                                                FROM  
                                                    PatientImmunizations ui WITH(NOLOCK)  
                                                INNER JOIN @t_PatientIdList p  
                                                    ON ui.PatientID = p.tKeyId  
                                                INNER JOIN Immunizations im WITH(NOLOCK)  
                                                    ON ui.immunizationID = im.immunizationID  
                                                WHERE  
                                                    ui.immunizationDate IS NOT NULL  
                                                    AND ui.IsAdhoc = 1  
                                                ORDER BY  
                                                    TaskTypeName  
                                          END  
                                          */
                        IF @v_TaskTypeName = 'Medication Prescription'  
                                          BEGIN  
                                                SELECT DISTINCT  
													@i_TaskTypeID TaskTypeID  
                                                   ,CONVERT(VARCHAR(20) , udc.EndDate , 101) AS DateCompleted  
                                                   ,csd.DrugName AS TaskTypeName  
                                                   ,udc.Comments AS Comments  
                                                   ,Dbo.ufn_GetUserNameByID(udc.CareTeamUserID) AS AssignedTo  
                                                FROM  
                                                    PatientDrugCodes udc WITH(NOLOCK)  
                                                INNER JOIN @t_PatientIdList p  
                                                    ON p.tKeyId = udc.PatientID  
                                                INNER JOIN CodeSetDrug csd WITH(NOLOCK)  
                                                    ON udc.DrugCodeId = csd.DrugCodeId  
                                                WHERE  
                                                    udc.DateFilled IS NOT NULL  
                                                    AND udc.IsAdhoc = 1  
                                                ORDER BY  
                                                    TaskTypeName  
                                          END  
  
                                 END  
                        END  
                     ELSE  
                        BEGIN  
                              IF @v_TaskTypeName = 'Ad-hoc Task'  
                                 BEGIN  
  
                                       IF @vc_IsSchduledType = 'S'  
                                          BEGIN  
  
                                                SELECT DISTINCT  
                                                    CONVERT(VARCHAR(20) , ts.TaskDueDate , 101) AS DueDate  
                                                   ,ts.ManualTaskName AS TaskTypeName  
                                                   ,CASE  
                                                         WHEN( SELECT  
                                                                   COUNT(*)  
                                                               FROM  
                                                                   TaskRemainder tr WITH(NOLOCK)  
                                                               WHERE  
                                                                   tr.TaskTypeGeneralizedID IS NULL  
                                                                   AND ts.TaskId = tr.TaskId  
                                                             ) = 0 THEN NULL  
                                                         ELSE( SELECT  
                                                                   COUNT(*)  
                                                               FROM  
                                                                   TaskRemainder tr WITH(NOLOCK)  
                                                               WHERE  
                                                                   tr.TaskTypeGeneralizedID IS NULL  
                                                                   AND ts.TaskId = tr.TaskId  
                                                             )  
                                                    END AS Attempts  
                                                   ,Dbo.ufn_GetUserNameByID(ts.AssignedCareProviderId) AS AssignedTo  
                                                FROM  
                                                    Task(NOLOCK) ts  
                                                INNER JOIN @t_PatientIdList p  
                                                    ON ts.PatientId = p.tKeyId   
                                                INNER JOIN TaskStatus tss WITH(NOLOCK)  
                                                    ON ts.TaskStatusId = tss.TaskStatusId  
                                                WHERE  
                                                    tss.TaskStatusText = 'Open'  
                                                    AND ts.ManualTaskName IS NOT NULL  
                                                    AND ts.Isadhoc = 1  
                                                      
                                          END  
                                       ELSE  
                                          BEGIN  
                                                SELECT DISTINCT  
                                                    CONVERT(VARCHAR(20) , ts.TaskCompletedDate , 101) AS DateCompleted  
                                                   ,ts.ManualTaskName AS TaskTypeName  
                                                   ,ts.Comments AS Comments  
                                                FROM  
                                                    Task ts WITH(NOLOCK)  
                                                INNER JOIN @t_PatientIdList p  
                                                    ON ts.PatientId = p.tKeyId  
                                                INNER JOIN TaskStatus tss WITH(NOLOCK)  
                                                    ON ts.TaskStatusId = tss.TaskStatusId  
                                                WHERE  
                                                     ts.ManualTaskName IS NOT NULL  
                                                    AND tss.TaskStatusText = 'Closed Complete'  
                                                    AND ts.Isadhoc = 1  
                                          END  
                                 END  
  
                        END  
               END  
      END TRY      
--------------------------------------------------------       
      BEGIN CATCH      
    -- Handle exception      
            DECLARE @i_ReturnedErrorID INT  
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
            RETURN @i_ReturnedErrorID  
      END CATCH  
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_AdhocTasks_ByTaskType] TO [FE_rohit.r-ext]
    AS [dbo];

