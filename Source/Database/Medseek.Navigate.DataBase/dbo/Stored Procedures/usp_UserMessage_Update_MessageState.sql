/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserMessage_Update_MessageState  
Description   : This procedure is used to update the  UserMessages tables  
Created By    : Pramod      
Created Date  : 14-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_UserMessage_Update_MessageState]    
(    
 @i_AppUserId KEYID,  
 @i_UserMessageId KEYID,  
 @vMessageState VARCHAR(1)  
)    
AS    
BEGIN TRY    
	 SET NOCOUNT ON    
	 DECLARE @l_numberOfRecordsUpdated INT  
	   
	 -- Check if valid Application User ID is passed      
	 IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
	 BEGIN    
		  RAISERROR ( N'Invalid Application User ID %d passed.' ,    
			17 ,    
			1 ,    
			@i_AppUserId )  
	 END   
	   
	 UPDATE UserMessages  
		SET MessageState = @vMessageState  
	  WHERE UserMessageId = @i_UserMessageId  
	  
	 SET @l_numberOfRecordsUpdated = @@ROWCOUNT  
	  
	 IF @l_numberOfRecordsUpdated <> 1            
	 BEGIN            
		  RAISERROR  
		   (  N'Invalid row count %d in update of UserMessages Table'  
			,17  
			,1  
			,@l_numberOfRecordsUpdated  
		   )  
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
    ON OBJECT::[dbo].[usp_UserMessage_Update_MessageState] TO [FE_rohit.r-ext]
    AS [dbo];

