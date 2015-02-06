/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_Task_UpdateAssignedCareProviderId]    
Description   : This procedure is used to Update records in Task table
Created By    : Rathnam
Created Date  : 18-May-2011    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_Task_UpdateAssignedCareProviderId]  
(  
	@i_AppUserId KeyID,
	@i_TaskId KEYID,
	@i_AssignedCareProviderId KEYID
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
	
	UPDATE Task 
	   SET AssignedCareProviderId = @i_AssignedCareProviderId,
		   LastModifiedByUserId = @i_AppUserId,
		   LastModifiedDate = GETDATE()
	 WHERE TaskId = @i_TaskId
	 
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
    ON OBJECT::[dbo].[usp_Task_UpdateAssignedCareProviderId] TO [FE_rohit.r-ext]
    AS [dbo];

