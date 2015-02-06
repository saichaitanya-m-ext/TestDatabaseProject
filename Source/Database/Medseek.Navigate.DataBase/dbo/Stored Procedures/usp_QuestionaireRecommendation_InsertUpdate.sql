/*    select * from questionaire
-------------------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_QuestionaireRecommendation_InsertUpdate]    
Description   : This procedure is used to insert records into QuestionaireRecommendation  table and   
    MedicationQuestionaire through TableType Params.     
Created By    : P.V.P.Mohan   
Created Date  : 30-Oct-2012    
-------------------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
  
-------------------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_QuestionaireRecommendation_InsertUpdate] --23,39,2,0,NULL,'12',NULL,'A',null,null

(
 @i_AppUserId KEYID
,@i_QuestionaireId KEYID
,@i_RecommendationId KEYID
,@i_StopMedication ISINDICATOR = 0
,@t_tQuestionaireRecommendation TQUESTIONAIRERECOMMENDATION READONLY 
,@vc_DaysToNextQuestionnaire CHAR(2)
,@i_NextQuestionaireId KEYID = NULL
,@vc_StatusCode STATUSCODE = 'A'
,@i_QuestionaireRecommendationId INT
,@o_QuestionaireRecommendationId INT OUTPUT
)
AS
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
    
------------------insert operation into Questionaire table-----     
      DECLARE @l_TranStarted BIT = 0
      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @l_TranStarted = 1  -- Indicator for start of transactions
         END
      ELSE
         BEGIN
               SET @l_TranStarted = 0
         END
      IF @i_QuestionaireRecommendationId IS NULL OR @i_QuestionaireRecommendationId = 0
         BEGIN

               INSERT INTO
                   QuestionaireRecommendation
                   (
                     QuestionaireId
                   ,RecommendationId
                   ,StopMedication
                   ,DaysToNextQuestionnaire
                   ,StatusCode
                   ,NextQuestionaireId
                   ,CreatedByUserId
                   )
               VALUES
                   (
                    @i_QuestionaireId
                   ,@i_RecommendationId
                   ,@i_StopMedication
                   ,@vc_DaysToNextQuestionnaire
                   ,'A'
                   ,@i_NextQuestionaireId
                   ,@i_AppUserId
                   )
                   
               SET @o_QuestionaireRecommendationId = SCOPE_IDENTITY()
               
               INSERT INTO
                   MedicationQuestionaire
                   (
                    QuestionaireRecommendationId
                   ,DrugCodeId
                   ,RecommendationNumber
                   ,RecommendationFrequency
                   ,DurationNumber
                   ,DurationFrequency
                   ,CreatedByUserId
                   )
                   SELECT
                       @o_QuestionaireRecommendationId
                      ,t.DrugCodeId
                      ,t.RecommendationNumber
                      ,t.RecommendationFrequency
                      ,t.DurationNumber
                      ,t.DurationFrequency
                      ,@i_AppUserId
                   FROM
                       @t_tQuestionaireRecommendation t
         END
      ELSE
         BEGIN
               UPDATE
                   QuestionaireRecommendation
               SET
                   QuestionaireId = @i_QuestionaireId
                  ,RecommendationId = @i_RecommendationId
                  ,StopMedication = @i_StopMedication
                  ,DaysToNextQuestionnaire = @vc_DaysToNextQuestionnaire
                  ,StatusCode = @vc_StatusCode
                  ,NextQuestionaireId = @i_NextQuestionaireId
                  ,LastModifiedByUserId = @i_AppUserId
                  ,LastModifiedDate = GETDATE()
               WHERE
                   QuestionaireRecommendationId = @i_QuestionaireRecommendationId

               DELETE  FROM
                       MedicationQuestionaire
               WHERE
                       QuestionaireRecommendationId = @i_QuestionaireRecommendationId

               INSERT INTO
                   MedicationQuestionaire
                   (
                     QuestionaireRecommendationId
                   ,DrugCodeId
                   ,RecommendationNumber
                   ,RecommendationFrequency
                   ,DurationNumber
                   ,DurationFrequency
                   ,CreatedByUserId
                   )
                   SELECT
                       @i_QuestionaireRecommendationId
                      ,t.DrugCodeId
                      ,t.RecommendationNumber
                      ,t.RecommendationFrequency
                      ,t.DurationNumber
                      ,t.DurationFrequency
                      ,@i_AppUserId
                   FROM
                       @t_tQuestionaireRecommendation t

         END

      IF ( @l_TranStarted = 1 )  -- If transactions are there, then commit
         BEGIN
               SET @l_TranStarted = 0
               COMMIT TRANSACTION
         END
END TRY  
------------------------------------------------------------------------------------------------------------------------------  
BEGIN CATCH    
    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH  

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionaireRecommendation_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

