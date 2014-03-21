/*      
-------------------------------------------------------------------------------------      
Procedure Name: usp_Question_QuestionSetQuestion_Insert      
Description   : This procedure is used to insert records into Question and QuestionSetQuestion  
				table.  
Created By    : Aditya      
Created Date  : 19-Mar-2010      
-------------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
LoggedBy   :Sivakrihna Changed @vc_Description param datatype from shortdescoption to longdescription

-------------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_Question_QuestionSetQuestion_Insert]    
(    
 @i_AppUserId  KeyID,    
 @i_QuestionTypeID  KeyID,  
 @vc_Description  LongDescription,  
 @vc_QuestionText  LongDescription,  
 @i_AnswerTypeId  KeyID,
 @i_QuestionSetId KeyID,
 @vc_StatusCode STATUSCODE,  
 @vc_ImageNameAndPath  VARCHAR(200),  
 @vc_ImageContentType VARCHAR (20),  
 @vc_UsercontrolName  VARCHAR(200),  
 @i_IsRequiredQuestion  IsIndicator,  
 @i_IsPrerequisite  IsIndicator, 
 @vc_DataSource VARCHAR(200),
 @o_QuestionId KeyID OUTPUT  
)    
AS    
BEGIN TRY  
	 SET NOCOUNT ON    
	 DECLARE @l_numberOfRecordsInserted INT     
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
	  
	 INSERT INTO Question  
		(   
		   QuestionTypeID,  
		   Description,  
		   QuestionText,  
		   AnswerTypeId,  
		   ImageNameAndPath,  
		   ImageContentType,  
		   UsercontrolName,
		   DataSource,  
		   CreatedByUserId  
		)  
	 VALUES  
		(   
		   @i_QuestionTypeID,  
		   @vc_Description,  
		   @vc_QuestionText,  
		   @i_AnswerTypeId,  
		   @vc_ImageNameAndPath ,  
		   @vc_ImageContentType ,  
		   @vc_UsercontrolName, 
		   @vc_DataSource, 
		   @i_AppUserId  
		)  
	  
	 SET @o_QuestionId = SCOPE_IDENTITY()
	      
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
			@o_QuestionId,
			@vc_StatusCode,
			@i_IsRequiredQuestion,
			@i_IsPrerequisite,
			@i_AppUserId 
	   )  
	     
		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT  
	            
	        
		IF @l_numberOfRecordsInserted <> 1            
	 BEGIN            
	  RAISERROR        
	   (  N'Invalid row count %d in insert Question'  
		,17        
		,1        
		,@l_numberOfRecordsInserted                   
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
    ON OBJECT::[dbo].[usp_Question_QuestionSetQuestion_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

