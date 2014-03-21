
  
/*          
------------------------------------------------------------------------------------------------          
Procedure Name: usp_TaskTypeCommunications_Select 1,16,8        
Description   : This procedure is used to get the records from the TaskTypeCommunications table           
Created By    : Aditya          
Created Date  : 06-Apr-2010          
------------------------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
27-July-2010 NagaBabu Added TaskTypeCommunicationID as InPut perameter and TaskTypeCommunicationID,    
                            CommunicationTemplateID,TaskTypeGeneralizedID Fields in Select Statement  
02-Aug-2010  NagaBabu Added StatusCode to the select statement                                      
3-Aug-10 Pramod Modified to include tab for specific schedules  
9-Aug-10 Pramod Included DISTINCT clause for the 2nd tab  
11-Aug-10 NagaBabu Included a new field TaskTypeCommunicationTemplate by concatinating   
                           TaskTypeCommunicationID and CommunicationTemplateID Fields  
23-Aug-2010 NagaBabu Added TemplateName field in select statement                              
28-Sep-10 Pramod Modified the TaskTypeCommunicationTemplate with two extra values from tasktype table  
29-Sep-2010 NagaBabu Added CASE statement for StatusCode in this SP for every select Statement  
30-Sep-2010 Pramod Changed the case for schedule procedure (to like %) and included Evaluate lab results  
11-Oct-2010 NagaBabu Added 'Questionnaire' to If Else Statement  
25-Nov-10 Pramod Included TaskTypeCommunications.TaskTypeCommunicationID = @i_TaskTypeCommunicationID in the where clause  
28-Mar-2011 NagaBabu Added @vc_StatusCode and added in all where clause  
27-Apr-2011 NagaBabu Modified 'TypeName' field where '@v_TaskTypeName LIKE 'Schedule Procedure%''  
15July-2011 NagaBabu Added LeadtimeDays field for the tasktype 'Schedule Procedure'  
Jan-28-2014 Prathyusha modifid SP
------------------------------------------------------------------------------------------------          
*/  
CREATE PROCEDURE [dbo].[usp_TaskTypeCommunications_Select] (  
 @i_AppUserId KeyID  
 ,@i_TaskTypeCommunicationID KeyID = NULL  
 ,@i_TaskTypeID KeyID = NULL  
 ,@i_CommunicationSequence KeyID = NULL  
 ,@vc_StatusCode StatusCode = NULL  
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
  
 SELECT TaskTypeCommunications.TaskTypeCommunicationID  
  ,TaskTypeCommunications.TaskTypeID  
  ,TaskTypeCommunications.CommunicationTypeID  
  ,CommunicationType.CommunicationType AS ContactType  
  ,TaskTypeCommunications.CommunicationSequence  
  ,CommunicationType.CommunicationType + ' - ' + CAST(TaskTypeCommunications.CommunicationSequence AS VARCHAR(3)) AS CommunicationAttempt  
  ,TaskTypeCommunications.CommunicationAttemptDays  
  ,TaskTypeCommunications.NoOfDaysBeforeTaskClosedIncomplete  
  ,TaskTypeCommunications.CreatedByUserId  
  ,TaskTypeCommunications.CreatedDate  
  ,TaskTypeCommunications.LastModifiedByUserId     
  ,TaskTypeCommunications.CommunicationTemplateID  
  ,TaskTypeCommunications.TaskTypeGeneralizedID  
  ,CASE TaskTypeCommunications.StatusCode  
  
   WHEN 'A'  
    THEN 'Active'  
   WHEN 'I'  
    THEN 'InActive'  
   ELSE ''  
   END AS StatusCode  
   ,TaskTypeCommunications.LastModifiedDate 
  ,CAST(TaskTypeCommunications.TaskTypeCommunicationID AS VARCHAR(12)) + ' - ' + ISNULL(CAST(TaskTypeCommunications.CommunicationTemplateID AS VARCHAR(12)), '') + '-' + ISNULL(CAST(TaskTypeCommunications.CommunicationAttemptDays AS VARCHAR(12)), '') + '-'
 + ISNULL(CAST(TaskTypeCommunications.NoOfDaysBeforeTaskClosedIncomplete AS VARCHAR(12)), '') AS TaskTypeCommunicationTemplate  
  ,CommunicationTemplate.TemplateName  
  ,TaskTypeCommunications.RemainderState  
  ,TaskType.ScheduledDays  
  ,CASE   
   WHEN TaskTypeCommunications.RemainderState = 'B'  
    THEN TaskTypeCommunications.CommunicationAttemptDays  
   END BeforeDueDateDays  
  ,CASE   
   WHEN TaskTypeCommunications.RemainderState = 'A'  
    THEN TaskTypeCommunications.CommunicationAttemptDays  
   END AfterDueDateDays  
 FROM TaskTypeCommunications WITH (NOLOCK)  
 INNER JOIN TaskType WITH (NOLOCK) ON TaskType.TaskTypeId = TaskTypeCommunications.TaskTypeID  
 LEFT JOIN CommunicationType WITH (NOLOCK) ON CommunicationType.CommunicationTypeId = TaskTypeCommunications.CommunicationTypeID  
 LEFT JOIN CommunicationTemplate WITH (NOLOCK) ON CommunicationTemplate.CommunicationTemplateId = TaskTypeCommunications.CommunicationTemplateID  
 WHERE (  
   TaskTypeCommunications.TaskTypeID = @i_TaskTypeID  
   OR @i_TaskTypeID IS NULL  
   )  
  AND (  
   TaskTypeCommunications.CommunicationSequence = @i_CommunicationSequence  
   OR @i_CommunicationSequence IS NULL  
   )  
  AND (  
   TaskTypeCommunications.TaskTypeCommunicationID = @i_TaskTypeCommunicationID  
   OR @i_TaskTypeCommunicationID IS NULL  
   )  
  AND (  
   TaskTypeCommunications.StatusCode = @vc_StatusCode  
   OR @vc_StatusCode IS NULL  
   )  
  
 DECLARE @v_TaskTypeName SourceName  
  ,@b_AllowSpecificSchedules BIT  
  
 IF @i_TaskTypeID IS NOT NULL  
  AND @i_TaskTypeCommunicationID IS NULL  
 BEGIN  
  SELECT @v_TaskTypeName = TaskTypeName  
   ,@b_AllowSpecificSchedules = AllowSpecificSchedules  
  FROM TaskType  
  WHERE TaskTypeID = @i_TaskTypeID  
  
  IF @b_AllowSpecificSchedules = 1  
  BEGIN  
   IF @v_TaskTypeName = 'Life Style Goal\Activity Follow Up'  
    SELECT DISTINCT TaskTypeCommunications.TaskTypeGeneralizedID  
     ,Activity.NAME AS TypeName  
     
     ,CASE   
      WHEN (  
        SELECT TOP 1 1  
        FROM TaskTypeCommunications tc  
        WHERE tc.TaskTypeGeneralizedID = Activity.ActivityId  
         AND StatusCode = 'A'  
        ) = 1  
       THEN 'Active'  
      ELSE 'InActive'  
      END StatusCode  
      ,Activity.LastModifiedDate
    FROM TaskTypeCommunications WITH (NOLOCK)  
    INNER JOIN Activity WITH (NOLOCK) ON TaskTypeCommunications.TaskTypeGeneralizedID = Activity.ActivityId  
     AND Activity.StatusCode = 'A'  
    WHERE TaskTypeCommunications.TaskTypeID = @i_TaskTypeID  
     AND (  
      TaskTypeCommunications.StatusCode = @vc_StatusCode  
      OR @vc_StatusCode IS NULL  
      )  
   ELSE  
    IF @v_TaskTypeName IN (  
      'Questionnaire'  
      )  
     SELECT DISTINCT TaskTypeCommunications.TaskTypeGeneralizedID  
      ,Questionaire.QuestionaireName AS TypeName
      
      ,CASE   
       WHEN (  
         SELECT TOP 1 1  
         FROM TaskTypeCommunications tc  
         WHERE tc.TaskTypeGeneralizedID = Questionaire.QuestionaireId  
          AND StatusCode = 'A'  
         ) = 1  
        THEN 'Active'  
       ELSE 'InActive'  
       END StatusCode  
       ,Questionaire.LastModifiedDate  
     FROM TaskTypeCommunications WITH (NOLOCK)  
     INNER JOIN Questionaire WITH (NOLOCK) ON TaskTypeCommunications.TaskTypeGeneralizedID = Questionaire.QuestionaireId  
      AND Questionaire.StatusCode = 'A'  
     WHERE TaskTypeCommunications.TaskTypeID = @i_TaskTypeID  
      AND (  
       TaskTypeCommunications.StatusCode = @vc_StatusCode  
       OR @vc_StatusCode IS NULL  
       )  
    ELSE  
     IF @v_TaskTypeName LIKE 'Schedule Procedure%'  
      SELECT DISTINCT TaskTypeCommunications.TaskTypeGeneralizedID  
       ,CodeGrouping.CodeGroupingName AS TypeName  
       ,CASE   
        WHEN (  
          SELECT TOP 1 1  
          FROM TaskTypeCommunications tc  
          WHERE tc.TaskTypeGeneralizedID = CodeGrouping.CodeGroupingID  
           AND StatusCode = 'A'  
          ) = 1  
         THEN 'Active'  
        ELSE 'InActive'  
        END StatusCode  
       ,'' LeadtimeDays  
      FROM TaskTypeCommunications WITH (NOLOCK)  
      INNER JOIN CodeGrouping WITH (NOLOCK) ON TaskTypeCommunications.TaskTypeGeneralizedID = CodeGrouping.CodeGroupingID  
      WHERE TaskTypeCommunications.TaskTypeID = @i_TaskTypeID  
       AND (  
        TaskTypeCommunications.StatusCode = @vc_StatusCode  
        OR @vc_StatusCode IS NULL  
        )  
          
     ELSE  
      IF @v_TaskTypeName = 'Program Enrollment'  
       SELECT DISTINCT TaskTypeCommunications.TaskTypeGeneralizedID  
        ,Program.ProgramName AS TypeName  
        ,CASE   
         WHEN (  
           SELECT TOP 1 1  
           FROM TaskTypeCommunications tc  
           WHERE tc.TaskTypeGeneralizedID = Program.ProgramId  
            AND StatusCode = 'A'  
           ) = 1  
          THEN 'Active'  
         ELSE 'InActive'  
         END StatusCode  
       FROM TaskTypeCommunications WITH (NOLOCK)  
       INNER JOIN Program WITH (NOLOCK) ON TaskTypeCommunications.TaskTypeGeneralizedID = Program.ProgramId  
        AND Program.StatusCode = 'A'  
       WHERE TaskTypeCommunications.TaskTypeID = @i_TaskTypeID  
        AND (  
         TaskTypeCommunications.StatusCode = @vc_StatusCode  
         OR @vc_StatusCode IS NULL  
         )  
      ELSE  
       IF @v_TaskTypeName IN (  
         'Communications'  
         )  
        SELECT DISTINCT TaskTypeCommunications.TaskTypeGeneralizedID  
         ,CommunicationType.CommunicationType AS TypeName  
       
         ,CASE   
          WHEN (  
            SELECT TOP 1 1  
            FROM TaskTypeCommunications tc  
            WHERE tc.TaskTypeGeneralizedID = CommunicationType.CommunicationTypeId  
             AND StatusCode = 'A'  
            ) = 1  
           THEN 'Active'  
          ELSE 'InActive'  
          END StatusCode  
            ,CommunicationType.LastModifiedDate
        FROM TaskTypeCommunications WITH (NOLOCK)  
        INNER JOIN CommunicationType WITH (NOLOCK) ON TaskTypeCommunications.TaskTypeGeneralizedID = CommunicationType.CommunicationTypeId  
         AND CommunicationType.StatusCode = 'A'  
        WHERE TaskTypeCommunications.TaskTypeID = @i_TaskTypeID  
         AND (  
          TaskTypeCommunications.StatusCode = @vc_StatusCode  
          OR @vc_StatusCode IS NULL  
          )  
         ELSE  
          IF @v_TaskTypeName = 'Medication Prescription'  
           SELECT DISTINCT TaskTypeCommunications.TaskTypeGeneralizedID  
            ,CodeSetDrug.DrugName AS TypeName  
            ,CASE   
             WHEN (  
               SELECT TOP 1 1  
               FROM TaskTypeCommunications tc  
               WHERE tc.TaskTypeGeneralizedID = CodeSetDrug.DrugCodeId  
                AND StatusCode = 'A'  
               ) = 1  
              THEN 'Active'  
             ELSE 'InActive'  
             END StatusCode  
           FROM TaskTypeCommunications WITH (NOLOCK)  
           INNER JOIN CodeSetDrug WITH (NOLOCK) ON TaskTypeCommunications.TaskTypeGeneralizedID = CodeSetDrug.DrugCodeId  
           WHERE TaskTypeCommunications.TaskTypeID = @i_TaskTypeID  
            AND (  
             TaskTypeCommunications.StatusCode = @vc_StatusCode  
             OR @vc_StatusCode IS NULL  
             )  
            
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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskTypeCommunications_Select] TO [FE_rohit.r-ext]
    AS [dbo];

