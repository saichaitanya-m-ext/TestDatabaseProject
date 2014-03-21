/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UserQuestionaireTitration_Recommendation]    
Description   : This procedure is used to set the Recommendations to the
                UserQuestionaire
Created By    : Rathnam
Created Date  : 09-Sept-2010.
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
6-Oct-10 Pramod Included IsTitration default to 1 in the insert of UserDrugCodes
9-Oct-10 Pramod Corrected the Insert into UserQuestionnaireDrugs to use @i_UserQuestionaireId
				(rather than the @o_UserQuestionaireId)
04-Nov-2010 Rathnam removed the @c_StopMedication IN ( 'D' , 'M' ) condition 
                   while inserting into UserQuestionaire table.				
17-Nov-2010 Pramod Included @i_PreviousUserQuestionaireId and utilized for updating old
Userquestionnaire entry and set to Inactive
------------------------------------------------------------------------------    
*/


CREATE PROCEDURE [dbo].[usp_UserQuestionaireTitration_Recommendation]
(
 @i_AppUserId KEYID
,@i_RecommendationID KEYID
,@i_PatientUserId KEYID
,@i_UserQuestionaireId KEYID
,@i_DaysToNextQuestionaire SMALLINT
,@vc_Comments VARCHAR(500)
,@i_NextQuestionaireID KEYID
,@o_UserQuestionaireID KEYID OUTPUT
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


      DECLARE @l_TranStarted BIT = 0

      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @l_TranStarted = 1  -- Indicator for start of transactions
         END
      ELSE
         SET @l_TranStarted = 0


      DECLARE
              @c_StopMedication CHAR(1)
             ,@i_DrugCodeID KEYID
             ,@i_FrequencyNumber INT
             ,@i_UserDrugID KEYID
             ,@i_PreviousUserQuestionaireId KEYID

      SELECT
          @c_StopMedication = StopMedication
      FROM
          RecommendationRule
      WHERE
          RecommendationId = @i_RecommendationID

      IF @c_StopMedication IS NULL OR @c_StopMedication = 'D'
         BEGIN

			   SELECT @i_PreviousUserQuestionaireId = PreviousPatientQuestionaireId
			     FROM PatientQuestionaire
			    WHERE PatientQuestionaireId = @i_UserQuestionaireId
			    
			   IF @i_PreviousUserQuestionaireId IS NOT NULL
				   UPDATE
					   PatientDrugCodes
				   SET
					   DiscontinuedDate = GETDATE()
					  ,EndDate = GETDATE()
					  ,LastModifiedByUserId = @i_AppUserId
					  ,LastModifiedDate = GETDATE()
					  ,StatusCode = 'I'
				   WHERE
					   PatientID = @i_PatientUserId
					   AND IsTitration = 1
					   AND PatientDrugId IN ( SELECT
											   UQD.PatientDrugID UserDrugID
										   FROM
											   PatientQuestionaireDrugs UQD
										   WHERE
											   UQD.PatientQuestionaireID = @i_PreviousUserQuestionaireId
										   ) --@i_UserQuestionaireId )

         END

      IF @i_NextQuestionaireID IS NOT NULL
         BEGIN
               INSERT INTO
                   PatientQuestionaire
                   (
                    DateDue
                   ,PatientId
                   ,QuestionaireID
                   ,DateTaken
                   ,CreatedByUserId
                   ,PreviousPatientQuestionaireId
                   )
               VALUES
                   (
                    GETDATE() + @i_DaysToNextQuestionaire
                   ,@i_PatientUserId
                   ,@i_NextQuestionaireID
                   ,NULL
                   ,@i_AppUserId
                   ,@i_UserQuestionaireId
                   )

               SET @o_UserQuestionaireID = SCOPE_IDENTITY()
         END   
		   DECLARE curDrug CURSOR
				   FOR SELECT
						   DrugCodeID
						  ,FrequencyNumber
					   FROM
						   RecommendationDrugs
					   WHERE
						   RecommendationId = @i_RecommendationID


		   OPEN curDrug
		   FETCH NEXT FROM curDrug INTO @i_DrugCodeID,@i_FrequencyNumber
		   WHILE @@FETCH_STATUS = 0
				 BEGIN
					   INSERT INTO
						   PatientDrugCodes
						   (
							PatientID
						   ,DrugCodeId
						   ,TimesPerDay
						   ,CreatedByUserId
						   ,StartDate
						   ,Comments
						   ,FrequencyOfTitrationDays
						   ,DatePrescribed
						   ,CareTeamUserID
						   ,IsTitration                           
						   )
					   VALUES
						   (
							@i_PatientUserId
						   ,@i_DrugCodeID
						   ,@i_FrequencyNumber
						   ,@i_AppUserId
						   ,GETDATE()
						   ,@vc_Comments
						   ,@i_FrequencyNumber
						   ,GETDATE()
						   ,@i_AppUserId
						   ,1
						   )

					   SET @i_UserDrugID = SCOPE_IDENTITY()

					   INSERT INTO
						   PatientQuestionaireDrugs
						   (
							PatientDrugID
						   ,CreatedByUserId
						   ,PatientQuestionaireID
						   )
					   VALUES
						   (
							@i_UserDrugID
						   ,@i_AppUserId
						   ,@i_UserQuestionaireId
						   )
					   FETCH NEXT FROM curDrug INTO @i_DrugCodeID ,@i_FrequencyNumber
				 END

		   CLOSE curDrug
		   DEALLOCATE curDrug
         

      IF ( @l_TranStarted = 1 )  -- If transactions are there, then commit
         BEGIN
               SET @l_TranStarted = 0
               COMMIT TRANSACTION
         END
      
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
    ON OBJECT::[dbo].[usp_UserQuestionaireTitration_Recommendation] TO [FE_rohit.r-ext]
    AS [dbo];

