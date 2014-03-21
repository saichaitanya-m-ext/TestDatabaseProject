/*    
------------------------------------------------------------------------------    
Procedure Name: usp_QuestionSet_QuestionaireQuestionSet_Insert_Update  
Description   : This procedure is used to Insert or update records in QuestionSet 
				and QuestionaireQuestionSet tables
Created By    : Aditya    
Created Date  : 19-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_QuestionSet_QuestionaireQuestionSet_Insert_Update]  
(  
	@i_AppUserId KeyID,
	@i_QuestionSetId KeyID, 
	@vc_QuestionSetName ShortDescription,
	@vc_Description LongDescription,
	@i_QuestionaireId KeyID,
	@i_SortOrder STID,
	@b_IsShowPanel IsIndicator,
	@b_IsShowQuestionSetName IsIndicator,
	@v_StatusCode STATUSCODE 
)  
AS  
BEGIN TRY

	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsUpdated INT ,
			@l_numberOfRecordsChanged INT  
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

    DECLARE @l_TranStarted   BIT = 0
    IF( @@TRANCOUNT = 0 )  
    BEGIN
        BEGIN TRANSACTION
        SET @l_TranStarted = 1  -- Indicator for start of transactions
    END
    ELSE
        SET @l_TranStarted = 0 

	UPDATE QuestionSet
	   SET	QuestionSetName = @vc_QuestionSetName,
			Description = @vc_Description,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @v_StatusCode
	 WHERE QuestionSetId = @i_QuestionSetId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT

	IF @l_numberOfRecordsUpdated <> 1
	BEGIN      
		RAISERROR  
			(  N'Invalid Row count %d passed to update QuestionSet Details'
				,17
				,1
				,@l_numberOfRecordsUpdated
			)
	END

	IF EXISTS ( SELECT 1
				  FROM QuestionaireQuestionSet
				 WHERE QuestionaireId = @i_QuestionaireId
				   AND QuestionSetId = @i_QuestionSetId
			  )
	BEGIN
		UPDATE QuestionaireQuestionSet
		   SET SortOrder = @i_SortOrder,
		       StatusCode = @v_StatusCode,
		       IsShowPanel = @b_IsShowPanel,
		       IsShowQuestionSetName = @b_IsShowQuestionSetName,
		       LastModifiedByUserId = @i_AppUserId,
		       LastModifiedDate = GETDATE()
		 WHERE QuestionaireId = @i_QuestionaireId
	       AND QuestionSetId = @i_QuestionSetId
	       
   		SET @l_numberOfRecordsChanged = @@ROWCOUNT  

	END
	ELSE
	BEGIN
		INSERT QuestionaireQuestionSet
		       ( QuestionaireId,
				 QuestionSetId,
				 SortOrder,
				 IsShowPanel,
				 IsShowQuestionSetName,
				 StatusCode,
				 CreatedByUserId
		       )
		 VALUES
		       ( @i_QuestionaireId,
				 @i_QuestionSetId,
				 @i_SortOrder,
				 @b_IsShowPanel,
				 @b_IsShowQuestionSetName,
				 @v_StatusCode,
				 @i_AppUserId
		       )
		       
   		SET @l_numberOfRecordsChanged = @@ROWCOUNT  		       
	END

    IF @l_numberOfRecordsChanged  <> 1            
	BEGIN            
		RAISERROR        
		(  N'Invalid row count %d in insert Question'  
		,17        
		,1        
		,@l_numberOfRecordsChanged                    
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
    ON OBJECT::[dbo].[usp_QuestionSet_QuestionaireQuestionSet_Insert_Update] TO [FE_rohit.r-ext]
    AS [dbo];

