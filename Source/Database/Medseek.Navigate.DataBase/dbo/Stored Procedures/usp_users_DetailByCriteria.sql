
/*            
------------------------------------------------------------------------------            
Procedure Name: [usp_users_DetailByCriteria]          
Description   : This procedure is used to get the UsersDetails    
Created By    : NagaBabu            
Created Date  : 27-Aug-2010    
-- usp_users_DetailByCriteria 2, 'And PatientId in (Select PatientId from PopulationDefinitionPatients where  PopulationDefinitionID= 66 AND StatusCode=''A'')',0

--Usp_users_DetailByCriteria 2,'And ProviderId in (Select ProviderId from careteamMembers where AccountStatusCode=''A'' AND careteamid=13)',1        
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION   
30-Aug-2010 NagaBabu Added COALESCE condition for FullName field in dynamic sql statement  
03-APR-2013 Mohan Added  Provider Table and added Flag Condition to get details of Provider List.             
------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_users_DetailByCriteria] (
	@i_AppUserid KeyId
	,@nv_CriteriaSQL NVARCHAR(MAX)
	,@i_IsFlag BIT = 0
	)
AS
BEGIN TRY
	SET NOCOUNT ON

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

	IF (@i_IsFlag = 0)
	BEGIN
		IF @nv_CriteriaSQL IS NOT NULL
			OR @nv_CriteriaSQL <> ''
		BEGIN
			DECLARE @nv_PrefixSQL NVARCHAR(MAX) = 
				'SELECT   
          FullName As [Full Name]  
         ,[Gender]  
         ,CONVERT(VARCHAR(10),DateOfBirth, 101) As Birthday  
         ,Age  
         ,PrimaryEmailAddress EmailIdPrimary  
         ,SecondaryEmailAddress EmailIdAlternate  
         ,PrimaryPhoneNumber PhoneNumberPrimary  
         ,PrimaryPhoneNumberExtension PhoneNumberExtensionPrimary  
         ,SecondaryPhoneNumber PhoneNumberAlternate  
         ,SecondaryPhoneNumberExtension PhoneNumberExtensionAlternate  
         ,Fax  
         ,AddressLine1  
         ,AddressLine2  
         ,City  
         ,StateCode  
         ,ZipCode  
         ,PrimaryAddressContactName EmergencyContactName  
         ,MemberNum MedicalRecordNumber  
         ,AcceptsFaxCommunications  
         ,AcceptsEmailCommunications  
         ,AcceptsSMSCommunications  
         ,AcceptsMassCommunications  
         ,AcceptsPreventativeCommunications  
         ,CommunicationType PreferedCommunicationType  
         ,EthnicityName EthnicityID  
         ,RaceName  
         ,CallTimeName   
         ,UserStatuscode  
         FROM [Patients] U  
        WHERE u.[UserStatusCode] = ''A'' '
				,@nv_FullSQL NVARCHAR(MAX) = ''

			SET @nv_FullSQL = @nv_PrefixSQL + ' ' + @nv_CriteriaSQL

			EXEC (@nv_FullSQL)
		END
	END

	IF (@i_IsFlag = 1)
	BEGIN
		IF @nv_CriteriaSQL IS NOT NULL
			OR @nv_CriteriaSQL <> ''
		BEGIN
			DECLARE @nv_PrefixSQL1 NVARCHAR(MAX) = 
				'SELECT 
        p.Providerid,  
         p.Firstname + '' ''+ p.LastName + '' ''+p.Middlename AS FullName,   
         [Gender] ,  
         OrganizationName,  
         PrimaryEmailAddress EmailIdPrimary,  
         SecondaryEmailAddress EmailIdAlternate,  
         PrimaryPhoneNumber PhoneNumberPrimary,  
         PrimaryPhoneNumberExtension PhoneNumberExtensionPrimary,  
         SecondaryPhoneNumber PhoneNumberAlternate,  
         SecondaryPhoneNumberExtension PhoneNumberExtensionAlternate,  
         TertiaryPhoneNumber,  
         TertiaryPhoneNumberExtension,  
         PrimaryAddressLine1,  
         SecondaryAddressLine1,  
         PrimaryAddressCity,  
         PrimaryAddressStateCodeID,  
         CS.StateName,  
         PrimaryAddressPostalCode,  
         PrimaryAddressContactName EmergencyContactName,  
         AccountStatusCode  
           
     FROM [PROVIDER]P   
     LEFT JOIN  CODESETSTATE CS  
     ON CS.StateID = P.PrimaryAddressStateCodeID 
     WHERE P.AccountStatusCode=''A'''
				,@nv_FullSQL1 NVARCHAR(MAX) = ''

			SET @nv_FullSQL1 = @nv_PrefixSQL1 + ' ' + @nv_CriteriaSQL

			EXEC (@nv_FullSQL1)
		END
	END
END TRY

-------------------------------------------------------------------------------------------------------------------------   
BEGIN CATCH
	-- Handle exception          
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_users_DetailByCriteria] TO [FE_rohit.r-ext]
    AS [dbo];

