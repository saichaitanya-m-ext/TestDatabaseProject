/*  
----------------------------------------------------------------------------------  
Procedure Name: [usp_User_Insert]  
Description   : This proc is used to creae either patient/provider   
Created By    : Rathnam  
Created Date  : 15-March-2013  
----------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY    DESCRIPTION  
06-11-2013  GouriShankar Renamed SpecialtyCodeID to CMSProviderSpecialtyCodeID  
----------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_User_Insert] @i_AppUserId KEYID
	,@i_UserId KEYID
	,@b_IsPatient BIT
	,@i_SecurityRoleID KEYID = NULL
	,@v_NamePrefix VARCHAR(10) = NULL
	,@v_NameSuffix VARCHAR(10) = NULL
	,@v_FirstName LASTNAME = NULL
	,@v_MiddleName MIDDLENAME = NULL
	,@v_LastName FIRSTNAME = NULL
	,@v_PreferredName SHORTDESCRIPTION = NULL
	,@v_SSN SSN = NULL
	,@i_CountryOfBirthID KEYID = NULL
	,@i_MaritalStatusID KEYID = NULL
	,@i_BloodTypeID KEYID = NULL
	,@v_PCPName VARCHAR(120) = NULL
	,@i_PreferredCommunicationTypeID KEYID = NULL
	,@v_MedicalRecordNumber VARCHAR(20) = NULL
	,@v_Title SHORTDESCRIPTION = NULL
	,@v_Gender UNIT = NULL
	,@dt_DateOfBirth USERDATE = NULL
	,@i_RaceID KEYID = NULL
	,@i_EthnicityID KEYID = NULL
	,@v_NPINumber PIN = NULL
	,@i_CallTimePreferenceId KEYID = NULL
	,@v_UserStatusCode STATUSCODE = NULL
	,@v_MemberNum SOURCENAME = NULL
	,@t_UserspeacialityID TTYPEKEYID READONLY
	,@t_UserLanguageID TBLUSERLANGUAGE READONLY
	,@v_PCPNPI VARCHAR(80) = NULL
	,@v_DEANumber VARCHAR(30) = NULL
	,@v_TaxID_EIN_SSN VARCHAR(10) = NULL
	,@v_PrimaryPhoneContactName VARCHAR(60) = NULL
	,@i_PrimaryPhoneContactRelationshipToPatientID KEYID = NULL
	,@i_PrimaryPhoneTypeID KEYID = NULL
	,@v_PrimaryPhoneNumber VARCHAR(15) = NULL
	,@v_PrimaryPhoneNumberExtension VARCHAR(20) = NULL
	,@v_PrimaryEmailAddressContactName VARCHAR(60) = NULL
	,@i_PrimaryEmailAddressContactRelationshipToPatientID KEYID = NULL
	,@i_PrimaryEmailAddressTypeID KEYID = NULL
	,@v_PrimaryEmailAddress VARCHAR(256) = NULL
	,@v_PrimaryAddressContactName VARCHAR(60) = NULL
	,@i_PrimaryAddressContactRelationshipToPatientID VARCHAR(20) = NULL
	,@i_PrimaryAddressTypeID KEYID = NULL
	,@v_PrimaryAddressLine1 VARCHAR(60) = NULL
	,@v_PrimaryAddressLine2 VARCHAR(60) = NULL
	,@v_PrimaryAddressLine3 VARCHAR(60) = NULL
	,@v_PrimaryAddressCity VARCHAR(60) = NULL
	,@i_PrimaryAddressStateCodeID KEYID = NULL
	,@i_PrimaryAddressCountyID KEYID = NULL
	,@i_PrimaryAddressCountryCodeID VARCHAR(60) = NULL
	,@v_PrimaryAddressPostalCode VARCHAR(20) = NULL
	,@i_ProviderTypeID KEYID = NULL
	,@v_OrganizationName SHORTDESCRIPTION = NULL
	,@v_IsCareProvider ISINDICATOR = NULL
	,@v_InsuranceLicenseNumber VARCHAR(80) = NULL
	,@v_SecondaryAlternativeProviderID VARCHAR(80) = NULL
	,@v_ProviderURL SHORTDESCRIPTION = NULL
	,@v_PrimaryPhoneContactTitle VARCHAR(120) = NULL
	,@v_PrimaryPhoneTypeID VARCHAR(15) = NULL
	,@v_PrimaryEmailAddressContactTilte VARCHAR(120) = NULL
	,@v_PrimaryEmailAddressTypeID VARCHAR(15) = NULL
	,@v_PrimaryAddressContactTitle VARCHAR(120) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @i_numberOfRecordsUpdated INT

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

	-- Check duplicates for member number  
	BEGIN TRANSACTION

	DECLARE @i_RoleName VARCHAR(500)
		,@v_aspnetEmail NVARCHAR(256)
		,@i_Id INT

	IF @b_IsPatient = 1
		AND NOT EXISTS (
			SELECT 1
			FROM Patient
			WHERE UserID = @i_UserId
			)
	BEGIN
		INSERT INTO Patient (
			UserID
			,FirstName
			,LastName
			,DateOfBirth
			,AccountStatusCode
			,CreatedByUserID
			,CreatedDate
			)
		SELECT @i_UserId
			,@v_FirstName
			,@v_LastName
			,@dt_DateOfBirth
			,'A'
			,@i_AppUserId
			,GETDATE()

		SELECT @i_Id = SCOPE_IDENTITY()

		INSERT INTO UsersSecurityRoles (
			SecurityRoleId
			,PatientID
			,CreatedByUserId
			,CreatedDate
			)
		SELECT @i_SecurityRoleID
			,@i_Id
			,@i_AppUserId
			,GETDATE()

		SELECT @v_aspnetEmail = INS.Email
		FROM aspnet_Membership INS
		INNER JOIN aspnet_users
			ON INS.UserId = aspnet_users.UserId
		INNER JOIN Users u
			ON u.UserLoginName = aspnet_Users.UserName
		WHERE u.UserId = @i_UserId

		UPDATE Patient
		SET PrimaryEmailAddress = @v_aspnetEmail
			,LastModifiedDate = GETDATE()
		WHERE PatientID = @i_Id

		UPDATE Users
		SET IsPatient = 1
		WHERE UserId = @i_UserId

		UPDATE Patient
		SET NamePrefix = ISNULL(@v_NamePrefix, NamePrefix)
			,NameSuffix = ISNULL(@v_NameSuffix, NameSuffix)
			,LastName = ISNULL(@v_LastName, LastName)
			,MiddleName = ISNULL(@v_MiddleName, MiddleName)
			,FirstName = ISNULL(@v_FirstName, FirstName)
			,PreferredName = ISNULL(@v_PreferredName, PreferredName)
			,SSN = ISNULL(@v_SSN, SSN)
			,CountryOfBirthID = ISNULL(@i_CountryOfBirthID, CountryOfBirthID)
			,MaritalStatusID = ISNULL(@i_MaritalStatusID, MaritalStatusID)
			,BloodTypeID = ISNULL(@i_BloodTypeID, BloodTypeID)
			,PCPName = ISNULL(@v_PCPName, PCPName)
			,PreferredCommunicationTypeID = ISNULL(@i_PreferredCommunicationTypeID, PreferredCommunicationTypeID)
			,MedicalRecordNumber = ISNULL(@v_MedicalRecordNumber, MedicalRecordNumber)
			,Title = ISNULL(@v_Title, Title)
			,Gender = ISNULL(@v_Gender, Gender)
			,DateOfBirth = ISNULL(@dt_DateOfBirth, DateOfBirth)
			,RaceID = ISNULL(@i_RaceID, RaceID)
			,EthnicityID = ISNULL(@i_EthnicityID, EthnicityID)
			,PCPNPI = ISNULL(@v_PCPNPI, PCPNPI)
			,CallTimePreferenceID = ISNULL(@i_CallTimePreferenceId, CallTimePreferenceID)
			,PrimaryPhoneContactName = ISNULL(@v_PrimaryPhoneContactName, PrimaryPhoneContactName)
			,PrimaryPhoneContactRelationshipToPatientID = ISNULL(@i_PrimaryPhoneContactRelationshipToPatientID, PrimaryPhoneContactRelationshipToPatientID)
			,PrimaryPhoneTypeID = ISNULL(@i_PrimaryPhoneTypeID, PrimaryPhoneTypeID)
			,PrimaryPhoneNumber = ISNULL(@v_PrimaryPhoneNumber, PrimaryPhoneNumber)
			,PrimaryPhoneNumberExtension = ISNULL(@v_PrimaryPhoneNumberExtension, PrimaryPhoneNumberExtension)
			,PrimaryEmailAddressContactName = ISNULL(@v_PrimaryEmailAddressContactName, PrimaryEmailAddressContactName)
			,PrimaryEmailAddressContactRelationshipToPatientID = ISNULL(@i_PrimaryEmailAddressContactRelationshipToPatientID, PrimaryEmailAddressContactRelationshipToPatientID)
			,PrimaryEmailAddressTypeID = ISNULL(@i_PrimaryEmailAddressTypeID, PrimaryEmailAddressTypeID)
			,PrimaryEmailAddress = ISNULL(@v_PrimaryEmailAddress, PrimaryEmailAddress)
			,PrimaryAddressContactName = ISNULL(@v_PrimaryAddressContactName, PrimaryAddressContactName)
			,PrimaryAddressContactRelationshipToPatientID = ISNULL(@i_PrimaryAddressContactRelationshipToPatientID, PrimaryAddressContactRelationshipToPatientID)
			,PrimaryAddressTypeID = ISNULL(@i_PrimaryAddressTypeID, PrimaryAddressTypeID)
			,PrimaryAddressLine1 = ISNULL(@v_PrimaryAddressLine1, PrimaryAddressLine1)
			,PrimaryAddressLine2 = ISNULL(@v_PrimaryAddressLine2, PrimaryAddressLine2)
			,PrimaryAddressLine3 = ISNULL(@v_PrimaryAddressLine3, PrimaryAddressLine3)
			,PrimaryAddressCity = ISNULL(@v_PrimaryAddressCity, PrimaryAddressCity)
			,PrimaryAddressStateCodeID = ISNULL(@i_PrimaryAddressStateCodeID, PrimaryAddressStateCodeID)
			,PrimaryAddressCountyID = ISNULL(@i_PrimaryAddressCountyID, PrimaryAddressCountyID)
			,PrimaryAddressCountryCodeID = ISNULL(@i_PrimaryAddressCountryCodeID, PrimaryAddressCountryCodeID)
			,PrimaryAddressPostalCode = ISNULL(@v_PrimaryAddressPostalCode, PrimaryAddressPostalCode)
			--,ProfessionalTypeID = ISNULL(@i_ProfessionalTypeID , ProfessionalTypeID)  
			--,PrimaryEmailAddress = ISNULL(@v_EmailIdPrimary , PrimaryEmailAddress)  
			--,SecondaryEmailAddress = ISNULL(@v_EmailIdAlternate , SecondaryEmailAddress)  
			--,PrimaryPhoneNumber = ISNULL(@v_PhoneNumberPrimary , PrimaryPhoneNumber)  
			--,PrimaryPhoneNumberExtension = ISNULL(@v_PhoneNumberExtensionPrimary , PrimaryPhoneNumberExtension)  
			--,SecondaryPhoneNumber = ISNULL(@v_PhoneNumberAlternate , SecondaryPhoneNumber)  
			--,SecondaryPhoneNumberExtension = ISNULL(@v_PhoneNumberExtensionAlternate , SecondaryPhoneNumberExtension)  
			--,TertiaryPhoneNumber = ISNULL(@v_Fax , TertiaryPhoneNumber)  
			--,PrimaryAddressLine1 = ISNULL(@v_AddressLine1 , PrimaryAddressLine1)  
			--,PrimaryAddressLine2 = ISNULL(@v_AddressLine2 , PrimaryAddressLine2)  
			--,PrimaryAddressCity = ISNULL(@v_City , PrimaryAddressCity)  
			--,PrimaryAddressStateCode = ISNULL(@v_State , PrimaryAddressStateCode)  
			--,PrimaryAddressPostalCode = ISNULL(@v_ZipCode , PrimaryAddressPostalCode)  
			--,MedicalRecordNumber = ISNULL(@v_MemberNum , MedicalRecordNumber)  
			--,PreferredCommunicationTypeID = ISNULL(@i_PreferedCommunicationTypeID , PreferredCommunicationTypeID)  
			--,RaceID = ISNULL(@i_RaceID , RaceID)  
			--,CallTimePreferenceId = ISNULL(@i_CallTimePreferenceId , CallTimePreferenceId)  
			,AccountStatusCode = ISNULL(@v_UserStatusCode, AccountStatusCode)
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		WHERE PatientID = @i_Id

		IF EXISTS (
				SELECT 1
				FROM @t_UserLanguageID UsersLanguage
				WHERE UsersLanguage.LanguageId IS NOT NULL
				)
		BEGIN
			INSERT INTO PatientLanguage (
				PatientID
				,LanguageID
				,IsPrimarySpoken
				,IsPrimaryWritten
				,CreatedByUserId
				)
			SELECT @i_ID
				,UsersLanguage.LanguageId
				,IsSpoken
				,IsWritten
				,@i_AppUserID
			FROM @t_UserLanguageID UsersLanguage
		END
	END
	ELSE
	BEGIN
		IF @b_IsPatient = 0
			AND NOT EXISTS (
				SELECT 1
				FROM Provider
				WHERE UserID = @i_UserId
				)
		BEGIN
			INSERT INTO Provider (
				IsIndividual
				,IsCareProvider
				,IsExternalProvider
				,AccountStatusCode
				,CreatedByUserID
				,CreatedDate
				,UserID
				)
			SELECT 1
				,@v_IsCareProvider
				,CASE 
					WHEN @v_IsCareProvider = 0
						THEN 1
					ELSE 0
					END
				,'A'
				,@i_AppUserId
				,GETDATE()
				,@i_UserId

			SELECT @i_Id = SCOPE_IDENTITY()

			INSERT INTO UserGroup (
				UserID
				,ProviderID
				,CreatedByUserId
				,CreatedDate
				)
			VALUES (
				@i_UserId
				,@i_Id
				,@i_AppUserId
				,GETDATE()
				)

			SELECT @v_aspnetEmail = INS.Email
			FROM aspnet_Membership INS
			INNER JOIN aspnet_users
				ON INS.UserId = aspnet_users.UserId
			INNER JOIN Users u
				ON u.UserLoginName = aspnet_Users.UserName
			WHERE u.UserId = @i_UserId

			UPDATE Provider
			SET PrimaryEmailAddress = @v_aspnetEmail
				,LastModifiedDate = GETDATE()
			WHERE ProviderID = @i_Id

			UPDATE Users
			SET IsProvider = 1
			WHERE UserId = @i_UserId

			UPDATE Provider
			SET NamePrefix = ISNULL(@v_NamePrefix, NamePrefix)
				,NameSuffix = ISNULL(@v_NameSuffix, NameSuffix)
				,FirstName = ISNULL(@v_FirstName, FirstName)
				,MiddleName = ISNULL(@v_MiddleName, MiddleName)
				,LastName = ISNULL(@v_LastName, LastName)
				,ProviderTypeID = ISNULL(@i_ProviderTypeID, ProviderTypeID)
				,OrganizationName = ISNULL(@v_OrganizationName, OrganizationName)
				,IsCareProvider = ISNULL(@v_IsCareProvider, IsCareProvider)
				,InsuranceLicenseNumber = ISNULL(@v_InsuranceLicenseNumber, InsuranceLicenseNumber)
				,SecondaryAlternativeProviderID = ISNULL(@v_SecondaryAlternativeProviderID, SecondaryAlternativeProviderID)
				,Gender = ISNULL(@v_Gender, Gender)
				,NPINumber = ISNULL(@v_NPINumber, NPINumber)
				,ProviderURL = ISNULL(@v_ProviderURL, ProviderURL)
				,DEANumber = ISNULL(@v_DEANumber, DEANumber)
				,TaxID_EIN_SSN = ISNULL(@v_TaxID_EIN_SSN, TaxID_EIN_SSN)
				,PrimaryPhoneContactName = ISNULL(@v_PrimaryPhoneContactName, PrimaryPhoneContactName)
				,PrimaryPhoneContactTitle = ISNULL(@v_PrimaryPhoneContactTitle, PrimaryPhoneContactTitle)
				,PrimaryPhoneTypeID = ISNULL(@v_PrimaryPhoneTypeID, PrimaryPhoneTypeID)
				,PrimaryPhoneNumber = ISNULL(@v_PrimaryPhoneNumber, PrimaryPhoneNumber)
				,PrimaryEmailAddressContactName = ISNULL(@v_PrimaryEmailAddressContactName, PrimaryEmailAddressContactName)
				,PrimaryEmailAddressContactTilte = ISNULL(@v_PrimaryEmailAddressContactTilte, PrimaryEmailAddressContactTilte)
				,PrimaryEmailAddressTypeID = ISNULL(@v_PrimaryEmailAddressTypeID, PrimaryEmailAddressTypeID)
				,PrimaryEmailAddress = ISNULL(@v_PrimaryEmailAddress, PrimaryEmailAddress)
				,PrimaryAddressContactName = ISNULL(@v_PrimaryAddressContactName, PrimaryAddressContactName)
				,PrimaryAddressContactTitle = ISNULL(@v_PrimaryAddressContactTitle, PrimaryAddressContactTitle)
				,PrimaryAddressTypeID = ISNULL(@i_PrimaryAddressTypeID, PrimaryAddressTypeID)
				,PrimaryAddressLine1 = ISNULL(@v_PrimaryAddressLine1, PrimaryAddressLine1)
				,PrimaryAddressLine2 = ISNULL(@v_PrimaryAddressLine2, PrimaryAddressLine2)
				,PrimaryAddressLine3 = ISNULL(@v_PrimaryAddressLine3, PrimaryAddressLine3)
				,PrimaryAddressCity = ISNULL(@v_PrimaryAddressCity, PrimaryAddressCity)
				,PrimaryAddressStateCodeID = ISNULL(@i_PrimaryAddressStateCodeID, PrimaryAddressStateCodeID)
				,PrimaryAddressCountyID = ISNULL(@i_PrimaryAddressCountyID, PrimaryAddressCountyID)
				,PrimaryAddressCountryCodeID = ISNULL(@i_PrimaryAddressCountryCodeID, PrimaryAddressCountryCodeID)
				,PrimaryAddressPostalCode = ISNULL(@v_PrimaryAddressPostalCode, PrimaryAddressPostalCode)
				,
				--ProfessionalTypeID = ISNULL(@i_ProfessionalTypeID , ProfessionalTypeID),  
				--PrimaryEmailAddress = ISNULL(@v_EmailIdPrimary ,PrimaryEmailAddress),  
				--SecondaryEmailAddress = ISNULL(@v_EmailIdAlternate ,SecondaryEmailAddress),  
				--PrimaryPhoneNumber = ISNULL(@v_PhoneNumberPrimary ,PrimaryPhoneNumber),  
				--PrimaryPhoneNumberExtension = ISNULL(@v_PhoneNumberExtensionPrimary ,PrimaryPhoneNumberExtension),  
				--SecondaryPhoneNumber = ISNULL(@v_PhoneNumberAlternate ,SecondaryPhoneNumber),  
				--SecondaryPhoneNumberExtension = ISNULL(@v_PhoneNumberExtensionAlternate ,SecondaryPhoneNumberExtension),  
				--TertiaryPhoneNumber = ISNULL(@v_Fax, TertiaryPhoneNumber),  
				--PrimaryAddressLine1 = ISNULL(@v_AddressLine1 ,PrimaryAddressLine1),  
				--PrimaryAddressLine2 = ISNULL(@v_AddressLine2 ,PrimaryAddressLine2),  
				--PrimaryAddressCity = ISNULL(@v_City ,PrimaryAddressCity),  
				--PrimaryAddressStateCode = ISNULL(@v_State ,PrimaryAddressStateCode),  
				--PrimaryAddressPostalCode = ISNULL(@v_ZipCode ,PrimaryAddressPostalCode),  
				AccountStatusCode = ISNULL(@v_UserStatusCode, AccountStatusCode)
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			WHERE Providerid = @i_Id

			INSERT INTO UsersSecurityRoles (
				SecurityRoleId
				,ProviderID
				,CreatedByUserId
				,CreatedDate
				)
			SELECT @i_SecurityRoleID
				,@i_Id
				,@i_AppUserId
				,GETDATE()

			IF EXISTS (
					SELECT 1
					FROM @t_UserspeacialityID Userspeacial
					WHERE Userspeacial.tKeyId IS NOT NULL
					)
			BEGIN
				DELETE
				FROM ProviderSpecialty
				WHERE EXISTS (
						SELECT 1
						FROM ProviderSpecialty
						WHERE ProviderID = @i_ID
						)

				INSERT INTO ProviderSpecialty (
					ProviderID
					--,SpecialtyCodeID     /*06-11-2013*/  
					,CMSProviderSpecialtyCodeID
					,CreatedByUserId
					)
				SELECT @i_ID
					,UserSpecial.tKeyId
					,@i_AppUserId
				FROM @t_UserspeacialityID UserSpecial
			END

			IF EXISTS (
					SELECT 1
					FROM @t_UserLanguageID UsersLanguage
					WHERE UsersLanguage.LanguageId IS NOT NULL
					)
			BEGIN
				INSERT INTO ProviderLanguage (
					ProviderID
					,LanguageID
					,IsPrimarySpoken
					,IsPrimaryWritten
					,CreatedByUserId
					)
				SELECT @i_ID
					,LanguageId
					,IsSpoken
					,IsWritten
					,@i_AppUserID
				FROM @t_UserLanguageID UsersLanguage
			END
		END
	END

	COMMIT TRANSACTION
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
    ON OBJECT::[dbo].[usp_User_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

