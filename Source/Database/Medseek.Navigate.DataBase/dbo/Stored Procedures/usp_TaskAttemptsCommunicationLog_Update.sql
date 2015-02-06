/*    
------------------------------------------------------------------------------    
Procedure Name: usp_TaskAttemptsCommunicationLog_Update
Description   : This procedure is used to update record into TaskAttemptsCommunicationLog table
Created By    : Rathnam
Created Date  : 19-Jan-2012  
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_TaskAttemptsCommunicationLog_Update]  
(  
	@i_AppUserId KeyID,
	@i_TaskAttemptsCommunicationLogID KEYID,
	@i_FilePath VARCHAR(200) = NULL
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsUpdated INT   
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

	UPDATE TaskAttemptsCommunicationLog
	   SET 
		   StatusCode = 'S',
		   LastModifiedDate = GETDATE(),
		   LastModifiedByUserId = @i_AppUserId,
		   FilePath = @i_FilePath
	 WHERE TaskAttemptsCommunicationLogID = @i_TaskAttemptsCommunicationLogId
	 
	 
	 UPDATE UserCommunication
	 SET CommunicationState = 'Sent',
		 LastModifiedByUserId = @i_AppUserId,
		 LastModifiedDate = GETDATE()
     WHERE TaskAttemptsCommunicationLogId = @i_TaskAttemptsCommunicationLogID		 
	 
  
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
    ON OBJECT::[dbo].[usp_TaskAttemptsCommunicationLog_Update] TO [FE_rohit.r-ext]
    AS [dbo];

