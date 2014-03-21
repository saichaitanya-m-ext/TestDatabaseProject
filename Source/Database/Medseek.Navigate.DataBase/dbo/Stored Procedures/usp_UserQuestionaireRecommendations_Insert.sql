/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserQuestionaireRecommendations_Insert    
Description   : This procedure is used to insert record into 
				UserQuestionaireRecommendations table
Created By    : Pramod    
Created Date  : 12-May-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
08-SEPT-2010  Rathnam  Call the usp_UserQuestionaireTitration_Recommendation 
                       for Recommendation Logic   
6-Oct-2010 Pramod Removed the DateDue = @d_ReassessmentDate from the update UserQuestionaire
07-Mar-2011 NagaBabu Removed null value to @i_RecommendationId by default, and added null to @v_ActionComment by default
29-Feb-2012 Rathnam added @b_IsTitration parameter and commented the RaiseError statement as per Dilip Discussion
------------------------------------------------------------------------------    
*/ 
CREATE PROCEDURE [dbo].[usp_UserQuestionaireRecommendations_Insert]
(
 @i_AppUserId KEYID
,@i_UserQuestionaireId KEYID
,@i_RecommendationId KEYID 
,@i_SysRecommendationId KEYID = NULL
,@i_FrequencyOfTitrationDays SMALLINT
,@v_ActionComment VARCHAR(500)= NULL
,@d_SurveyDate DATETIME
,@d_ReassessmentDate DATETIME = NULL
,@i_PatientUserId KEYID
,@i_NextQuestionaireID KEYID 
,@o_UserQuestionaireID KEYID OUTPUT
,@b_IsTitration BIT = 0
)
AS
BEGIN TRY
      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsInserted INT = 0 
	-- Check if valid Application User ID is passed    
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      DECLARE @l_TranStarted BIT = 0

      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @l_TranStarted = 1  -- Indicator for start of transactions
         END
      ELSE
         SET @l_TranStarted = 0
	  IF @b_IsTitration  = 1
		  BEGIN
			  INSERT INTO
				  PatientQuestionaireRecommendations
				  (
				   PatientQuestionaireId
				  ,RecommendationId
				  ,CreatedByUserId
				  ,SysRecommendationId
				  ,FrequencyOfTitrationDays
				  ,ActionComment
				  )
			  VALUES
				  (
				   @i_UserQuestionaireId
				  ,@i_RecommendationId
				  ,@i_AppUserId
				  ,@i_SysRecommendationId
				  ,@i_FrequencyOfTitrationDays
				  ,@v_ActionComment
				  )
			END
      --SET @l_numberOfRecordsInserted = @@ROWCOUNT

      --IF @l_numberOfRecordsInserted <> 1
      --   BEGIN
      --         RAISERROR ( N'Invalid row count %d in insert UserQuestionaireRecommendations'
      --         ,17
      --         ,1
      --         ,@l_numberOfRecordsInserted )
      --   END

      UPDATE
          PatientQuestionaire
          
      SET
          DateTaken = @d_SurveyDate
         --,DateDue = @d_ReassessmentDate
         ,LastModifiedByUserId = @i_AppUserId
         ,LastModifiedDate = GETDATE()
         ,StatusCode = CASE
                            WHEN @i_FrequencyOfTitrationDays IS NULL THEN 'I'
                            ELSE 'C'
                       END
         ,TotalScore = (SELECT dbo.GetMaxScoreByUserQuestionaireID (@i_UserQuestionaireId))              
      WHERE
          PatientQuestionaireId = @i_UserQuestionaireId
          
          
       EXEC usp_UserQuestionaireTitration_Recommendation
			@i_AppUserId = @i_AppUserId,
			@i_RecommendationID = @i_RecommendationId,
			@i_PatientUserId = @i_PatientUserId,
			@i_UserQuestionaireId = @i_UserQuestionaireId,
			@i_DaysToNextQuestionaire = @i_FrequencyOfTitrationDays,
			@vc_Comments = @v_ActionComment,
			@i_NextQuestionaireID = @i_NextQuestionaireID,
			@o_UserQuestionaireID = @o_UserQuestionaireID OUTPUT
          

      IF ( @l_TranStarted = 1 )  -- If transactions are there, then commit
         BEGIN
               SET @l_TranStarted = 0
               COMMIT TRANSACTION
         END
      ELSE
         BEGIN
               ROLLBACK TRANSACTION
         END

      RETURN 0
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
    ON OBJECT::[dbo].[usp_UserQuestionaireRecommendations_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

