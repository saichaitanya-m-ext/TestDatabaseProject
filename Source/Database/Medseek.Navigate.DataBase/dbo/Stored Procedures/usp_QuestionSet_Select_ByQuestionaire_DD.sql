/*    
----------------------------------------------------------------------------------------    
Procedure Name: usp_QuestionSet_Select_ByQuestionaire_DD    
Description   : This procedure is used for bringing all the QuestionSet for specific questionaire    
Created By    : Pramod
Created Date  : 29-Mar-2010    
-----------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
21-Apr-10 Pramod Included the new parameter @i_IgnoreQuestionSetID
-----------------------------------------------------------------------------------------    
*/  
  
CREATE PROCEDURE [dbo].[usp_QuestionSet_Select_ByQuestionaire_DD]  
( @i_AppUserId KEYID,
  @i_QuestionaireId KEYID,
  @i_IgnoreQuestionSetID KeyID
)  
AS  
BEGIN TRY     
    
 -- Check if valid Application User ID is passed    
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END    
    
------------ Selection from QuestionSet table starts here ------------    
      SELECT  
          QuestionaireQuestionSet.QuestionaireQuestionSetId,
          QuestionaireQuestionSet.QuestionSetId,
          QuestionSet.QuestionSetName
      FROM QuestionaireQuestionSet with (nolock)
           INNER JOIN QuestionSet with (nolock)
             ON QuestionaireQuestionSet.QuestionSetId = QuestionSet.QuestionSetId
      WHERE QuestionaireQuestionSet.QuestionaireId = @i_QuestionaireId
        AND QuestionaireQuestionSet.QuestionSetId <> @i_IgnoreQuestionSetID
        AND QuestionaireQuestionSet.StatusCode = 'A'
      ORDER BY 
            QuestionaireQuestionSet.SortOrder,
			QuestionSet.QuestionSetName
       
END TRY  
BEGIN CATCH    
    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException   
     @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionSet_Select_ByQuestionaire_DD] TO [FE_rohit.r-ext]
    AS [dbo];

