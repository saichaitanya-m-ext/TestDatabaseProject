/*
----------------------------------------------------------------------------------------
Procedure Name:[usp_HealthStatusScoreOrganization_Insert]
Description	  :This Procedure is used to Insert values to HealthStatusScoreOrganization table 
Created By    :NagaBabu	
Created Date  :13-Jan-2011 
-----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
-----------------------------------------------------------------------------------------
*/ 

CREATE PROCEDURE [dbo].[usp_HealthStatusScoreOrganization_Insert]
( 
	@i_AppUserId KeyID ,
	@vc_Name SourceName ,
	@i_SortOrder KeyID ,
	@vc_StatusCode StatusCode 
	--@o_HealthStatusScoreOrgId KeyID OUTPUT
) 
AS
BEGIN TRY 
	SET NOCOUNT ON    
    DECLARE @l_numberOfRecordsInserted INT    	
	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END

------------ Insertion HealthStatusScoreOrganization table starts here ------------
      INSERT INTO HealthStatusScoreOrganization
		  (
		    Name ,
		    SortOrder ,
		    StatusCode ,
		    CreatedByUserId 
		  )
	  VALUES
		  (
			@vc_Name ,
			@i_SortOrder ,
			@vc_StatusCode ,
			@i_AppUserId
		  )
		  	
	  SELECT @l_numberOfRecordsInserted = @@ROWCOUNT 
			 --@o_HealthStatusScoreOrgId = SCOPE_IDENTITY()
	
	  IF @l_numberOfRecordsInserted <> 1            
		BEGIN            
		    RAISERROR        
		     (  N'Invalid row count %d in insert HealthStatusScoreOrganization Table'        
			   ,17        
			   ,1        
			   ,@l_numberOfRecordsInserted                   
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
    ON OBJECT::[dbo].[usp_HealthStatusScoreOrganization_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

