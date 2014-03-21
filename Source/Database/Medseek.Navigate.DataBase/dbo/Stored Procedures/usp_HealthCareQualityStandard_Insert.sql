

/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_HealthCareQualityStandard_Insert]       
Description   : This procedure is used to insert Values into HealthCareQualityStandard  table
Created By    : NagaBabu  
Created Date  : 28-Oct-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------        
*/

CREATE PROCEDURE [dbo].[usp_HealthCareQualityStandard_Insert]
(
 @i_AppUserId KEYID ,
 @vc_HealthCareQualityStandardName ShortDescription ,
 @vc_CustomMeasureType VARCHAR(50),
 @o_HealthCareQualityStandardID KEYID OUT
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
    
---------insert operation into HealthCareQualityStandard table-----  
	   INSERT INTO 
		   HealthCareQualityStandard  
		   (
			 HealthCareQualityStandardName ,
			 CustomMeasureType,
			 CreatedByUserId 
		   )
	   VALUES
		   (
		     @vc_HealthCareQualityStandardName ,
		     @vc_CustomMeasureType,
		     @i_AppUserId 
		   )
		SELECT @o_HealthCareQualityStandardID = SCOPE_IDENTITY(),      	   	        
               @i_numberOfRecordsInserted = @@ROWCOUNT
	    IF @i_numberOfRecordsInserted <> 1
	    BEGIN
			RAISERROR
				( N'Invalid row count %d in insert HealthCareQualityStandard'
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


select * from HealthCareQualityStandard    

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthCareQualityStandard_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

