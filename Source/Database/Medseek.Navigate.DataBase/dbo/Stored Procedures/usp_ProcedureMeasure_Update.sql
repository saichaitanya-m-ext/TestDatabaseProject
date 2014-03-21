/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ProcedureMeasure_Update    
Description   : This procedure is used to Update record into ProcedureMeasure table
Created By    : Aditya    
Created Date  : 16-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ProcedureMeasure_Update]  
(  
	@i_AppUserId  KeyID,
	@i_MeasureId	KeyID,
	@i_ProcedureId	KeyID,
	@v_StatusCode StatusCode,
	@i_ProcedureMeasureId KeyID 
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

	 UPDATE ProcedureMeasure
	    SET	MeasureId = @i_MeasureId,
			ProcedureId = @i_ProcedureId, 
			StatusCode = @v_StatusCode,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE()
	  WHERE ProcedureMeasureId = @i_ProcedureMeasureId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update ProcedureMeasure'  
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
    ON OBJECT::[dbo].[usp_ProcedureMeasure_Update] TO [FE_rohit.r-ext]
    AS [dbo];

