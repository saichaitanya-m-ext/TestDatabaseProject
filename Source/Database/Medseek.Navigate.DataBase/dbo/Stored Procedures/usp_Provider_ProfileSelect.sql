/*    
----------------------------------------------------------------------------------    
Procedure Name: [usp_Provider_ProfileSelect]  2,7  
Description   : This procedure is used to get ProviderID and Records  from Provider Table.    
Created By    : P.V.P.Mohan    
Created Date  : 26-Mar-2013    
----------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
----------------------------------------------------------------------------------    
*/ 
CREATE PROCEDURE [dbo].[usp_Provider_ProfileSelect] 
(
  @i_AppUserId KEYID ,
  @i_ProviderID KEYID
)       
AS    
BEGIN TRY    
      SET NOCOUNT ON    
      ----- Check if valid Application User ID is passed--------------    
      IF ( @i_AppUserId IS NULL )    
      OR ( @i_AppUserId <= 0 )    
         BEGIN    
               RAISERROR ( N'Invalid Application User ID %d passed.' ,    
               17 ,    
               1 ,    
               @i_AppUserId )    
         END    
   --------- search user from the search criteria ----------------    
      SELECT    
				NamePrefix,
				NameSuffix,
				LastName,        
				FirstName,    
				MiddleName ,            
				ProviderTypeID,
				OrganizationName,
				IsCareProvider,
				InsuranceLicenseNumber,
				SecondaryAlternativeProviderID,
				Gender,
				NPINumber,
				ProviderURL,
				DEANumber,
				TaxID_EIN_SSN,
				PrimaryAddressContactName,
				PrimaryAddressContactTitle,
				PrimaryAddressTypeID,
				PrimaryAddressLine1,
				PrimaryAddressLine2,
				PrimaryAddressLine3,
				PrimaryAddressCity,
				PrimaryAddressStateCodeID,
				PrimaryAddressCountyID,
				PrimaryAddressCountryCodeID,
				PrimaryAddressPostalCode,
				SecondaryAddressContactName,
				SecondaryAddressContactTitle,
				SecondaryAddressTypeID,
				SecondaryAddressLine1,
				SecondaryAddressLine2,
				SecondaryAddressLine3,
				SecondaryAddressCity,
				SecondaryAddressStateCodeID,
				SecondaryAddressCountyID,
				SecondaryAddressCountryCodeID,
				SecondaryAddressPostalCode,
				PrimaryPhoneContactName,
				PrimaryPhoneContactTitle,
				PrimaryPhoneTypeID,
				PrimaryPhoneNumber,
				PrimaryPhoneNumberExtension,
				SecondaryPhoneContactName,
				SecondaryPhoneContactTitle,
				SecondaryPhoneTypeID,
				SecondaryPhoneNumber,
				SecondaryPhoneNumberExtension,
				TertiaryPhoneContactName,
				TertiaryPhoneContactTitle,
				TertiaryPhoneTypeID,
				TertiaryPhoneNumber,
				TertiaryPhoneNumberExtension,
				PrimaryEmailAddressContactName,
				PrimaryEmailAddressContactTilte,
				PrimaryEmailAddressTypeID,
				PrimaryEmailAddress,
				SecondaryEmailAddressContactName,
				SecondaryEmailAddressContactTitle,
				SecondaryEmailAddresTypeID,
				SecondaryEmailAddress,
				AccountStatusCode,
				Provider.LastModifiedByUserID,
				Provider.LastModifiedDate
	  FROM 
	      Provider 
					LEFT OUTER JOIN  LkUpPhoneType
						ON LkUpPhoneType.PhoneTypeID = Provider.PrimaryPhoneTypeID
					LEFT OUTER JOIN  LkUpAddressType
						ON LkUpAddressType.AddressTypeID = Provider.PrimaryAddressTypeID
					LEFT OUTER JOIN  LkUpEmailAddressType
						ON LkUpEmailAddressType.EmailAddressTypeID = Provider.PrimaryEmailAddressTypeID
					LEFT OUTER JOIN  CodeSetCountry
						ON CodeSetCountry.CountryID = Provider.PrimaryAddressCountryCodeID
					LEFT OUTER JOIN  CodeSetCounty
						ON CodeSetCounty.CountyID = Provider.PrimaryAddressCountyID
					LEFT OUTER JOIN  CodeSetState
						ON CodeSetState.StateID	 = Provider.PrimaryAddressStateCodeID
	       
	        WHERE
           ( Provider.ProviderID = @i_ProviderID OR @i_ProviderID IS NULL ) 
          
END TRY    
--------------------------------------------------------     
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID     
END CATCH

select * from LkUpPhoneType
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Provider_ProfileSelect] TO [FE_rohit.r-ext]
    AS [dbo];

