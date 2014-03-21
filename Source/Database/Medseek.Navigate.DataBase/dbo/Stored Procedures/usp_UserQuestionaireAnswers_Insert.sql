/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserQuestionaireAnswers_Insert    
Description   : This procedure is used to insert record into UserQuestionaireAnswers table
Created By    : Pramod    
Created Date  : 04-May-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserQuestionaireAnswers_Insert]  
(  
	@i_AppUserId KeyID,
	@t_UserQuestionaireAnswers UserQuestionaireAnswersTbl Readonly
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT = 0 
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR 
		   ( N'Invalid Application User ID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	END  

	IF EXISTS (SELECT 1 FROM @t_UserQuestionaireAnswers) -- Run these steps only when there are records
	BEGIN
		DECLARE @l_TranStarted   BIT = 0
		IF( @@TRANCOUNT = 0 )  
		BEGIN
			BEGIN TRANSACTION
			SET @l_TranStarted = 1  -- Indicator for start of transactions
		END
		ELSE
			SET @l_TranStarted = 0  
	    	
		DELETE FROM UserQuestionaireAnswers
		 WHERE EXISTS ( SELECT 1 FROM @t_UserQuestionaireAnswers UQA
						 WHERE UQA.UserQuestionaireID = UserQuestionaireAnswers.UserQuestionaireID
						   AND UQA.QuestionSetQuestionId = UserQuestionaireAnswers.QuestionSetQuestionId
					  )
		 
		INSERT INTO UserQuestionaireAnswers
		   ( UserQuestionaireID
			 ,QuestionSetQuestionId
			 ,AnswerID
			 ,AnswerComments
			 ,AnswerString
			 ,CreatedByUserId
		   )
		SELECT
			 UserQuestionaireID
			 ,QuestionSetQuestionId
			 ,AnswerID
			 ,AnswerComments
			 ,AnswerString
			 ,@i_AppUserId
		  FROM @t_UserQuestionaireAnswers
		  
		SET @l_numberOfRecordsInserted = @@ROWCOUNT
	      
		IF @l_numberOfRecordsInserted = 0
		BEGIN          
			RAISERROR      
				(  N'Invalid row count %d in insert UserQuestionaireAnswers'
					,17      
					,1      
					,@l_numberOfRecordsInserted                 
				)              
		END 
		
		IF( @l_TranStarted = 1 )  -- If transactions are there, then commit
			BEGIN
			   SET @l_TranStarted = 0
			   COMMIT TRANSACTION 
			END 
		ELSE
			BEGIN
			   ROLLBACK TRANSACTION
			END 
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
    ON OBJECT::[dbo].[usp_UserQuestionaireAnswers_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

