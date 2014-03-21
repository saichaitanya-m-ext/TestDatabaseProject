/*        
------------------------------------------------------------------------------        
Procedure Name: usp_ExternalCareProvider_Search       
Description   : This procedure is used to get the details from ExternalCareProvider table       
Created By    : Aditya        
Created Date  : 25-Mar-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
02-June-2010  NagaBabu  added @vc_City
09-June-2010  NagaBabu  added @vc_ZipCode
21-June-2010  NagaBabu  deleted UserProviders.PatientUserId in select statement  
20-Sep-10 Pramod Included UserProviders.StatusCode = 'A' in the join condition
01-April-2011 NagaBabu Added order by clause
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_ExternalCareProvider_Search]
(
 @i_AppUserId KEYID
,@i_ExternalProviderId KEYID = NULL
,@i_PatientUserId KEYID = NULL
,@vc_FirstName SOURCENAME = NULL
,@vc_LastName SOURCENAME = NULL
,@vc_EmailId EMAILID = NULL
,@vc_PhoneNumber PHONE = NULL
,@vc_Fax FAX = NULL
,@vc_AddressLine1 ADDRESS = NULL
,@vc_AddressLine2 ADDRESS = NULL
,@vc_StatusCode STATUSCODE = NULL
,@vc_City CITY = NULL
,@vc_ZipCode ZIPCODE = NULL
)
AS
BEGIN TRY
      SET NOCOUNT ON         
-- Check if valid Application User ID is passed      

      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END


      SELECT
          Provider.ProviderID ExternalProviderId
         ,FirstName
         ,LastName
         ,MiddleName
         ,PrimaryAddressLine1 AddressLine1
         ,PrimaryAddressLine2 AddressLine2
         ,PrimaryAddressCity City
         ,CSS.StateCode StateCode
         ,PrimaryAddressStateCodeID StateID
         ,PrimaryPhoneNumber PhoneNumber
         ,PrimaryPhoneNumberExtension PhoneNumberExt
         ,PrimaryEmailAddress EmailId
         ,TertiaryPhoneNumber Fax
         ,Provider.CreatedByUserID
         ,Provider.CreatedDate
         ,Provider.LastModifiedByUserID
         ,Provider.LastModifiedDate
         ,CASE AccountStatusCode
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'InActive'
            ELSE ''
          END AS StatusDescription
         ,PrimaryAddressPostalCode ZipCode
      FROM
          Provider
      LEFT OUTER JOIN PatientProvider 
         ON PatientProvider.ProviderID = Provider.ProviderID    
	 LEFT JOIN CodeSetState CSS 
		 ON CSS.StateID = Provider.PRIMARYADDRESSSTATECODEID
      WHERE
          IsExternalProvider = 1
          AND (PatientProvider.PatientID = @i_PatientUserId OR @i_PatientUserId IS NULL)
          AND ( Provider.ProviderID = @i_ExternalProviderId
                OR @i_ExternalProviderId IS NULL
              )
          AND ( FirstName LIKE '%' + @vc_FirstName + '%'
                OR @vc_FirstName = ''
                OR @vc_FirstName IS NULL
              )
          AND ( LastName LIKE '%' + @vc_LastName + '%'
                OR @vc_LastName = ''
                OR @vc_LastName IS NULL
              )
          AND ( PrimaryEmailAddress LIKE '%' + @vc_EmailId + '%'
                OR @vc_EmailId = ''
                OR @vc_EmailId IS NULL
              )
          AND ( PrimaryPhoneNumber LIKE '%' + @vc_PhoneNumber + '%'
                OR @vc_PhoneNumber = ''
                OR @vc_PhoneNumber IS NULL
              )
          AND ( PrimaryAddressLine1 LIKE '%' + @vc_AddressLine1 + '%'
                OR @vc_AddressLine1 = ''
                OR @vc_AddressLine1 IS NULL
              )
          AND ( PrimaryAddressLine2 LIKE '%' + @vc_AddressLine2 + '%'
                OR @vc_AddressLine2 = ''
                OR @vc_AddressLine2 IS NULL
              )
          AND ( PrimaryAddressCity LIKE '%' + @vc_City + '%'
                OR @vc_City = ''
                OR @vc_City IS NULL
              )
          AND ( TertiaryPhoneNumber LIKE '%' + @vc_Fax + '%'
                OR @vc_Fax = ''
                OR @vc_Fax IS NULL
              )
          AND ( AccountStatusCode = @vc_StatusCode
                OR @vc_StatusCode IS NULL
              )
          AND ( PrimaryAddressPostalCode = @vc_ZipCode
                OR @vc_ZipCode IS NULL
              )
              
	--and  ( UserProviders.PatientUserId = @i_PatientUserId OR @i_PatientUserId IS NULL )    
      ORDER BY
          ExternalProviderId DESC
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
    ON OBJECT::[dbo].[usp_ExternalCareProvider_Search] TO [FE_rohit.r-ext]
    AS [dbo];

