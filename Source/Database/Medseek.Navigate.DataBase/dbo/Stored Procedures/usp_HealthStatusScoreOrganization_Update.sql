/*
----------------------------------------------------------------------------------------
Procedure Name:[usp_HealthStatusScoreOrganization_Update]
Description	  :This Procedure is used to Update values to HealthStatusScoreOrganization table 
Created By    :NagaBabu	
Created Date  :13-Jan-2011 
-----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
-----------------------------------------------------------------------------------------
*/ 

CREATE PROCEDURE [dbo].[usp_HealthStatusScoreOrganization_Update]
( 
	@i_AppUserId KeyID ,
	@vc_Name SourceName ,
	@i_SortOrder KeyID ,
	@vc_StatusCode StatusCode ,
	@i_HealthStatusScoreOrgId KeyID 
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

------------ Updation HealthStatusScoreOrganization table starts here ------------
      UPDATE HealthStatusScoreOrganization
		 SET Name = @vc_Name ,
		     SortOrder = @i_SortOrder ,
		     StatusCode = @vc_StatusCode ,
		     LastModifiedByUserId = @i_AppUserId ,
		     LastModifiedDate = GETDATE() 
	   WHERE HealthStatusScoreOrgId = @i_HealthStatusScoreOrgId	     
		 
	  SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT 
	
	  IF @l_numberOfRecordsUpdated <> 1            
		BEGIN            
		    RAISERROR        
		     (  N'Invalid Row count %d passed to update HealthStatusScoreOrganization table'    
			   ,17        
			   ,1        
			   ,@l_numberOfRecordsUpdated                   
		     )                
		END    
  
    RETURN 0  			    
		        
END TRY
-----------------------------------------------------------------------
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthStatusScoreOrganization_Update] TO [FE_rohit.r-ext]
    AS [dbo];

