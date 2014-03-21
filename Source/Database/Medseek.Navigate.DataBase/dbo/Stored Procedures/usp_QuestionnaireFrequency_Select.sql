/*          
------------------------------------------------------------------------------          
Procedure Name: usp_QuestionnaireFrequency_Select          
Description   : This procedure is used to Select records from QuestionnaireFrequency table      
Created By    : NagaBabu         
Created Date  : 30-Aug-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION    
01-Sep-2010 NagaBabu Deleted ScheduleQuestionaireId Field this sp while this field was    
      deleted from QuestionnaireFrequency table and Added StatusCode as input Perameter    
23-Sep-10 Pramod For Statuscode parameter default is set to NULL for showing both active and inactive records    
06-Jun-11 Rathnam added DiseaseiD, ispreventive columns to the select stateement    
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in     
            the place of CohortListID and PopulationDefinitionUsers    
------------------------------------------------------------------------------          
*/    
CREATE PROCEDURE [dbo].[usp_QuestionnaireFrequency_Select]    
(    
 @i_AppUserId KeyId ,        
 @i_QuestionaireId KeyId = NULL,    
 @i_CareTeamId KeyId = NULL,    
 @i_PopulationDefinitionID KeyId = NULL,    
 @i_ProgramId KeyId = NULL,    
 @i_UserId KeyId = NULL,    
 @v_StatusCode StatusCode = NULL     
)    
AS    
BEGIN TRY        
   SET NOCOUNT ON        
          
   -- Check if valid Application User ID is passed          
   IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )        
    BEGIN        
     RAISERROR ( N'Invalid Application User ID %d passed.' ,        
     17 ,        
     1 ,        
     @i_AppUserId )        
    END      
        
   SELECT     
    QuestionnaireFrequency.QuestionnaireFrequencyID ,    
    QuestionnaireFrequency.FrequencyNumber ,    
    CASE QuestionnaireFrequency.Frequency     
     WHEN 'D' THEN 'Day(s)'    
     WHEN 'W' THEN 'Week(s)'    
     WHEN 'M' THEN 'Month(s)'    
     WHEN 'Y' THEN 'Year(s)'    
    END AS Frequency ,    
    QuestionnaireFrequency.QuestionaireId ,    
    Questionaire.QuestionaireName ,    
    QuestionnaireFrequency.CareTeamId ,    
    QuestionnaireFrequency.PopulationDefinitionID ,    
    QuestionnaireFrequency.ProgramId ,    
    QuestionnaireFrequency.PatientId as UserId ,    
    CASE QuestionnaireFrequency.StatusCode     
     WHEN 'A' THEN 'Active'    
     WHEN 'I' THEN 'InActive'    
    END AS StatusDescription ,    
    QuestionnaireFrequency.CreatedByUserId ,    
    QuestionnaireFrequency.CreatedDate ,    
    QuestionnaireFrequency.LastModifiedDate ,    
    QuestionnaireFrequency.LastModifiedByUserId,    
    Disease.Name,    
    QuestionnaireFrequency.IsPreventive    
   FROM    
    QuestionnaireFrequency WITH(NOLOCK)    
   INNER JOIN Questionaire WITH(NOLOCK)    
    ON QuestionnaireFrequency.QuestionaireId = Questionaire.QuestionaireId     
   LEFT OUTER JOIN Disease  WITH(NOLOCK)    
       ON QuestionnaireFrequency.DiseaseId = Disease.DiseaseId       
   WHERE    
    ( QuestionnaireFrequency.QuestionaireId = @i_QuestionaireId AND @i_QuestionaireId IS NOT NULL     
   AND QuestionnaireFrequency.CareTeamId IS NULL AND QuestionnaireFrequency.PopulationDefinitionID IS NULL    
   AND QuestionnaireFrequency.ProgramId IS NULL AND QuestionnaireFrequency.PatientId IS NULL    
   OR  @i_QuestionaireId IS NULL )     
    AND( QuestionnaireFrequency.CareTeamId = @i_CareTeamId OR @i_CareTeamId IS NULL )    
    AND( QuestionnaireFrequency.PopulationDefinitionID = @i_PopulationDefinitionID OR @i_PopulationDefinitionID IS NULL )    
    AND( QuestionnaireFrequency.ProgramId = @i_ProgramId OR @i_ProgramId IS NULL )    
    AND( QuestionnaireFrequency.PatientId = @i_UserId OR @i_UserId IS NULL )     
    AND( Questionaire.StatusCode = 'A')    
    AND( QuestionnaireFrequency.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL)    
   ORDER BY    
    Questionaire.QuestionaireName    
END TRY            
       
BEGIN CATCH    
    -- Handle exception            
      DECLARE @i_ReturnedErrorID INT      
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId      
      
      RETURN @i_ReturnedErrorID      
END CATCH 
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionnaireFrequency_Select] TO [FE_rohit.r-ext]
    AS [dbo];

