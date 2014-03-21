/*  
-------------------------------------------------------------------------------------------------  
Procedure Name: usp_QuestionaireQuestionSet_SelectByQuestionSetId  
Description   : This procedure is used to get the detail related to questionset from  
    questionairequestionset table based on the QuestionSet id.   
Created By    : Pramod   
Created Date  : 6-Apr-2010  
-------------------------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY   DESCRIPTION  
-------------------------------------------------------------------------------------------------  
*/  
CREATE PROCEDURE [dbo].[usp_QuestionaireQuestionSet_SelectByQuestionSetId]  
( @i_AppUserId KEYID ,  
  @i_QuestionaireId KEYID,  
  @i_QuestionSetId KEYID  
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
  
------------ Selection from QuestionSet table table starts here ------------  
      SELECT  
           QuestionSet.QuestionSetId,  
           QuestionSet.QuestionSetName,  
           QuestionSet.Description,  
           QuestionaireQuestionSet.SortOrder,  
           QuestionaireQuestionSet.IsShowPanel,  
           QuestionaireQuestionSet.IsShowQuestionSetName,  
           QuestionaireQuestionSet.Createdbyuserid,  
           QuestionaireQuestionSet.CreatedDate,  
           QuestionaireQuestionSet.LastModifiedByUserId,  
     QuestionaireQuestionSet.LastModifiedDate,  
           QuestionaireQuestionSet.StatusCode  
      FROM  
           QuestionSet with (nolock)  
           INNER JOIN QuestionaireQuestionSet with (nolock)   
             ON QuestionSet.QuestionSetId = QuestionaireQuestionSet.QuestionSetId  
      WHERE  
   QuestionaireQuestionSet.QuestionaireId = @i_QuestionaireId  
        AND QuestionSet.QuestionSetId = @i_QuestionSetId   
        --AND QuestionSet.StatusCode = 'A'   
      ORDER BY  
          QuestionSet.SortOrder ,  
          QuestionSet.QuestionSetName  
  
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionaireQuestionSet_SelectByQuestionSetId] TO [FE_rohit.r-ext]
    AS [dbo];

