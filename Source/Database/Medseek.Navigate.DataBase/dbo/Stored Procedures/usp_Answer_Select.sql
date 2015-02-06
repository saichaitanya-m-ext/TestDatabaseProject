/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Answer_Select]  
Description   : This procedure is used for getting the answers for a question  
Created By    : Pramod  
Created Date  : 22-Mar-2010  
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
22-Mar-2010     Pramod   
----------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_Answer_Select]  
( @i_AppUserId KEYID,  
  @i_QuestionId KEYID,  
  @i_AnswerId KEYID = NULL  
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
---------------- All the Active Answers are retrieved --------  
      SELECT   
             Answer.AnswerId,  
    Answer.AnswerDescription,  
    Answer.Score,  
    Answer.AnswerString,  
    Answer.SortOrder,  
    Answer.CreatedByUserId,  
    Answer.CreatedDate,  
    Answer.LastModifiedByUserId,  
    Answer.LastModifiedDate,  
    Answer.StatusCode,  
    Question.QuestionId,  
    Question.QuestionText,  
    Question.Description AS QuestionDescription,
	Answer.AnswerLabel
        FROM  
             Answer   WITH (NOLOCK)
             INNER JOIN Question  WITH (NOLOCK) 
               ON Answer.QuestionId = Question.QuestionId  
       WHERE   
             Answer.QuestionId = @i_QuestionId  
         AND ( Answer.AnswerId = @i_AnswerId OR @i_AnswerId IS NULL )  
       ORDER BY  
          Answer.SortOrder,  
          Answer.AnswerDescription  
  
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Answer_Select] TO [FE_rohit.r-ext]
    AS [dbo];

