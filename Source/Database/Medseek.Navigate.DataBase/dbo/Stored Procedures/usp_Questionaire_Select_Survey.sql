/*    
-------------------------------------------------------------------------------------------------    
Procedure Name: usp_Questionaire_Select_Survey  23,1
Description   : This procedure is used for building data required for questionaire survey  
Created By    : Pramod    
Created Date  : 31-Mar-2010    
-------------------------------------------------------------------------------------------------    
Log History   :     
DD-Mon-YYYY  BY   DESCRIPTION    
22-Apr-10 Pramod Separated the questions and Answers to have better control from UI   
06-May-10 Pramod Included the user selected answers table for managing display in the UI  
17-May-10 Pramod Included data from userquestionaire and  userqstnairerecommendations  
19-May-10 Pramod included select for Default System Recommendation in the query  
9-Jul-10 Pramod IsShowPanel = 1 condition is commented as the hiding / unhiding of the panel  
    is going to be handled in survey page  
12-Jul-10 Pramod Included where clause to ignore Finish questionset in the query  
15-Jul-10 Pramod Changed the default recommendation to "Contact PCP immediately"  
19-Jul-10 Pramod Included the QuestionDataSourceName , QuestionControlType   
06-Sept-10 Rathnam Added QuestionaireID, QuestionaireName columns for recommendations  in SELECT statement
09-09-2010 NagaBabu Deleted NewUserDrugID1,NewUserDrugID2,OldUserDrugID1,OldUserDrugID2 fields
31-10-2011 NagaBabu Added 'AND UQA.AnswerID IS NOT NULL' to the select statement of Fourth resultset 
17-Nov-2011 NagaBabu Replacrd IsShowPanel ISINDICATOR by IsShowPanel ISINDICATOR NULL in @tblFilteredQuestionSet      
05-Jan-2011 Rathnam Added WHERE Answer.AnswerId IS NOT NULL tothe thrird select statement
21-03-2012 Rathnam commented the AND UQA.AnswerID IS NOT NULL as per dilip 
-------------------------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_Questionaire_Select_Survey]  
(  
 @i_AppUserId KEYID ,  
 @i_QuestionaireId KEYID ,  
 @i_UserQuestionaireID KEYID = NULL )  
AS  
BEGIN TRY     
    
 -- Check if valid Application User ID is passed    
      IF ( @i_AppUserId IS NULL )  
      OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END  
  
      DECLARE @tblFilteredQuestionSet TABLE  
      (  
        QuestionSetId KEYID ,  
        QuestionSetName SHORTDESCRIPTION ,  
        IsShowPanel ISINDICATOR NULL)  
  
      DECLARE @tblFilteredQuestionSetQuestion TABLE  
      (  
        QuestionSetQuestionId KEYID ,  
        QuestionSetId KEYID ,  
        IsRequiredQuestion ISINDICATOR ,  
        IsPrerequisite ISINDICATOR ,  
        QuestionId KEYID ,  
        QuestionText LONGDESCRIPTION ,  
        AnswerTypeId KEYID ,  
        AnswerTypeCode VARCHAR(20) ,  
        QuestionDataSourceName VARCHAR(500) ,  
        QuestionControlType VARCHAR(30) )   
 -- Returns all the questionsets having show panel enabled for the particular questionaire  
      INSERT INTO  
          @tblFilteredQuestionSet  
          (  
            QuestionSetId ,  
            QuestionSetName ,  
            IsShowPanel )  
          SELECT  
              QuestionSet.QuestionSetId ,  
              QuestionSet.QuestionSetName ,  
              QuestionaireQuestionSet.IsShowPanel  
          FROM  
              QuestionaireQuestionSet with (nolock)  
          INNER JOIN Questionaire  with (nolock) 
          ON  Questionaire.QuestionaireId = QuestionaireQuestionSet.QuestionaireId --AND QuestionaireQuestionSet.IsShowPanel = 1  
          INNER JOIN QuestionSet  with (nolock) 
          ON  QuestionSet.QuestionSetId = QuestionaireQuestionSet.QuestionSetId  
          WHERE  
              QuestionaireQuestionSet.QuestionaireId = @i_QuestionaireId  
              AND QuestionaireQuestionSet.StatusCode = 'A'  
          ORDER BY  
              QuestionaireQuestionSet.SortOrder ,  
              QuestionSet.QuestionSetName  
  
 -- This data will be displayed as Panels in the questionaire survey page  
      SELECT  
          QuestionSetId ,  
          QuestionSetName ,  
          IsShowPanel  
      FROM  
          @tblFilteredQuestionSet  
      WHERE  
          QuestionSetName <> 'Finish' -- Finish questionset is ignored for display  
  
      INSERT INTO  
          @tblFilteredQuestionSetQuestion  
          (  
            QuestionSetQuestionId ,  
            QuestionSetId ,  
            IsRequiredQuestion ,  
            IsPrerequisite ,  
      QuestionId ,  
            QuestionText ,  
            AnswerTypeId ,  
            AnswerTypeCode ,  
            QuestionDataSourceName ,  
            QuestionControlType )  
          SELECT  
              QuestionSetQuestion.QuestionSetQuestionId ,  
              QuestionSetQuestion.QuestionSetId ,  
              QuestionSetQuestion.IsRequiredQuestion ,  
              QuestionSetQuestion.IsPrerequisite ,  
              Question.QuestionId ,  
              Question.QuestionText ,  
              AnswerType.AnswerTypeId ,  
              AnswerType.AnswerTypeCode ,  
              UserControl.DataSourceName ,  
              UserControl.ControlType  
          FROM  
              QuestionSetQuestion WITH(NOLOCK) 
          INNER JOIN @tblFilteredQuestionSet FilteredQuestionSet  
          ON  FilteredQuestionSet.QuestionSetId = QuestionSetQuestion.QuestionSetId  
          INNER JOIN Question  WITH(NOLOCK)
          ON  Question.QuestionId = QuestionSetQuestion.QuestionId  
              AND Question.StatusCode = 'A'  
          LEFT OUTER JOIN AnswerType  WITH(NOLOCK)
          ON  AnswerType.AnswerTypeId = Question.AnswerTypeId  
          LEFT OUTER JOIN UserControl  WITH(NOLOCK)
          ON  UserControl.UserControlName = Question.UsercontrolName  
          WHERE  
              QuestionSetQuestion.StatusCode = 'A'  
  
 -- This data will be displayed under each specific Panels in the questionaire survey page  
      SELECT  
          QuestionSetQuestionId ,  
          QuestionSetId ,  
          IsRequiredQuestion ,  
          IsPrerequisite ,  
          QuestionId ,  
          QuestionText ,  
          AnswerTypeId ,  
          AnswerTypeCode ,  
          QuestionDataSourceName ,  
          QuestionControlType  
      FROM  
          @tblFilteredQuestionSetQuestion  
   
 -- This Answer data will be displayed for each specific Panels's questions in the questionaire survey page  
      SELECT  
          FilteredQuestionSetQuestion.QuestionSetQuestionId ,  
          Answer.AnswerId ,  
          Answer.AnswerDescription ,  
          Answer.AnswerString,
          Answer.AnswerLabel
      FROM  
          @tblFilteredQuestionSetQuestion FilteredQuestionSetQuestion  
      INNER JOIN Question  WITH(NOLOCK)
      ON  Question.QuestionId = FilteredQuestionSetQuestion.QuestionId  
          AND Question.StatusCode = 'A'  
      LEFT OUTER JOIN Answer  WITH(NOLOCK)
      ON  Answer.QuestionId = Question.QuestionId  
          AND Answer.StatusCode = 'A'
      WHERE Answer.AnswerId IS NOT NULL      
  
      IF @i_UserQuestionaireID IS NOT NULL  
         BEGIN  
  -- This will show selected Answer for individual questions under each Panels's questions in the questionaire survey page  
               SELECT  
                   UQA.UserQuestionaireAnswersID ,  
                   UQA.QuestionSetQuestionId ,  
                   UQA.AnswerID ,  
                   UQA.AnswerComments ,  
                   UQA.AnswerString  
               FROM  
                   UserQuestionaireAnswers UQA  WITH(NOLOCK)
               LEFT OUTER JOIN @tblFilteredQuestionSetQuestion FQSQ  
               ON  UQA.QuestionSetQuestionId = FQSQ.QuestionSetQuestionId  
               WHERE  
                   UQA.UserQuestionaireID = @i_UserQuestionaireID 
               --AND UQA.AnswerID IS NOT NULL     
  
  -- Default recommendation id and name to be used in the survey page  
               SELECT  
                   Recommendation.RecommendationId AS SysRecommendationId ,  
                   Recommendation.RecommendationName AS SysRecommendationName ,  
                   RecommendationRule.NextQuestionaireID AS NextQuestionaireID ,  
                   Questionaire.QuestionaireName AS QuestionaireName ,  
                   Recommendation.DefaultFrequencyOfTitrationDays AS DefaultFrequencyOfTitrationDays  
               FROM  
                   Recommendation  WITH(NOLOCK)
               INNER JOIN RecommendationRule  WITH(NOLOCK)
               ON  Recommendation.RecommendationId = RecommendationRule.RecommendationID  
               LEFT OUTER JOIN Questionaire  WITH(NOLOCK)
               ON  RecommendationRule.NextQuestionaireID = Questionaire.QuestionaireId  
               WHERE  
                   Recommendation.RecommendationName = 'We  call PCP immediately'  
  
  -- Get the date taken and other information  
               SELECT  
                   PatientId UserId ,  
                   QuestionaireId ,  
                   DateTaken ,  
                   CreatedDate ,  
                   CreatedByUserId ,  
                   Comments ,  
                   DateDue ,  
                   DateAssigned ,  
                   LastModifiedByUserId ,  
                   LastModifiedDate  
               FROM  
                   PatientQuestionaire  
               WHERE  
                   PatientQuestionaireId = @i_UserQuestionaireID  
  
  -- Display the latest record from UserQuestionaireRecommendations  
               SELECT TOP 1  
                   PatientQuestionaireRecommendations.RecommendationId ,  
                   PatientQuestionaireRecommendations.SysRecommendationId ,  
                   ( SELECT  
                         RecommendationName  
                     FROM  
                         Recommendation  
                     WHERE  
                         RecommendationId = PatientQuestionaireRecommendations.SysRecommendationId ) AS SysRecommendationName ,  
                   PatientQuestionaireRecommendations.FrequencyOfTitrationDays ,  
                   PatientQuestionaireRecommendations.CreatedByUserId ,  
                   PatientQuestionaireRecommendations.CreatedDate ,  
                   PatientQuestionaireRecommendations.ActionComment ,  
                   --UserQuestionaireRecommendations.OldUserDrugID1 ,  
                   --UserQuestionaireRecommendations.NewUserDrugID1 ,  
                   --UserQuestionaireRecommendations.OldUserDrugID2 ,  
                   --UserQuestionaireRecommendations.NewUserDrugID2 ,  
                   RecommendationRule.NextQuestionaireID AS NextQuestionaireID ,  
                   Questionaire.QuestionaireName AS QuestionaireName,  
                   ( SELECT  
                         DefaultFrequencyOfTitrationDays   
                     FROM  
                         Recommendation  
                     WHERE  
                         RecommendationId = PatientQuestionaireRecommendations.RecommendationId ) AS MasterFrequencyOfTitrationDays   
               FROM  
                   PatientQuestionaireRecommendations  WITH(NOLOCK)
               INNER JOIN RecommendationRule	WITH(NOLOCK)
               ON  PatientQuestionaireRecommendations.RecommendationId = RecommendationRule.RecommendationID  
               LEFT OUTER JOIN Questionaire  WITH(NOLOCK)
               ON  RecommendationRule.NextQuestionaireID = Questionaire.QuestionaireId  
               WHERE  
                   PatientQuestionaireRecommendations.PatientQuestionaireId = @i_UserQuestionaireID  
               ORDER BY  
                   PatientQuestionaireRecommendations.CreatedDate DESC  
         END  
END TRY  
BEGIN CATCH    
    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH     



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Questionaire_Select_Survey] TO [FE_rohit.r-ext]
    AS [dbo];

