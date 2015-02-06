/*    
------------------------------------------------------------------------------    
Procedure Name: usp_DiseaseMeasure_Insert    
Description   : This procedure is used to insert record into DiseaseMeasure table
Created By    : Aditya    
Created Date  : 29-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
16-May-2011 Rathnam added @b_IsPrimaryMeasure one more parameter  
17-May-2011 Rathnam added update statement   
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_DiseaseMeasure_Insert]  
(  
	@i_AppUserId  KeyID,
	@i_DiseaseId KeyID,
	@i_MeasureId KeyID,
	@i_Prioritization KeyID,
	@vc_StatusCode StatusCode,
	@o_DiseaseMeasureId	KeyID OUTPUT,
	@b_IsPrimaryMeasure	 IsIndicator = 0
	
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

	--------- Insert Operation into DiseaseMeasure starts here -------------------
	
	UPDATE DiseaseMeasure
	    SET	
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @vc_StatusCode,
			IsPrimaryMeasure = 0
	  WHERE DiseaseId = @i_DiseaseId 
	    AND IsPrimaryMeasure = 1 
	    AND @b_IsPrimaryMeasure = 1
	
	INSERT INTO DiseaseMeasure
			(	
				DiseaseId,
				MeasureId,
				Prioritization,
				StatusCode,
				CreatedByUserId,
				IsPrimaryMeasure
			)
	VALUES
			(
				@i_DiseaseId,
				@i_MeasureId,
				@i_Prioritization,
				@vc_StatusCode,
				@i_AppUserId,
				@b_IsPrimaryMeasure
			) 
			       
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,
			@o_DiseaseMeasureId = SCOPE_IDENTITY() 
			
			
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert DiseaseMeasure'
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
    ON OBJECT::[dbo].[usp_DiseaseMeasure_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

