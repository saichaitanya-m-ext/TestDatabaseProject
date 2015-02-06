﻿/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ProcedureMeasure_Insert    
Description   : This procedure is used to insert record into ProcedureMeasure table
Created By    : Aditya    
Created Date  : 16-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ProcedureMeasure_Insert]  
(  
	@i_AppUserId  KeyID,
	@i_MeasureId	KeyID,
	@i_ProcedureId	KeyID,
	@v_StatusCode StatusCode,
	@o_ProcedureMeasureId KeyID OUTPUT
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

	--------- Insert Operation into ProcedureMeasure starts here -------------------
	 
	INSERT INTO ProcedureMeasure
			(	
				MeasureId,
				ProcedureId,
				StatusCode,
				CreatedByUserId
			)
	VALUES
			(
				@i_MeasureId,
				@i_ProcedureId,
				@v_StatusCode,
				@i_AppUserId
			) 
			       
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,
			@o_ProcedureMeasureId = SCOPE_IDENTITY() 
			
			
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert ProcedureMeasure'
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
    ON OBJECT::[dbo].[usp_ProcedureMeasure_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

