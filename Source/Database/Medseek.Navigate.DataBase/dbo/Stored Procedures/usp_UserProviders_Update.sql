/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserProviders_Update      
Description   : This procedure is used to update records in UserProviders table.  
Created By    : Pramod      
Created Date  : 25-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_UserProviders_Update]    
(    
 @i_AppUserId KeyID,  
 @i_UserProviderId KeyID,  
 @i_PatientUserId KeyID,  
 @i_ExternalProviderId KeyID = NULL,  
 @i_ProviderUserId KeyID = NULL,     
 @vc_Comments VARCHAR(200),  
 @vc_StatusCode StatusCode  
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
	    
	 UPDATE UserProviders  
		SET PatientUserId = @i_PatientUserId,  
		    ExternalProviderId = @i_ExternalProviderId,  
		    ProviderUserId = @i_ProviderUserId,  
		    Comments = @vc_Comments,  
		    StatusCode = @vc_StatusCode,  
		    LastModifiedByUserId = @i_AppUserId,  
		    LastModifiedDate = GETDATE()  
	  WHERE UserProviderId = @i_UserProviderId  
	     
	 SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT  
	        
	 IF @l_numberOfRecordsUpdated <> 1  
	 BEGIN        
		  RAISERROR  
			( N'Invalid Row count %d passed to update Details'    
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserProviders_Update] TO [FE_rohit.r-ext]
    AS [dbo];

