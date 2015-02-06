/*    
-------------------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_QuestionnaireScoring_Insert]    
Description   : This procedure is used to insert records into QuestionnaireScoring  table.     
Created By    : Gurumoorthy.V  
Created Date  : 28-Sep-2011    
-------------------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
-------------------------------------------------------------------------------------------------    
*/

CREATE PROCEDURE [dbo].[usp_QuestionnaireScoring_Insert]
(
	 @i_AppUserId INT
	,@i_QuestionaireId KEYID
	,@tbl_tQuestionaireScoring TQUESTIONAIRESCORING READONLY
	,@vc_StatusCode VARCHAR(1)
	,@i_QuestionnaireScoringID INT OUTPUT
)
AS
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
    
------------------insert operation into QuestionnaireScoring   table-----     
		DELETE FROM QuestionnaireScoring 
		WHERE QuestionaireId=@i_QuestionaireId

      INSERT INTO
          QuestionnaireScoring
          (
           QuestionaireId
          ,RangeStartScore
          ,RangeEndScore
          ,RangeName
          ,RangeDescription
          ,StatusCode
          ,CreatedByUSerID
          )
          SELECT
              @i_QuestionaireId
             ,RangeStartScore
             ,RangeEndScore
             ,RangeName
             ,RangeDescription
             ,@vc_StatusCode
             ,@i_AppUserId
          FROM
              @tbl_tQuestionaireScoring
              
          SELECT @i_QuestionnaireScoringID = @@ROWCOUNT    
END TRY
BEGIN CATCH    
    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH  
  
  
  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionnaireScoring_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

