/*      
------------------------------------------------------------------------------      
Procedure Name: usp_CareTeamMembers_Update      
Description   : This procedure is used to update record in CareTeamMembers table.  
Created By    : Aditya      
Created Date  : 15-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
27-Sep-2010 NagaBabu Modified return statement by returning 0      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_CareTeamMembers_Update]  
(    
  @i_AppUserId KeyID ,  
  @i_UserId KeyID,  
  @i_CareTeamId KeyID,  
  @i_IsCareTeamManager KeyID,  
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
 
    
---------Update operation into CareTeamMembers table-----    

   
	  UPDATE
			CareTeamMembers  
		 SET 
			IsCareTeamManager = @i_IsCareTeamManager,  
			StatusCode = @vc_StatusCode,  
			LastModifiedByUserId = @i_AppUserId,  
			LastModifiedDate = GETDATE()  
	   WHERE 
			CareTeamId = @i_CareTeamId  
			AND ProviderID = @i_UserId  
	  
		SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT  
        
		IF @l_numberOfRecordsUpdated <> 1  
	    BEGIN        
	        RAISERROR    
	        (  N'Invalid Row count %d passed to update CareTeamMembers Details'    
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
    ON OBJECT::[dbo].[usp_CareTeamMembers_Update] TO [FE_rohit.r-ext]
    AS [dbo];

