  
/*      
------------------------------------------------------------------------------      
Procedure Name: [[usp_Provider_Profile_Update]]      
Description   : This procedure is used to update record in Provider table  
Created By    : Mohan      
Created Date  : 26-Mar-2013      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
  
------------------------------------------------------------------------------      
*/  
CREATE PROCEDURE [dbo].[usp_Provider_ProfileUpdate] (  
 @i_AppUserId KEYID  
 ,@i_ProviderID KEYID  
 ,@v_NamePrefix VARCHAR(10) = NULL  
 ,@v_NameSuffix VARCHAR(10) = NULL  
 ,@v_FirstName LASTNAME = NULL  
 ,@v_MiddleName MIDDLENAME = NULL  
 ,@v_LastName FIRSTNAME = NULL  
 ,@i_ProviderTypeID KEYID = NULL  
 ,@v_OrganizationName SHORTDESCRIPTION = NULL  
 ,@v_IsCareProvider IsIndicator = NULL  
 ,@v_InsuranceLicenseNumber VARCHAR(80) = NULL  
 ,@v_SecondaryAlternativeProviderID VARCHAR(80) = NULL  
 ,@v_Gender UNIT = NULL  
 ,@v_NPINumber PIN = NULL  
 ,@v_ProviderURL ShortDescription = NULL  
 ,@v_DEANumber VARCHAR(30) = NULL  
 ,@v_TaxID_EIN_SSN VARCHAR(10) = NULL  
 ,@v_PrimaryAddressContactName VARCHAR(60) = NULL  
 ,@v_PrimaryAddressContactTitle VARCHAR(20) = NULL  
 ,@i_PrimaryAddressTypeID KEYID = NULL  
 ,@v_PrimaryAddressLine1 VARCHAR(60) = NULL  
 ,@v_PrimaryAddressLine2 VARCHAR(60) = NULL  
 ,@v_PrimaryAddressLine3 VARCHAR(60) = NULL  
 ,@v_PrimaryAddressCity VARCHAR(60) = NULL  
 ,@i_PrimaryAddressStateCodeID KEYID = NULL  
 ,@i_PrimaryAddressCountyID KEYID = NULL  
 ,@i_PrimaryAddressCountryCodeID KEYID = NULL  
 ,@v_PrimaryAddressPostalCode VARCHAR(20) = NULL  
 ,@v_PrimaryPhoneContactName VARCHAR(60) = NULL  
 ,@v_PrimaryPhoneContactTitle VARCHAR(120) = NULL  
 ,@i_PrimaryPhoneTypeID KEYID = NULL  
 ,@v_PrimaryPhoneNumber VARCHAR(15) = NULL  
 ,@v_PrimaryPhoneNumberExtension VARCHAR(20) = NULL  
 ,@v_PrimaryEmailAddressContactName VARCHAR(60) = NULL  
 ,@v_PrimaryEmailAddressContactTilte VARCHAR(120) = NULL  
 ,@i_PrimaryEmailAddressTypeID KEYID = NULL  
 ,@v_PrimaryEmailAddress VARCHAR(256) = NULL  
 ,@v_UserStatusCode VARCHAR(20) = NULL  
 ,@v_SecondaryAddressContactName VARCHAR(60) = NULL  
 ,@v_SecondaryAddressContactTitle VARCHAR(120) = NULL  
 ,@i_SecondaryAddressTypeID KEYID = NULL  
 ,@v_SecondaryAddressLine1 VARCHAR(60) = NULL  
 ,@v_SecondaryAddressLine2 VARCHAR(60) = NULL  
 ,@v_SecondaryAddressLine3 VARCHAR(60) = NULL  
 ,@v_SecondaryAddressCity VARCHAR(60) = NULL  
 ,@v_SecondaryAddressStateCodeID KEYID = NULL  
 ,@i_SecondaryAddressCountyID KEYID = NULL  
 ,@i_SecondaryAddressCountryCodeID KEYID = NULL  
 ,@v_SecondaryAddressPostalCode VARCHAR(20) = NULL  
 ,@v_SecondaryPhoneContactName VARCHAR(60) = NULL  
 ,@v_SecondaryPhoneContactTitle VARCHAR(120) = NULL  
 ,@i_SecondaryPhoneTypeID KEYID = NULL  
 ,@v_SecondaryPhoneNumber VARCHAR(15) = NULL  
 ,@v_SecondaryPhoneNumberExtension VARCHAR(20) = NULL  
 ,@v_TertiaryPhoneContactName VARCHAR(60) = NULL  
 ,@v_TertiaryPhoneContactTitle VARCHAR(120) = NULL  
 ,@v_TertiaryPhoneTypeID KEYID = NULL  
 ,@v_TertiaryPhoneNumber VARCHAR(15) = NULL  
 ,@v_TertiaryPhoneNumberExtension VARCHAR(20) = NULL  
 ,@v_SecondaryEmailAddressContactName VARCHAR(60) = NULL  
 ,@v_SecondaryEmailAddressContactTitle VARCHAR(60) = NULL  
 ,@i_SecondaryEmailAddresTypeID KEYID = NULL  
 ,@v_SecondaryEmailAddress VARCHAR(256) = NULL  
 )  
AS  
BEGIN TRY  
 SET NOCOUNT ON  
  
 DECLARE @l_numberOfRecordsUpdated INT  
  
 -- Check if valid Application User ID is passed      
 IF (@i_AppUserId IS NULL)  
  OR (@i_AppUserId <= 0)  
 BEGIN  
  RAISERROR (  
    N'Invalid Application User ID %d passed.'  
    ,17  
    ,1  
    ,@i_AppUserId  
    )  
 END  
 --exec sproc_Insertusers @v_NamePrefix ,@v_FirstName
 UPDATE Provider  
 SET NamePrefix = @v_NamePrefix  
  ,NameSuffix = @v_NameSuffix  
  ,FirstName = @v_FirstName  
  ,MiddleName = @v_MiddleName  
  ,LastName = @v_LastName  
  ,ProviderTypeID = @i_ProviderTypeID  
  ,OrganizationName = @v_OrganizationName  
  ,IsCareProvider = @v_IsCareProvider  
  ,InsuranceLicenseNumber = @v_InsuranceLicenseNumber  
  ,SecondaryAlternativeProviderID = @v_SecondaryAlternativeProviderID  
  ,Gender = @v_Gender  
  ,NPINumber = @v_NPINumber  
  ,ProviderURL = @v_ProviderURL  
  ,DEANumber = @v_DEANumber  
  ,TaxID_EIN_SSN = @v_TaxID_EIN_SSN  
  ,PrimaryAddressContactName = @v_PrimaryAddressContactName  
  ,PrimaryAddressContactTitle = @v_PrimaryAddressContactTitle  
  ,PrimaryAddressTypeID = @i_PrimaryAddressTypeID  
  ,PrimaryAddressLine1 = @v_PrimaryAddressLine1  
  ,PrimaryAddressLine2 = @v_PrimaryAddressLine2  
  ,PrimaryAddressLine3 = @v_PrimaryAddressLine3  
  ,PrimaryAddressCity = @v_PrimaryAddressCity  
  ,PrimaryAddressStateCodeID = @i_PrimaryAddressStateCodeID  
  ,PrimaryAddressCountyID = @i_PrimaryAddressCountyID  
  ,PrimaryAddressCountryCodeID = @i_PrimaryAddressCountryCodeID  
  ,PrimaryAddressPostalCode = @v_PrimaryAddressPostalCode  
  ,PrimaryPhoneContactName = @v_PrimaryPhoneContactName  
  ,PrimaryPhoneContactTitle = @v_PrimaryPhoneContactTitle  
  ,PrimaryPhoneTypeID = @i_PrimaryPhoneTypeID  
  ,PrimaryPhoneNumber = @v_PrimaryPhoneNumber  
  ,PrimaryPhoneNumberExtension = @v_PrimaryPhoneNumberExtension  
  ,PrimaryEmailAddressContactName = @v_PrimaryEmailAddressContactName  
  ,PrimaryEmailAddressContactTilte = @v_PrimaryEmailAddressContactTilte  
  ,PrimaryEmailAddressTypeID = @i_PrimaryEmailAddressTypeID  
  ,PrimaryEmailAddress = @v_PrimaryEmailAddress  
  ,AccountStatusCode = 'A' 
  ,SecondaryAddressContactName = @v_SecondaryAddressContactName  
  ,SecondaryAddressContactTitle = @v_SecondaryAddressContactTitle  
  ,SecondaryAddressTypeID = @i_SecondaryAddressTypeID  
  ,SecondaryAddressLine1 = @v_SecondaryAddressLine1  
  ,SecondaryAddressLine2 = @v_SecondaryAddressLine3  
  ,SecondaryAddressLine3 = @v_SecondaryAddressLine3  
  ,SecondaryAddressCity = @v_SecondaryAddressCity  
  ,SecondaryAddressStateCodeID = @v_SecondaryAddressStateCodeID  
  ,SecondaryAddressCountyID = @i_SecondaryAddressCountyID  
  ,SecondaryAddressCountryCodeID = @i_SecondaryAddressCountryCodeID  
  ,SecondaryPhoneContactName = @v_SecondaryPhoneContactName  
  ,SecondaryPhoneContactTitle = @v_SecondaryPhoneContactTitle  
  ,SecondaryPhoneTypeID = @i_SecondaryPhoneTypeID  
  ,SecondaryPhoneNumber = @v_SecondaryPhoneNumber  
  ,SecondaryPhoneNumberExtension = @v_SecondaryPhoneNumberExtension  
  ,TertiaryPhoneContactName = @v_TertiaryPhoneContactName  
  ,TertiaryPhoneContactTitle = @v_TertiaryPhoneContactTitle  
  ,TertiaryPhoneTypeID = @v_TertiaryPhoneTypeID  
  ,TertiaryPhoneNumber = @v_TertiaryPhoneNumber  
  ,TertiaryPhoneNumberExtension = @v_TertiaryPhoneNumberExtension  
  ,SecondaryAddressPostalCode = @v_SecondaryAddressPostalCode  
  ,SecondaryEmailAddressContactName = @v_SecondaryEmailAddressContactName  
  ,SecondaryEmailAddressContactTitle = @v_SecondaryEmailAddressContactTitle  
  ,SecondaryEmailAddresTypeID = @i_SecondaryEmailAddresTypeID  
  ,SecondaryEmailAddress = @v_SecondaryEmailAddress  
 WHERE ProviderID = @i_ProviderID  
  
 SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT  
  
 UPDATE aspnet_Membership  
 SET aspnet_Membership.IsLockedOut = CASE   
   WHEN Provider.AccountStatusCode = 'L'  
    THEN 1  
   ELSE 0  
   END  
  ,aspnet_Membership.FailedPasswordAttemptCount = CASE   
   WHEN Provider.AccountStatusCode = 'L'  
    THEN 5  
   ELSE 0  
   END  
  ,aspnet_Membership.Email = ISNULL(Provider.PrimaryEmailAddress, aspnet_Membership.Email)  
  ,aspnet_Membership.LoweredEmail = ISNULL(LOWER(Provider.PrimaryEmailAddress), aspnet_Membership.Email)  
 FROM aspnet_Membership  
 INNER JOIN aspnet_users  
  ON aspnet_users.UserId = aspnet_Membership.UserId  
 INNER JOIN Users  
  ON Users.UserLoginName = aspnet_users.UserName  
 INNER JOIN UserGroup  
  ON UserGroup.UserID = Users.UserId  
 INNER JOIN Provider  
  ON Provider.ProviderID = UserGroup.ProviderID  
 WHERE Provider.ProviderID = @i_ProviderID  
  
 UPDATE Users  
 SET AccountStatusCode = I.AccountStatusCode  
 FROM Provider I  
 INNER JOIN UserGroup UG  
  ON UG.ProviderID = I.ProviderID  
 WHERE users.UserId = ug.UserID  
  AND UG.ProviderID = @i_ProviderID  
  
 IF @l_numberOfRecordsUpdated <> 1  
 BEGIN  
  RAISERROR (  
    N'Invalid Row count %d passed to update Immunization Details'  
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
    ON OBJECT::[dbo].[usp_Provider_ProfileUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

