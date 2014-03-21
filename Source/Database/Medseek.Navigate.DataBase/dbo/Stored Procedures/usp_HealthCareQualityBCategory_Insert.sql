/*    
------------------------------------------------------------------------------    
Procedure Name: usp_HealthCareQualityBCategory_Insert    
Description   : This procedure is used to insert record into Immunizations table
Created By    :	NagaBabu	
Created Date  : 11-Oct-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_HealthCareQualityBCategory_Insert]  
(  
	@i_AppUserId KEYID,  
	@i_HealthCareQualityCategoryId KEYID,
	@vc_HealthCareQualityBCategoryName ShortDescription ,
	@o_HealthCareQualityBCategoryId KEYID OUT
)  
AS  
BEGIN TRY  
	SET NOCOUNT ON  
	DECLARE @i_numberOfRecordsInserted INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR ( N'Invalid Application User ID %d passed.' ,  
		   17 ,  
		   1 ,  
		   @i_AppUserId )  
	END  

	INSERT INTO HealthCareQualityBCategory
	   ( 
		 HealthCareQualityCategoryId ,
		 HealthCareQualityBCategoryName ,
	     CreatedByUserId 
	   )
	VALUES
	   ( 
		 @i_HealthCareQualityCategoryId ,
		 @vc_HealthCareQualityBCategoryName ,
		 @i_AppUserId 
	   )
	   	
    SELECT @i_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_HealthCareQualityBCategoryId = SCOPE_IDENTITY()
      
    IF @i_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Insert HealthCareQualityBCategory'
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
    ON OBJECT::[dbo].[usp_HealthCareQualityBCategory_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

