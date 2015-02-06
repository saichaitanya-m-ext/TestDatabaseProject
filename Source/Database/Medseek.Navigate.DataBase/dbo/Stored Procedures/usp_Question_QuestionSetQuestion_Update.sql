/*      
-------------------------------------------------------------------------------------      
Procedure Name: usp_Question_QuestionSetQuestion_Update      
Description   : This procedure is used to update records in Question and QuestionSetQuestion
				table.  
Created By    : Pramod
Created Date  : 25-Mar-2010
-------------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
LoggedBy   :Sivakrihna Changed @vc_Description param datatype from shortdescoption to longdescription
LoggedDate  :08-Nov-2011

-------------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_Question_QuestionSetQuestion_Update]    
(    
	@i_AppUserId KeyID,    
	@i_QuestionId KeyID,
	@i_QuestionTypeID KeyID,  
	@vc_Description LongDescription,  
	@vc_QuestionText LongDescription,  
	@i_AnswerTypeId KeyID,
	@i_QuestionSetId KeyID,
	@vc_StatusCode STATUSCODE,  
	@vc_ImageNameAndPath VARCHAR(200),  
	@vc_ImageContentType VARCHAR (20),  
	@vc_UsercontrolName VARCHAR(200),  
	@i_IsRequiredQuestion IsIndicator,  
	@i_IsPrerequisite IsIndicator,
	@vc_DataSource VARCHAR(200)
)    
AS    
BEGIN TRY  
	SET NOCOUNT ON    
	DECLARE @l_numberOfRecordsChanged INT     
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
  
	UPDATE Question  
	   SET 
			QuestionTypeID = @i_QuestionTypeID,
			Description = @vc_Description,  
			QuestionText = @vc_QuestionText,  
			AnswerTypeId = @i_AnswerTypeId,  
			ImageNameAndPath = @vc_ImageNameAndPath,  
			ImageContentType = @vc_ImageContentType,  
			UsercontrolName = @vc_UsercontrolName,
			DataSource= @vc_DataSource,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE()
	  WHERE QuestionId = @i_QuestionId
	  
	IF EXISTS (SELECT 1 
				 FROM QuestionSetQuestion 
				WHERE QuestionSetId = @i_QuestionSetId
				  AND QuestionId = @i_QuestionId 
			   )
	BEGIN
	
		UPDATE QuestionSetQuestion
		   SET StatusCode = @vc_StatusCode,
			   IsRequiredQuestion = @i_IsRequiredQuestion,
			   IsPrerequisite = @i_IsPrerequisite,
			   LastModifiedByUserId = @i_AppUserId,
			   LastModifiedDate = GETDATE()
		 WHERE QuestionSetId = @i_QuestionSetId
		   AND QuestionId = @i_QuestionId
		   
		SET @l_numberOfRecordsChanged = @@ROWCOUNT  
	END
	ELSE
	BEGIN
		INSERT INTO QuestionSetQuestion  
		(  
			QuestionSetId,
			QuestionId,
			StatusCode,
			IsRequiredQuestion,
			IsPrerequisite,
			CreatedByUserId
		)   
		VALUES  
		(  
			@i_QuestionSetId,
			@i_QuestionId,
			@vc_StatusCode,
			@i_IsRequiredQuestion,
			@i_IsPrerequisite,
			@i_AppUserId 
		)  
		
		SET @l_numberOfRecordsChanged = @@ROWCOUNT  
     END

    IF @l_numberOfRecordsChanged  <> 1            
	BEGIN            
		RAISERROR        
		(  N'Invalid row count %d in Insert/Update QuestionSetQuestion'  
		,17        
		,1        
		,@l_numberOfRecordsChanged                    
		)                
	END    
  
	IF( @l_TranStarted = 1 )  -- If transactions are there then commit  
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException   
     @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Question_QuestionSetQuestion_Update] TO [FE_rohit.r-ext]
    AS [dbo];

