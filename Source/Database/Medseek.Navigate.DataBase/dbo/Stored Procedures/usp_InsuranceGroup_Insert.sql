/*    
------------------------------------------------------------------------------    
Procedure Name: usp_InsuranceGroup_Insert
Description   : This procedure is used to Insert the details into InsuranceGroup table
Created By    : Pramod
Created Date  : 02-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION

------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_InsuranceGroup_Insert]  
(  
	@i_AppUserId KeyID,
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
	@v_StatusCode StatusCode,
	@o_InsuranceGroupID KEYID OUTPUT
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
  
	DECLARE @l_numberOfRecordsInserted INT

	INSERT INTO InsuranceGroup
	(  
		GroupName,
		AddressLine1,
		AddressLine2,
		City,
		StateCode,
		ZipCode,
		ContactName,
		ContactPhoneNumber,
		ContactPhoneNumberExtension,
		Website,
		PhoneNumber,
		PhoneNumberExtension,
		Fax,
		CreatedByUserId,
		StatusCode
	)
	VALUES
	(
		@v_GroupName ,
		@v_AddressLine1 ,  
		@v_AddressLine2 ,  
		@v_City ,  
		@v_StateCode ,
		@v_ZipCode,  
		@v_ContactName ,
		@v_ContactPhoneNumber,
		@v_ContactPhoneNumberExtension,  
		@v_Website ,
		@v_PhoneNumber ,
		@v_PhoneNumberExtension ,
		@v_Fax ,
		@i_AppUserId,
		@v_StatusCode
	)

    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_InsuranceGroupID  = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Insert InsuranceGroup'
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
    ON OBJECT::[dbo].[usp_InsuranceGroup_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

