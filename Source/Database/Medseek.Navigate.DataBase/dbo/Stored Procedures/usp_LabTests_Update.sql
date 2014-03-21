/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_LabTests_Update]
Description	  : This procedure is used to Update data into LabTests table.
Created By    :	NagaBabu
Created Date  : 26-Apr-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
06-May-2011 Rathnam Removed the ProcedureID parameter
---------------------------------------------------------------------------------
*/  
   
CREATE PROCEDURE [dbo].[usp_LabTests_Update] 
(
	@i_AppUserId KEYID ,
	@v_LabTestName ShortDescription ,
	@v_LabTestDesc LongDescription = NULL,
	@v_StatusCode StatusCode ,
	@i_LabTestId KEYID 
)
AS
BEGIN TRY 

	SET NOCOUNT ON	
	-- Check if valid Application User ID is passed
	DECLARE @i_numberOfRecordsUpdated INT
	IF(@i_AppUserId IS NULL) OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR
		(	 N'Invalid Application User ID %d passed.'
			,17
			,1
			,@i_AppUserId
		)
	END
	
------------    Updation operation takes place   --------------------------
	UPDATE LabTests
	   SET LabTestName = @v_LabTestName ,
		   LabTestDesc = @v_LabTestDesc ,
		   StatusCode = @v_StatusCode ,
		   LastModifiedByUserId = @i_AppUserId ,
		   LastModifiedDate	= GETDATE()	
	WHERE LabTestId = @i_LabTestId	   
	
	SET @i_numberOfRecordsUpdated = @@ROWCOUNT    
       
	 IF @i_numberOfRecordsUpdated <> 1     
		  RAISERROR    
		  (  N'Update of LabTests table experienced invalid row count of %d'    
		   ,17    
		   ,1    
		   ,@i_numberOfRecordsUpdated             
		  )            
	
	RETURN 0
	
END TRY 
------------ Exception Handling --------------------------------
BEGIN CATCH
    DECLARE @i_ReturnedErrorID	INT
    
    EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException
				@i_UserId = @i_AppUserId
                        
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LabTests_Update] TO [FE_rohit.r-ext]
    AS [dbo];

