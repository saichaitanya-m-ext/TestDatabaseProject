
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_LookUpCodeType_Delete]    
Description   : This procedure is used to Delete record from LkUpCodeType_Test table (Node)
Created By    : Rama Krishna	    
Created Date  : 5-12-2013   
------------------------------------------------------------------------------    
 
*/  
Create PROCEDURE [dbo].[usp_LookUpCodeType_Delete]  
(  
	@i_AppUserId KeyID,
	@i_CodeTypeID KeyID
 )
AS  
BEGIN TRY

	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsDeleted INT   
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

	DELETE FROM LkUpCodeType_Test
	 WHERE  CodeTypeID = @i_CodeTypeID
			

    SELECT @l_numberOfRecordsDeleted = @@ROWCOUNT
      
	IF @l_numberOfRecordsDeleted <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to Delete DocumentProgram Details'  
				,17  
				,1 
				,@l_numberOfRecordsDeleted
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
    ON OBJECT::[dbo].[usp_LookUpCodeType_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

