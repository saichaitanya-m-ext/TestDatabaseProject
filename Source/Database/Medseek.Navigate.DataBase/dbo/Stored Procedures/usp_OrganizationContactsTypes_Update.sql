/*    
------------------------------------------------------------------------------    
Procedure Name: usp_OrganizationContactsTypes_Update    
Description   : This procedure is used to update record in OrganizationContactsTypes table
Created By    : Pramod    
Created Date  : 24-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_OrganizationContactsTypes_Update]  
(  
	@i_AppUserId KeyID,
	@i_ContactTypeId KeyID,
	@v_Name ShortDescription,
	@v_StatusCode StatusCode
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

	 UPDATE OrganizationContactsType
	    SET	Name = @v_Name,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @v_StatusCode
	  WHERE ContactTypeId = @i_ContactTypeId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update Organization Contacts Type Details'  
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
    ON OBJECT::[dbo].[usp_OrganizationContactsTypes_Update] TO [FE_rohit.r-ext]
    AS [dbo];

