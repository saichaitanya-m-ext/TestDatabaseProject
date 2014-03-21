/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserMessage_And_Attachments_Insert      
Description   : This procedure is used to insert record into UserMessages,Attachments  
    and in UserMessageAttachments tables.   
Created By    : Aditya      
Created Date  : 31-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
14-May-2010 Pramod Set the parameter values for draft,messageset,patientuserid,usermessageid to NULL  
17-May-10   Pramod Set @i_UserMessageId paramter to OUT  
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_UserMessage_And_Attachments_Insert]    
(    
 @i_AppUserId KEYID,  
 @vc_SubjectText VARCHAR (200),  
 @vc_MessageText NVARCHAR(MAX),  
 @i_UserId KEYID,  
 @b_isDraft ISINDICATOR = NULL,  
 @vc_MessageState CHAR(1) = NULL,  
 @i_PatientUserId KEYID = NULL,  
 @t_Attachment AttachmentTbl READONLY,  
 @t_MessageToUserId UserIdTblType READONLY,  
 @i_UserMessageId KEYID = NULL OUT ,
 @i_IsMassCommunication BIT = 0 
)    
AS    
BEGIN TRY    
	 SET NOCOUNT ON    
	 DECLARE @l_numberOfRecordsInserted INT,  
	   @i_AttachmentId INT     
	 -- Check if valid Application User ID is passed      
	 IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
	 BEGIN    
		 RAISERROR ( N'Invalid Application User ID %d passed.' ,    
		 17 ,    
		 1 ,    
		 @i_AppUserId )    
	 END   
	   
	 DECLARE @l_TranStarted   BIT = 0  
		IF( @@TRANCOUNT = 0 )    
		BEGIN  
			BEGIN TRANSACTION  
			SET @l_TranStarted = 1  -- Indicator for start of transactions  
		END  
		ELSE  
			SET @l_TranStarted = 0    
	  
	------------------Inserting Into UserMessages Table---------------  
	  
	 IF @i_UserMessageId IS NULL  
	 BEGIN  
		  INSERT INTO UserMessages  
			 (   
				SubjectText,  
				MessageText,  
				ProviderID,  
				isDraft,  
				MessageState,  
				PatientId,  
				CreatedByUserId  
			 )  
		  VALUES  
			 (   
				@vc_SubjectText,  
				@vc_MessageText,  
				@i_UserId,  
				@b_isDraft,  
				@vc_MessageState,  
				@i_PatientUserId,  
				@i_AppUserId  
			 )  
		        
		  SET @l_numberOfRecordsInserted = @@ROWCOUNT  
		  SET @i_UserMessageId = SCOPE_IDENTITY()  
		    
		  IF @l_numberOfRecordsInserted <> 1            
		  BEGIN            
			   RAISERROR  
				(  N'Invalid row count %d in insert into UserMessages Table'  
				 ,17  
				 ,1  
				 ,@l_numberOfRecordsInserted  
				)  
		  END  
	 END  
	 ELSE  -- DO THE CLEANUP OF THE RELATED TABLES (SO THAT FRESH INSERT OF DATA CAN HAPPEN)  
	 BEGIN  
	   
		  DELETE FROM UserMessageRecipients  
		   WHERE UserMessageID = @i_UserMessageId  
		  
		  DECLARE @t_AttachmentID TABLE (AttachmentID KeyID)  
		    
		  INSERT INTO @t_AttachmentID (AttachmentID)  
		  SELECT AttachmentId  
			FROM UserMessageAttachments  
		   WHERE UserMessageID = @i_UserMessageId  
		         
		  DELETE FROM UserMessageAttachments  
		   WHERE UserMessageID = @i_UserMessageId  
		     
		  DELETE FROM Attachments  
		   WHERE EXISTS   
				 ( SELECT 1   
					 FROM @t_AttachmentID  
					WHERE AttachmentId = Attachments.AttachmentId  
				 )  
		     
		  UPDATE UserMessages  
			 SET SubjectText = @vc_SubjectText,  
				 MessageText = @vc_MessageText,  
				 ProviderID = @i_UserId,  
				 isDraft = @b_isDraft,  
				 MessageState = @vc_MessageState,  
				 PatientId = @i_PatientUserId  
		   WHERE UserMessageId = @i_UserMessageId  
	  
	 END  
	  
	---------------Inserting Into UserMessageReciprocates Table--------  
	  
	 IF @i_IsMassCommunication = 1 
	 BEGIN
	 INSERT INTO UserMessageRecipients  
		(   
		   UserMessageID,  
		   PatientID,  
		   MessageState,  
		   CreatedByUserId  
		)  
		
		SELECT   
		   @i_UserMessageId,  
		   UserId,  
		   'N',  -- Set to N for Not viewed  
		   @i_AppUserId  
	  FROM @t_MessageToUserId
	 END
	 ELSE
	 BEGIN
	 INSERT INTO UserMessageRecipients  
		(   
		   UserMessageID,  
		   ProviderID,  
		   MessageState,  
		   CreatedByUserId  
		)  
		
		SELECT   
		   @i_UserMessageId,  
		   UserId,  
		   'N',  -- Set to N for Not viewed  
		   @i_AppUserId  
	  FROM @t_MessageToUserId
	
	   END
	            
	------------------Inserting Into Attachments Table---------------  
	  
	-- IF @vc_AttachmentName IS NOT NULL  
	  
	 DECLARE  
		  @vc_AttachmentName VARCHAR(100),  
		  @vc_AttachmentExtension VARCHAR(5),  
		  @vc_AttachmentBody VARBINARY(MAX),  
		  @vc_FileType VARCHAR(100),  
		  @vc_MimeType VARCHAR(100),  
		  @i_FileSizeInBytes INT  
	  
	 DECLARE   
		 curAttachment CURSOR FOR  
		  SELECT 
		       AttachmentName,  
			   AttachmentExtension,  
			   AttachmentBody,  
			   FileType,  
			   MimeType,  
			   FileSizeInBytes  
		  FROM @t_Attachment  
	        
		 OPEN curAttachment    
	  FETCH NEXT FROM curAttachment     
	   INTO @vc_AttachmentName,   
			@vc_AttachmentExtension,   
			@vc_AttachmentBody,   
			@vc_FileType,   
			@vc_MimeType,   
			@i_FileSizeInBytes  
	      
	 WHILE @@FETCH_STATUS = 0    
	 BEGIN  
	   
		  INSERT INTO Attachments  
			 (   
				AttachmentName,  
				AttachmentExtension,  
				AttachmentBody,  
				FileType,  
				MimeType,  
				FileSizeInBytes,  
				CreatedByUserId  
			 )  
		  VALUES  
			 (   
				@vc_AttachmentName,  
				@vc_AttachmentExtension,  
				@vc_AttachmentBody,  
				@vc_FileType,  
				@vc_MimeType,  
				@i_FileSizeInBytes,  
				@i_AppUserId  
			 )  
	  SET @i_AttachmentId = SCOPE_IDENTITY()  
	 ------------------Inserting Into UserMessageAttachments Table---------------  
	  
		  INSERT INTO UserMessageAttachments  
			 (   
				UserMessageId,  
				AttachmentId,  
				CreatedByUserId  
			 )  
		  VALUES  
			 (   
				@i_UserMessageId,  
				@i_AttachmentId,  
				@i_AppUserId  
			 )  
		  
		  FETCH NEXT FROM curAttachment     
		   INTO @vc_AttachmentName,   
				@vc_AttachmentExtension,   
				@vc_AttachmentBody,   
				@vc_FileType,   
				@vc_MimeType,   
				@i_FileSizeInBytes      
	 END  
		CLOSE curAttachment  
		DEALLOCATE curAttachment  
	   
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException   
     @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserMessage_And_Attachments_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

