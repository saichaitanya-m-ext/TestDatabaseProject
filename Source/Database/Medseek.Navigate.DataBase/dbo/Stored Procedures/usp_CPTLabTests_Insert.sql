﻿/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_CPTLabTests_Insert]
Description	  : This procedure is used to Insert data into CPTLabTests table.
Created By    :	Rathnam
Created Date  : 06-May-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
---------------------------------------------------------------------------------
*/  
   
CREATE PROCEDURE [dbo].[usp_CPTLabTests_Insert] 
(
	@i_AppUserId KEYID ,
	@i_LabTestId KEYID ,
	@i_ProcedureID KEYID ,
	@v_StatusCode StatusCode 
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

	INSERT INTO CPTLabTests
		( 
			ProcedureID ,
			LabTestID ,
			StatusCode ,
			CreatedByUserID
	   )
	VALUES
	   ( 
			@i_ProcedureID ,
			@i_LabTestId ,
			@v_StatusCode ,
			@i_AppUserId
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert CPTLabTests'
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
    ON OBJECT::[dbo].[usp_CPTLabTests_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

