/*    
------------------------------------------------------------------------------    
Procedure Name: usp_MeasureType_Insert    
Description   : This procedure is used to insert record into MeasureType table
Created By    : Aditya    
Created Date  : 14-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_MeasureType_Insert]  
(  
	@i_AppUserId  KeyID,
	@vc_MeasureTypeName SourceName, 
	@vc_Description SourceName,
	@i_SortOrder STID,
	@vc_StatusCode StatusCode,
	@o_MeasureTypeId KeyID OUTPUT
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

	--------- Insert Operation into MeasureType starts here -------------------
	 
	INSERT INTO MeasureType
			(	
				MeasureTypeName,
				Description,
				SortOrder,
				CreatedByUserId,
				StatusCode 
			)
	VALUES
			(
			 	@vc_MeasureTypeName,
			 	@vc_Description,
			 	@i_SortOrder,
				@i_AppUserId,
				@vc_StatusCode 
			) 
			       
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,
			@o_MeasureTypeId = SCOPE_IDENTITY() 
			
			
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert MeasureType'
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MeasureType_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

