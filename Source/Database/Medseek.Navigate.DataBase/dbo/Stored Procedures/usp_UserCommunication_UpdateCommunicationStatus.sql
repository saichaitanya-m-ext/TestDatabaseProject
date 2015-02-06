/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UserCommunication_UpdateCommunicationStatus]    
Description   : This procedure is used to Update Communication Status in UserCommunication table
Created By    : Suresh G
Created Date  : 11-May-2012
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/    
CREATE PROCEDURE [dbo].[usp_UserCommunication_UpdateCommunicationStatus]  
(  
	 @i_UserCommunicationId KeyID
	,@i_AppUserId KeyID
	,@v_CommunicationState VARCHAR(15)
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @i_numberOfRecordsUpdated INT   
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

	BEGIN   
	
	------------    Updation operation takes place   --------------------------
			
	UPDATE UserCommunication
	  SET CommunicationState = @v_CommunicationState		 
		  ,LastModifiedByUserId = @i_AppUserId
		  ,LastModifiedDate	= GETDATE()		  
	 WHERE 
		UserCommunicationId = @i_UserCommunicationId
		  	 
	SET @i_numberOfRecordsUpdated = @@ROWCOUNT
			
	IF @i_numberOfRecordsUpdated <> 1 
		RAISERROR
		(	 N'Update of UserCommunication table experienced invalid row count of %d'
			,17
			,1
			,@i_numberOfRecordsUpdated         
	)        
			
	RETURN 0
		 
	END  
  
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
    ON OBJECT::[dbo].[usp_UserCommunication_UpdateCommunicationStatus] TO [FE_rohit.r-ext]
    AS [dbo];

