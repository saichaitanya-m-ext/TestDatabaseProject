/*    
------------------------------------------------------------------------------    
Procedure Name: usp_InsuranceGroup_Update
Description   : This procedure is used to update the details in InsuranceGroup table
Created By    : Pramod
Created Date  : 02-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION

------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_InsuranceGroup_Update]
(  
	@i_AppUserId KeyID,
	@i_InsuranceGroupID KEYID,
	@v_GroupName SourceName,
	@v_AddressLine1 Address,  
	@v_AddressLine2 Address,  
	@v_City City,  
	@v_StateCode State, 
	@v_ZipCode ZipCode, 
	@v_ContactName SourceName,
	@v_ContactPhoneNumber Phone,
	@v_ContactPhoneNumberExtension PhoneExt,  
	@v_Website ShortDescription,
	@v_PhoneNumber Phone,
	@v_PhoneNumberExtension PhoneExt,
	@v_Fax Fax,
	@v_StatusCode StatusCode
)  
AS  
BEGIN TRY  
    SET NOCOUNT ON     
-- Check if valid Application User ID is passed  
  
    IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
    BEGIN  
           RAISERROR ( N'Invalid Application User ID %d passed.' ,  
           17 ,  
           1 ,  
           @i_AppUserId )  
    END  
  
	DECLARE @l_numberOfRecordsUpdated INT

	UPDATE InsuranceGroup
	   SET GroupName = @v_GroupName ,
		   AddressLine1 = @v_AddressLine1,
		   AddressLine2 = @v_AddressLine2,
		   City = @v_City,
		   StateCode = @v_StateCode,
		   ZipCode = @v_ZipCode,
		   ContactName = @v_ContactName,
		   ContactPhoneNumber = @v_ContactPhoneNumber,
		   ContactPhoneNumberExtension = @v_ContactPhoneNumberExtension,
		   Website = @v_Website,
		   PhoneNumber = @v_PhoneNumber,
		   PhoneNumberExtension = @v_PhoneNumberExtension,
		   Fax = @v_Fax,
		   LastModifiedByUserId = @i_AppUserId,
		   LastModifiedDate = GETDATE(),
		   StatusCode = @v_StatusCode
	 WHERE InsuranceGroupID = @i_InsuranceGroupID

    SET @l_numberOfRecordsUpdated = @@ROWCOUNT

    IF @l_numberOfRecordsUpdated <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Update InsuranceGroup'
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
    ON OBJECT::[dbo].[usp_InsuranceGroup_Update] TO [FE_rohit.r-ext]
    AS [dbo];

