/*    
------------------------------------------------------------------------------    
Procedure Name: usp_DiseaseMeasure_Update    
Description   : This procedure is used to Update record into DiseaseMeasure table
Created By    : Aditya    
Created Date  : 16-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
16-May-2011 Rathnam added @b_IsPrimaryMeasure one more parameter    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_DiseaseMeasure_Update]  
(  
	@i_AppUserId  KeyID,
	@i_DiseaseId KeyID,
	@i_MeasureId KeyID,
	@i_Prioritization KeyID,
	@vc_StatusCode StatusCode,
	@i_DiseaseMeasureId	KeyID,
	@b_IsPrimaryMeasure IsIndicator = 0
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
     UPDATE DiseaseMeasure
	    SET	
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @vc_StatusCode,
			IsPrimaryMeasure = 0
	  WHERE DiseaseId = @i_DiseaseId 
	    AND IsPrimaryMeasure = 1 
	    AND @b_IsPrimaryMeasure = 1
     
	 UPDATE DiseaseMeasure
	    SET	DiseaseId = @i_DiseaseId,
			MeasureId = @i_MeasureId, 
			Prioritization = @i_Prioritization,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @vc_StatusCode,
			IsPrimaryMeasure = @b_IsPrimaryMeasure
	  WHERE DiseaseMeasureId = @i_DiseaseMeasureId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update DiseaseMeasure'  
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
    ON OBJECT::[dbo].[usp_DiseaseMeasure_Update] TO [FE_rohit.r-ext]
    AS [dbo];

