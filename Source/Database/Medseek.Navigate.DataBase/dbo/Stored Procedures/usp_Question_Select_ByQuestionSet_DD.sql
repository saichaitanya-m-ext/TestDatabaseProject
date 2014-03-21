/*    
----------------------------------------------------------------------------------------    
Procedure Name: usp_Question_Select_ByQuestionSet_DD    
Description   : This procedure is used for the Questions for a specific questionset
Created By    : Pramod
Created Date  : 29-Mar-2010    
-----------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
19-Aug-2010 NagaBabu Added ORDER BY clause to the select statement    
-----------------------------------------------------------------------------------------    
*/  
  
CREATE PROCEDURE [dbo].[usp_Question_Select_ByQuestionSet_DD]  
( @i_AppUserId KEYID,
  @i_QuestionSetID KeyID
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
    
------------ Selection from Question table starts here ------------    
      SELECT  
		  QuestionSetQuestion.QuestionSetQuestionId,
	      Question.QuestionId,  
		  Question.Description,  
		  Question.QuestionText  
      FROM  
		  QuestionSetQuestion with (nolock) 
	  INNER JOIN Question with (nolock) 
	      ON QuestionSetQuestion.QuestionId = Question.QuestionId
      WHERE 
          QuestionSetQuestion.QuestionSetId = @i_QuestionSetID
		  AND QuestionSetQuestion.StatusCode = 'A'
	  ORDER BY
		  Question.Description  	  
       
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
    ON OBJECT::[dbo].[usp_Question_Select_ByQuestionSet_DD] TO [FE_rohit.r-ext]
    AS [dbo];

