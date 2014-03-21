/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_LabTests_Insert]
Description	  : This procedure is used to Insert data into LabTests table.
Created By    :	NagaBabu
Created Date  : 26-Apr-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
09-May-2011 Rathnam removed the ProcedureID parameter
---------------------------------------------------------------------------------
*/  
   
CREATE PROCEDURE [dbo].[usp_LabTests_Insert] 
(
	@i_AppUserId KEYID ,
	@v_LabTestName ShortDescription ,
	@v_LabTestDesc LongDescription = NULL ,
	@v_StatusCode StatusCode ,
	@o_LabTestId KEYID OUT
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

	INSERT INTO LabTests
		( 
			LabTestName ,
			LabTestDesc ,
			StatusCode ,
			CreatedByUserID
	   )
	VALUES
	   ( 
			@v_LabTestName ,
			@v_LabTestDesc ,
			@v_StatusCode ,
			@i_AppUserId
	   )
	 
	SELECT @l_numberOfRecordsInserted = @@ROWCOUNT  
          ,@o_LabTestId = SCOPE_IDENTITY()  
    
    IF @l_numberOfRecordsInserted <> 1            
		 BEGIN            
		  RAISERROR        
		   (  N'Invalid row count %d in insert LabTests'  
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LabTests_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

