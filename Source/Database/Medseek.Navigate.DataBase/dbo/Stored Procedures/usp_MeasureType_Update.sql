/*    
------------------------------------------------------------------------------    
Procedure Name: usp_MeasureType_Update    
Description   : This procedure is used to update record in MeasureType table
Created By    : Aditya    
Created Date  : 14-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
24-Sep-2010 NagaBabu Changed datatype of @vc_Description as ShortDescription
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_MeasureType_Update]  
(  
	@i_AppUserId  KeyID,
	@vc_MeasureTypeName SourceName,
	@vc_Description ShortDescription,
	@i_SortOrder STID,
	@vc_StatusCode StatusCode,
	@i_MeasureTypeId KeyID 
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

	 UPDATE MeasureType
	    SET	MeasureTypeName = @vc_MeasureTypeName,
			Description = @vc_Description, 
			SortOrder = @i_SortOrder,
			StatusCode = @vc_StatusCode,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE() 
	  WHERE MeasureTypeId = @i_MeasureTypeId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update MeasureType'  
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
    ON OBJECT::[dbo].[usp_MeasureType_Update] TO [FE_rohit.r-ext]
    AS [dbo];

