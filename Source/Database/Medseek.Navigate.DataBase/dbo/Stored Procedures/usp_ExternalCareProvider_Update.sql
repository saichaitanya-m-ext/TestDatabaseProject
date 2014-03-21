/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ExternalCareProvider_Update    
Description   : This procedure is used to Update records in ExternalCareProvider table
Created By    : Aditya    
Created Date  : 06-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY         DESCRIPTION    
09-June-2010 NagaBabu  Added ZipCode Perameter to this SP             
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ExternalCareProvider_Update]  
(  
	@i_AppUserId KeyID,
	@vc_FirstName SourceName,
	@vc_MiddleName SourceName = NULL,
	@vc_LastName SourceName,
	@vc_AddressLine1 Address,
	@vc_AddressLine2 Address,
	@vc_City City,
	@vc_StateCode State,
	@vc_PhoneNumber Phone,
	@vc_PhoneNumberExt PhoneExt,
	@vc_EmailId	EmailId,
	@vc_Fax	Fax,
	@vc_StatusCode StatusCode,
	@i_ExternalProviderId KeyID,
    @vc_ZIPCode ZIPCode
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

	UPDATE
		Provider
	SET
		FirstName = @vc_FirstName ,
		MiddleName = @vc_MiddleName ,
		LastName = @vc_LastName ,
		PrimaryAddressLine1 = @vc_AddressLine1 ,
		PrimaryAddressLine2 = @vc_AddressLine2 ,
		PrimaryAddressCity = @vc_City ,
		PrimaryAddressStateCodeid = @vc_StateCode ,
		PrimaryPhoneNumber = @vc_PhoneNumber ,
		PrimaryPhoneNumberExtension = @vc_PhoneNumberExt ,
		PrimaryEmailAddress = @vc_EmailId ,
		TertiaryPhoneNumber = @vc_Fax ,
		AccountStatusCode = @vc_StatusCode ,
		LastModifiedByUserId = @i_AppUserId ,
		LastModifiedDate = GETDATE(),
		PrimaryAddressPostalCode = @vc_ZIPCode
	WHERE
		Providerid = @i_ExternalProviderId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update ExternalCareProvider'  
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
    ON OBJECT::[dbo].[usp_ExternalCareProvider_Update] TO [FE_rohit.r-ext]
    AS [dbo];

