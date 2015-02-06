﻿/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserProviders_Insert      
Description   : This procedure is used to insert record into UserProviders type table  
Created By    : Pramod      
Created Date  : 24-Feb-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/  
CREATE PROCEDURE [dbo].[usp_UserProviders_Insert]    
(    
 @i_AppUserId KeyID,    
 @i_PatientUserId KeyID,  
 @i_ExternalProviderId KeyID = NULL,  
 @i_ProviderUserId KeyID = NULL,  
 @vc_Comments VARCHAR(200),  
 @vc_StatusCode StatusCode,  
 @o_UserProviderId KeyID OUTPUT  
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
	   
	 INSERT INTO UserProviders  
		(   
		  PatientUserId,  
		  ExternalProviderId,  
		  ProviderUserId,  
		  Comments,  
		  StatusCode,  
		  CreatedByUserId  
		)  
	 VALUES  
		(  
		  @i_PatientUserId,  
		  @i_ExternalProviderId,  
		  @i_ProviderUserId,  
		  @vc_Comments,  
		  @vc_StatusCode,  
		  @i_AppUserId  
	    )     
	 SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,  
		    @o_UserProviderId = SCOPE_IDENTITY()  
	        
	 IF @l_numberOfRecordsInserted <> 1            
	 BEGIN            
		  RAISERROR        
		   (  N'Invalid row count %d in insert into UserProviders'  
			,17        
			,1        
			,@l_numberOfRecordsInserted            
		   )                
	 END    
	  
	 RETURN 0   
    
END TRY      
--------------------------------------------------------       
BEGIN CATCH      
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException       @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserProviders_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

