    
/*    
--------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_PatientDashBoard_CarePlan]2,4010  
Description   : This proc is used to show the patient demographic information in to the PatientHomepage    
Created By    : Rathnam    
Created Date  : 12-Dec-2012   
---------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
04-Jan-2013 NagaBabu Added Third resultset for patientPopulation managedpopulation  
12-Jan-2013 NagaBabu Added fourth,fifth resultssets newly     
20-Mar-2013 P.V.P.Mohan modified UserQuestionaire to PatientQuestionaire  
   and modified columns in task and PatientGoal.  
03-APR-2013 Mohan Modified UserProcedureFrequency to PatientProcedureGroupFrequency,  
   UserQuestionaire to PatientQuestionaire .     
---------------------------------------------------------------------------------    
*/   
  
CREATE PROCEDURE [dbo].[usp_PatientDashBoard_CarePlan]  
(  
 @i_AppUserId KEYID  
,@i_PatientUserID KEYID  
)  
AS  
BEGIN  
      BEGIN TRY     
    
 -- Check if valid Application User ID is passed    
            IF ( @i_AppUserId IS NULL )  
            OR ( @i_AppUserId <= 0 )  
               BEGIN  
                     RAISERROR ( N'Invalid Application User ID %d passed.'  
                     ,17  
                     ,1  
                     ,@i_AppUserId )  
               END  
  
            -------------------CarePlan_ProcessMeasure------------------------------------------------------------------    
     
   DECLARE @i_Top INT = 5  
     
   SELECT TOP (@i_Top)   
   csp.CodeGroupingID ,  
   csp.CodeGroupingName,     
   'Once every' + ' ' + CAST(( upf.FrequencyNumber) AS VARCHAR) +   
   CASE  
     WHEN upf.Frequency = 'D' THEN 'Day'  
     WHEN upf.Frequency = 'W' THEN 'Week'  
     WHEN upf.Frequency = 'M' THEN 'Month'  
     WHEN upf.Frequency = 'Y' THEN 'Year'  
   END AS PatientGoal,  
   CONVERT(VARCHAR(10),upf.EffectiveStartDate,101) EffectiveStartDate,  
   CASE WHEN LEN(csp.CodeGroupingName)>14 THEN SUBSTRING(CodeGroupingName,1,14)+ '...' ELSE csp.CodeGroupingName END ProcedureGroupShortName   
   FROM  PatientProcedureGroupFrequency upf WITH(NOLOCK)  
   INNER JOIN CodeGrouping csp WITH(NOLOCK)  
   ON csp.CodeGroupingID = upf.CodeGroupingID  
   WHERE upf.PatientId = @i_PatientUserID  
   ORDER BY upf.EffectiveStartDate DESC  
     
        
   
            SELECT  
    Program.ProgramId ,  
    Program.ProgramName  
   FROM  
    PatientProgram WITH(NOLOCK)  
   INNER JOIN Program WITH(NOLOCK)  
    ON PatientProgram.ProgramId = Program.ProgramId  
   WHERE PatientID = @i_PatientUserID   
      
     
 --------------------------------------------------------------------------  
            
            ;WITH cteQ  
            AS  
            (  
            SELECT TOP (@i_Top)  
                tblUQ.UserQuestionaireId  
               ,tblUQ.UserId  
               ,tblUQ.QuestionaireId  
               ,QuestionaireName  
               ,DateTaken  
               ,tblUQ.CreatedDate  
               ,tblUQ.CreatedByUserId  
               ,tblUQ.Comments  
               ,DateDue  
               ,DateAssigned  
               --,Name DiseaseName  
               ,tblUQ.IsPreventive  
               ,ISNULL(CAST(TotalScore AS VARCHAR(10)),'') Score   
               ,ISNULL(( SELECT  
                      TOP 1 RangeName  
                  FROM  
                      QuestionnaireScoring WITH(NOLOCK)  
                  WHERE  
                      TotalScore BETWEEN RangeStartScore AND RangeEndScore  
                  AND QuestionnaireScoring.QuestionaireId = tblUQ.QuestionaireId      
                ),'') AS 'Range'  
               ,tblUQ.ProgramId   
               ,ProgramName   
               ,IsMedicationTitration   
               ,QuestionnaireFrequency.QuestionnaireFrequencyID  
               ,'Once every ' + CAST(QuestionnaireFrequency.FrequencyNumber AS VARCHAR(10)) + CASE WHEN QuestionnaireFrequency.Frequency = 'D' THEN ' days'  
                        WHEN QuestionnaireFrequency.Frequency = 'W' THEN ' weeks'  
                        WHEN QuestionnaireFrequency.Frequency = 'M' THEN ' months'  
                        WHEN QuestionnaireFrequency.Frequency = 'Y' THEN ' years'  
                      END AS Patientgoal   
      --,Task.IsCareGap  
      ,0 AS IsCareGap  
      ,CASE WHEN DateDue < GETDATE() THEN 0 ELSE 1 END IsEdit                       
            FROM  
    (SELECT  
     PatientQuestionaire.PatientQuestionaireId UserQuestionaireId  
       ,PatientQuestionaire.PatientId UserId  
       ,PatientQuestionaire.QuestionaireId  
       ,Questionaire.QuestionaireName  
       ,PatientQuestionaire.DateTaken  
       ,PatientQuestionaire.CreatedDate  
       ,PatientQuestionaire.CreatedByUserId  
       ,PatientQuestionaire.Comments  
       ,PatientQuestionaire.DateDue  
       ,PatientQuestionaire.DateAssigned  
       ,PatientQuestionaire.PreviousPatientQuestionaireId  
       --,Disease.Name  
       ,ISNULL(PatientQuestionaire.IsPreventive , 0)AS IsPreventive  
       ,PatientQuestionaire.TotalScore  
       ,Program.ProgramId  
       ,Program.ProgramName  
       ,CASE WHEN QuestionaireType.QuestionaireTypeName = 'Medication Titration' THEN 'TRUE' ELSE 'FALSE' END AS  IsMedicationTitration  
    FROM  
     PatientQuestionaire WITH(NOLOCK)  
    INNER JOIN Questionaire WITH(NOLOCK)  
     ON Questionaire.QuestionaireId = PatientQuestionaire.QuestionaireId  
       AND PatientQuestionaire.StatusCode <> 'I'   
       AND Questionaire.StatusCode = 'A'  
    LEFT JOIN QuestionaireType QuestionaireType WITH(NOLOCK)  
      ON Questionaire.QuestionaireTypeId = QuestionaireType.QuestionaireTypeId  
    --LEFT OUTER JOIN Disease WITH(NOLOCK)  
    -- ON PatientQuestionaire.DiseaseId = Disease.DiseaseId  
    LEFT OUTER JOIN Program WITH(NOLOCK)  
     ON Program.ProgramId = PatientQuestionaire.ProgramId       
    WHERE  
     PatientQuestionaire.PatientId = @i_PatientUserID )tblUQ  
            LEFT JOIN QuestionnaireFrequency WITH(NOLOCK)  
    ON tblUQ.UserId = QuestionnaireFrequency.PatientId  
    AND tblUQ.QuestionaireId = QuestionnaireFrequency.QuestionaireId    
   LEFT JOIN Task WITH(NOLOCK)  
    ON Task.PatientTaskID = tblUQ.UserQuestionaireId   
   ORDER BY tblUQ.UserQuestionaireId DESC   
   )   
     
   SELECT   
   UserQuestionaireId  
               ,UserId  
               ,QuestionaireId  
               ,QuestionaireName  
               ,DateTaken  
               ,CONVERT(VARCHAR(10),CreatedDate,101) AS CreatedDate  
               ,CreatedByUserId  
               ,Comments  
               ,CONVERT(VARCHAR(10),DateDue,101) AS DateDue
               ,CONVERT(VARCHAR(10),DateAssigned,101) AS DateAssigned
               --,Name DiseaseName  
               ,IsPreventive  
               ,Score + CASE WHEN [Range] = '' THEN '' ELSE '/' + [Range] END 'Score/Range'  
               ,ProgramId   
               ,ProgramName   
               ,IsMedicationTitration   
               ,QuestionnaireFrequencyID  
               ,Patientgoal   
      --,Task.IsCareGap  
      ,IsCareGap  
      ,IsEdit   
     
    FROM cteQ  
---------------------------------------------------------------------------------------------------  
  
  SELECT DISTINCT TOP (@i_Top)   
   --ISNULL(( SELECT  
   --     PatientGoalprogresslog.PatientGoalId  
   --    FROM  
   --     PatientGoalprogresslog  
   --    WHERE  
   --     PatientGoalprogresslogId = @i_PatientGoalProgressLogId  
   --  ) , '') AS SelectedPatientGoalId  
   0 AS SelectedPatientGoalId  
   ,PatientGoal.PatientGoalId  
   ,PatientGoal.PatientId UserId  
   ,LifeStyleGoal AS Description  
   ,SUBSTRING(PatientGoal.Description , 0 , 50) AS ShortDescription  
   ,CASE PatientGoal.DurationUnits  
    WHEN 'D' THEN 'Days'  
    WHEN 'W' THEN 'Weeks'  
    WHEN 'M' THEN 'Months'  
    WHEN 'Q' THEN 'Quarters'  
    WHEN 'Y' THEN 'Years'  
    ELSE ''  
   END DurationUnits  
   ,PatientGoal.DurationTimeline  
   ,CASE PatientGoal.DurationUnits  
    WHEN 'D' THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Days'  
    WHEN 'W' THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Weeks'  
    WHEN 'M' THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Months'  
    WHEN 'Q' THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Quarters'  
    WHEN 'Y' THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Years'  
    ELSE ''  
   END Duration  
   ,CASE PatientGoal.ContactFrequencyUnits  
    WHEN 'D' THEN 'Days'  
    WHEN 'W' THEN 'Weeks'  
    WHEN 'M' THEN 'Months'  
    WHEN 'Q' THEN 'Quarters'  
    WHEN 'Y' THEN 'Years'  
    ELSE ''  
   END ContactFrequencyUnits  
   ,PatientGoal.ContactFrequency  
   ,CASE PatientGoal.ContactFrequencyUnits  
    WHEN 'D' THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Days'  
    WHEN 'W' THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Weeks'  
    WHEN 'M' THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Months'  
    WHEN 'Q' THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Quarters'  
    WHEN 'Y' THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Years'  
    ELSE ''  
   END ContactFrequencyDuration  
   --,PatientGoal.CommunicationTypeId  
   --,CommunicationType.CommunicationType AS CommunicationTypeName  
   --,PatientGoal.CancellationReason  
   ,PatientGoal.Comments  
   ,CASE PatientGoal.StatusCode  
    WHEN 'A' THEN 'Active'  
    WHEN 'I' THEN 'InActive'  
   END AS StatusDescription  
   ,CONVERT(VARCHAR(10),PatientGoal.StartDate,101) AS  StartDate
   ,PatientGoal.LifeStyleGoalId  
   ,LifeStyleGoals.LifeStyleGoal  
   ,CONVERT(VARCHAR(10),PatientGoal.GoalCompletedDate,101) AS GoalCompletedDate
   ,PatientGoal.ProgramId  
   ,CASE PatientGoal.GoalStatus  
    WHEN 'C' THEN 'Complete'  
    WHEN 'D' THEN 'Discontinue'  
    WHEN 'I' THEN 'In-progress'  
   END AS GoalStatus  
   ,PatientGoal.CreatedByUserId  
   ,CONVERT(VARCHAR(10),PatientGoal.CreatedDate,101) AS CreatedDate
   ,PatientGoal.LastModifiedByUserId  
   ,CONVERT(VARCHAR(10),PatientGoal.LastModifiedDate,101) AS LastModifiedDate
   ,Dbo.ufn_GetUserNameByID(PatientGoal.AssignedCareProviderId) AS AssignedTo  
   ,( SELECT TOP 1  
    CONVERT(VARCHAR(10),PatientGoalprogresslog.FollowUpDate,101)  
   FROM  
    PatientGoalprogresslog WITH(NOLOCK)  
   WHERE  
    PatientGoalId = PatientGoal.PatientGoalId  
   ORDER BY  
    PatientGoalProgressLogId DESC  
   ) AS FollowUpDate  
   ,PatientGoal.ProgramId  
  FROM  
   PatientGoal WITH(NOLOCK)  
  INNER JOIN LifeStyleGoals WITH(NOLOCK)  
   ON LifeStyleGoals.LifeStyleGoalId = PatientGoal.LifeStyleGoalId  
  WHERE PatientGoal.PatientId = @i_PatientUserID  
  AND PatientGoal.StatusCode = 'A'  
  AND LifeStyleGoals.StatusCode = 'A'  
  ORDER BY  
   StartDate DESC  
       
                  
END TRY  
BEGIN CATCH    
---------------------------------------------------------------------------------------------------------------------------------    
    -- Handle exception    
            DECLARE @i_ReturnedErrorID INT  
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
            RETURN @i_ReturnedErrorID  
END CATCH  
END    
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientDashBoard_CarePlan] TO [FE_rohit.r-ext]
    AS [dbo];

