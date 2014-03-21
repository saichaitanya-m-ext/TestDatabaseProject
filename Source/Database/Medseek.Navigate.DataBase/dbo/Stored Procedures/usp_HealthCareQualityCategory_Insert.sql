/*        
------------------------------------------------------------------------------        
Procedure Name: usp_HealthCareQualityCategory_Insert        
Description   : This procedure is used to insert Values into HealthCareQualityCategory
Created By    : NagaBabu  
Created Date  : 11-Oct-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------        
*/

CREATE PROCEDURE [dbo].[usp_HealthCareQualityCategory_Insert]
(
 @i_AppUserId KEYID ,
 @vc_HealthCareQualityCategoryName ShortDescription ,
 @o_HealthCareQualityCategoryID KEYID OUT
 )
AS
BEGIN TRY
      SET NOCOUNT ON  
      DECLARE @i_numberOfRecordsInserted INT  
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END    
    
---------insert operation into HealthCareQualityCategory table-----  
	   INSERT INTO 
		   HealthCareQualityCategory
		   (
			 HealthCareQualityCategoryName ,
			 CreatedByUserId 
		   )
	   VALUES
		   (
		     @vc_HealthCareQualityCategoryName ,
		     @i_AppUserId 
		   )
		SELECT @o_HealthCareQualityCategoryID = SCOPE_IDENTITY(),      	   	        
               @i_numberOfRecordsInserted = @@ROWCOUNT
	    IF @i_numberOfRecordsInserted <> 1
	    BEGIN
			RAISERROR
				( N'Invalid row count %d in insert HealthCareQualityCategory'
				   ,17      
				   ,1      
				   ,@i_numberOfRecordsInserted                 
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
    ON OBJECT::[dbo].[usp_HealthCareQualityCategory_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

