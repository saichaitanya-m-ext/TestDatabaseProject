/*    
------------------------------------------------------------------------------    
Procedure Name: usp_OrganizationContacts_Insert    
Description   : This procedure is used to insert record into OrganizationContacts table
Created By    : Aditya    
Created Date  : 15-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
28-Mar-2011 NagaBabu Added IF EXISTS condition
31-Mar-2011 NagaBabu Added else condition to know the data already exists
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_OrganizationContacts_Insert]
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
	@o_OrganizationContactsId KeyID OUTPUT
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
    
    IF NOT EXISTS ( SELECT 
						1
					FROM
						OrganizationContacts
					WHERE
						ContactTypeId = @i_ContactTypeId
					AND FirstName = @vc_FirstName
					AND LastName = @vc_LastName
					AND Phone = @vc_Phone
				  ) 					
    BEGIN
		INSERT INTO OrganizationContacts
			( 
				ContactTypeId,
				OrganizationId,
				FirstName,
				MiddleName,
				LastName,
				EmailID,
				Phone,
				PhoneExt,
				CreatedByUserId,
				StatusCode
		   )
		VALUES
		   ( 
				@i_ContactTypeId,
				@i_OrganizationId,
				@vc_FirstName,
				@vc_MiddleName,
				@vc_LastName,
				@vc_EmailID,
				@vc_Phone,
				@vc_PhoneExt,
				@i_AppUserId,
				@vc_StatusCode
		   )
	END
  	ELSE
         BEGIN
               SELECT 2601 ----- if data exists return the 2601 values  
         END
	SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
		  ,@o_OrganizationContactsId = SCOPE_IDENTITY()
      
	IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert Organization Contact Type'
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
    ON OBJECT::[dbo].[usp_OrganizationContacts_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

