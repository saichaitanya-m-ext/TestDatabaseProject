/*    
------------------------------------------------------------------------------    
Procedure Name: usp_OrganizationContacts_Update    
Description   : This procedure is used to update record in OrganizationContacts table
Created By    : Aditya    
Created Date  : 18-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_OrganizationContacts_Update]  
(  
	@i_AppUserId KeyID,
	@i_OrganizationId KeyID, 
	@i_ContactTypeId  KeyID,
	@vc_FirstName FirstName,
	@vc_MiddleName  MiddleName,
	@vc_LastName  LastName,
	@vc_EmailID  EmailID,
	@vc_Phone  Phone,
	@vc_PhoneExt PhoneExt,
	@vc_StatusCode StatusCode,
	@i_OrganizationContactsId KeyID 
 
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

	 UPDATE OrganizationContacts
	    SET	ContactTypeId = @i_ContactTypeId,
			FirstName =	@vc_FirstName ,
			MiddleName = @vc_MiddleName ,
			LastName = @vc_LastName,
			EmailID = @vc_EmailID,
			Phone = @vc_Phone,
			PhoneExt = @vc_PhoneExt,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @vc_StatusCode
	  WHERE OrganizationContactsId = @i_OrganizationContactsId AND OrganizationId = @i_OrganizationId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update Organization Contacts Details'  
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
    ON OBJECT::[dbo].[usp_OrganizationContacts_Update] TO [FE_rohit.r-ext]
    AS [dbo];

