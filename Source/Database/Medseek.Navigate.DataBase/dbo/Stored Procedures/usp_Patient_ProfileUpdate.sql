/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Patient_Profile_Update    
Description   : This procedure is used to update record in Patient table
Created By    : Mohan    
Created Date  :  26-Mar-2013   
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    

------------------------------------------------------------------------------    
*/ 
CREATE PROCEDURE [dbo].[usp_Patient_ProfileUpdate]  
(  
       @i_AppUserId KEYID
      ,@i_PatientID KEYID
      ,@v_NamePrefix VARCHAR(10) = NULL
	  ,@v_NameSuffix VARCHAR(10) = NULL
      ,@v_FirstName LASTNAME = NULL
      ,@v_MiddleName MIDDLENAME = NULL
      ,@v_LastName FIRSTNAME = NULL
      ,@v_PreferredName ShortDescription = NULL
      ,@v_SSN SSN = NULL
      ,@i_CountryOfBirthID KEYID = NULL
      ,@i_MaritalStatusID KEYID = NULL
      ,@i_BloodTypeID KEYID = NULL
	  ,@i_PCPInternalProviderID KEYID = NULL
      ,@i_PreferedCommunicationTypeID KEYID = NULL
      ,@i_NoOfDependents TinyInt = NULL
      ,@i_EmploymentStatusID KEYID = NULL
      ,@i_ProfessionalTypeID  KEYID = NULL
      ,@b_IsDeceased IsIndicator = NULL
      ,@d_DeceasedDate UserDate = NULL
      ,@v_MedicalRecordNumber VARCHAR(20) = NULL
      ,@v_Title SHORTDESCRIPTION = NULL
      ,@v_Gender UNIT = NULL
      ,@dt_DateOfBirth USERDATE = NULL
	  ,@i_RaceID KEYID = NULL
	  ,@i_EthnicityID KEYID = NULL
      ,@v_PCPNPI PIN = NULL
      ,@i_CallTimePreferenceId KEYID = NULL
      ,@v_PrimaryAddressContactName  VARCHAR(60) = NULL
      ,@i_PrimaryAddressContactRelationshipToPatientID KEYID = NULL
	  ,@i_PrimaryAddressTypeID KEYID = NULL
	  ,@v_PrimaryAddressLine1 VARCHAR(60) = NULL
	  ,@v_PrimaryAddressLine2 VARCHAR(60) = NULL
	  ,@v_PrimaryAddressLine3 VARCHAR(60) = NULL
	  ,@v_PrimaryAddressCity  VARCHAR(60) = NULL
	  ,@i_PrimaryAddressStateCodeID KEYID = NULL
	  ,@i_PrimaryAddressCountyID KEYID = NULL
	  ,@i_PrimaryAddressCountryCodeID KEYID = NULL
	  ,@v_PrimaryAddressPostalCode VARCHAR(20) = NULL
	  ,@v_PrimaryPhoneContactName VARCHAR(60) = NULL
      ,@i_PrimaryPhoneContactRelationshipToPatientID KEYID = NULL
      ,@i_PrimaryPhoneTypeID KEYID = NULL
      ,@v_PrimaryPhoneNumber VARCHAR(15) = NULL
      ,@v_PrimaryPhoneNumberExtension VARCHAR(20) = NULL
      ,@v_PrimaryEmailAddressContactName VARCHAR(60) = NULL
      ,@i_PrimaryEmailAddressContactRelationshipToPatientID KEYID = NULL
      ,@i_PrimaryEmailAddressTypeID KEYID = NULL
      ,@v_PrimaryEmailAddress VARCHAR(256) = NULL
      ,@b_AcceptsFaxCommunications IsIndicator = NULL
      ,@b_AcceptsEmailCommunications IsIndicator = NULL
      ,@b_AcceptsSMSCommunications IsIndicator = NULL
      ,@b_AcceptsMassCommunications IsIndicator = NULL
      ,@b_AcceptsPreventativeCommunications IsIndicator = NULL
      ,@v_SecondaryAddressContactName  VARCHAR(60) = NULL
	  ,@i_SecondaryAddressContactRelationshipToPatientID KEYID = NULL
	  ,@i_SecondaryAddressTypeID  KEYID = NULL
	  ,@v_SecondaryAddressLine1 VARCHAR(60) = NULL
	  ,@v_SecondaryAddressLine2 VARCHAR(60) = NULL
	  ,@v_SecondaryAddressLine3 VARCHAR(60) = NULL
	  ,@v_SecondaryAddressCity  VARCHAR(60) = NULL
	  ,@i_SecondaryAddressStateCodeID KEYID = NULL
	  ,@i_SecondaryAddressCountyID   KEYID = NULL
	  ,@i_SecondaryAddressCountryCodeID KEYID = NULL
	  ,@v_SecondaryAddressPostalCode  VARCHAR(20) = NULL
	  ,@v_SecondaryEmailAddressContactName VARCHAR(60) = NULL
	  ,@i_SecondaryEmailAddressContactRelationshipToPatientID KEYID = NULL
	  ,@i_SecondaryEmailAddresTypeID KEYID = NULL
	  ,@v_SecondaryEmailAddress VARCHAR(256) = NULL
	  ,@v_SecondaryPhoneContactName VARCHAR(60) = NULL
	  ,@i_SecondaryPhoneContactRelationshipToPatient  KEYID = NULL
	  ,@i_SecondaryPhoneTypeID KEYID = NULL
	  ,@v_SecondaryPhoneNumber VARCHAR(15) = NULL
	  ,@v_SecondaryPhoneNumberExtension VARCHAR(20) = NULL
	  ,@v_TertiaryPhoneContactName VARCHAR(60) = NULL
	  ,@i_TertiaryPhoneContactRealtionToPatientID  KEYID = NULL
	  ,@i_TertiaryPhoneTypeID KEYID = NULL
	  ,@v_TertiaryPhoneNumber VARCHAR(15) = NULL
	  ,@v_TeritaryPhoneNumberExtension VARCHAR(20) = NULL
	  ,@v_AccountStatusCode StatusCode



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
                   Patient
               SET
							NamePrefix 	=	@v_NamePrefix	,
							NameSuffix 	=	@v_NameSuffix	,
							LastName 	=	@v_LastName 	,
							MiddleName 	=	@v_MiddleName 	,
							FirstName 	=	@v_FirstName 	,
							PreferredName 	=	@v_PreferredName 	,
							SSN 	=	@v_SSN	,
							CountryOfBirthID 	=	@i_CountryOfBirthID	,
							MaritalStatusID 	=	@i_MaritalStatusID	,
							BloodTypeID 	=	@i_BloodTypeID	,
							PCPInternalProviderID 	=	@i_PCPInternalProviderID	,
							PreferredCommunicationTypeID 	=	@i_PreferedCommunicationTypeID	,
							NoOfDependents 	=	@i_NoOfDependents	,
							EmploymentStatusID 	=	@i_EmploymentStatusID	,
							ProfessionalTypeID 	=	@i_ProfessionalTypeID	,
							IsDeceased 	=	@b_IsDeceased	,
							DateDeceased 	=	@d_DeceasedDate	,
							MedicalRecordNumber 	=	@v_MedicalRecordNumber	,
							Title 	=	@v_Title 	,
							Gender 	=	@v_Gender 	,
							DateOfBirth 	=	@dt_DateOfBirth 	,
							RaceID 	=	@i_RaceID 	,
							EthnicityID 	=	@i_EthnicityID 	,
							PCPNPI 	=	@v_PCPNPI 	,
							CallTimePreferenceID 	=	@i_CallTimePreferenceId 	,
							PrimaryAddressContactName 	=	@v_PrimaryAddressContactName 	,
							PrimaryAddressContactRelationshipToPatientID 	=	@i_PrimaryAddressContactRelationshipToPatientID 	,
							PrimaryAddressTypeID 	=	@i_PrimaryAddressTypeID 	,
							PrimaryAddressLine1 	=	@v_PrimaryAddressLine1 	,
							PrimaryAddressLine2 	=	@v_PrimaryAddressLine2 	,
							PrimaryAddressLine3 	=	@v_PrimaryAddressLine3	,
							PrimaryAddressCity  	=	@v_PrimaryAddressCity	,
							PrimaryAddressStateCodeID 	=	@i_PrimaryAddressStateCodeID	,
							PrimaryAddressCountyID  	=	@i_PrimaryAddressCountyID	,
							PrimaryAddressCountryCodeID 	=	@i_PrimaryAddressCountryCodeID	,
							PrimaryAddressPostalCode 	=		@v_PrimaryAddressPostalCode,
							PrimaryPhoneContactName 	=	@v_PrimaryPhoneContactName 	,
							PrimaryPhoneContactRelationshipToPatientID 	=	@i_PrimaryPhoneContactRelationshipToPatientID 	,
							PrimaryPhoneTypeID 	=	@i_PrimaryPhoneTypeID 	,
							PrimaryPhoneNumber 	=	@v_PrimaryPhoneNumber 	,
							PrimaryPhoneNumberExtension 	=	@v_PrimaryPhoneNumberExtension 	,
							PrimaryEmailAddressContactName 	=	@v_PrimaryEmailAddressContactName 	,
							PrimaryEmailAddressContactRelationshipToPatientID 	=	@i_PrimaryEmailAddressContactRelationshipToPatientID 	,
							PrimaryEmailAddressTypeID 	=	@i_PrimaryEmailAddressTypeID 	,
							PrimaryEmailAddress 	=	@v_PrimaryEmailAddress 	,
							AcceptsFaxCommunications 	=	@b_AcceptsFaxCommunications 	,
							AcceptsEmailCommunications 	=	@b_AcceptsEmailCommunications	,
							AcceptsSMSCommunications 	=	@b_AcceptsSMSCommunications 	,
							AcceptsMassCommunications 	=	@b_AcceptsMassCommunications 	,
							AcceptsPreventativeCommunications 	=	@b_AcceptsPreventativeCommunications 	,
							SecondaryAddressContactName 	=	@v_SecondaryAddressContactName 	,
							SecondaryAddressContactRelationshipToPatientID 	=	@i_SecondaryAddressContactRelationshipToPatientID 	,
							SecondaryAddressTypeID 	=	@i_SecondaryAddressTypeID 	,
							SecondaryAddressLine1 	=	@v_SecondaryAddressLine1 	,
							SecondaryAddressLine2 	=	@v_SecondaryAddressLine2 	,
							SecondaryAddressLine3 	=	@v_SecondaryAddressLine3	,
							SecondaryAddressCity  	=	@v_SecondaryAddressCity	,
							SecondaryAddressStateCodeID 	=	@i_SecondaryAddressStateCodeID	,
							SecondaryAddressCountyID  	=	@i_SecondaryAddressCountyID	,
							SecondaryAddressCountryCodeID 	=	@i_SecondaryAddressCountryCodeID	,
							SecondaryAddressPostalCode 	=		@v_SecondaryAddressPostalCode,
							SecondaryPhoneContactName 	=	@v_SecondaryPhoneContactName 	,
							SecondaryPhoneContactRelationshipToPatientID 	=	@i_SecondaryPhoneContactRelationshipToPatient 	,
							SecondaryPhoneTypeID 	=	@i_SecondaryPhoneTypeID 	,
							SecondaryPhoneNumber 	=	@v_SecondaryPhoneNumber 	,
							SecondaryPhoneNumberExtension 	=	@v_SecondaryPhoneNumberExtension 	,
							TertiaryPhoneContactName 	=	@v_TertiaryPhoneContactName 	,
							TertiaryPhoneContactRealtionToPatientID 	=	@i_TertiaryPhoneContactRealtionToPatientID 	,
							TertiaryPhoneTypeID  	=	@i_TertiaryPhoneTypeID 	,
							TertiaryPhoneNumber  	=	@v_TertiaryPhoneNumber 	,
							TeritaryPhoneNumberExtension 	=	@v_TeritaryPhoneNumberExtension 	,
							SecondaryEmailAddressContactName  	=	@v_SecondaryEmailAddressContactName 	,
							SecondaryEmailAddressContactRelationshipToPatientID 	=	@i_SecondaryEmailAddressContactRelationshipToPatientID 	,
							SecondaryEmailAddresTypeID 	=	@i_SecondaryEmailAddresTypeID 	,
							SecondaryEmailAddress  	=	@v_SecondaryEmailAddress 	,
							AccountStatusCode		=	@v_AccountStatusCode


				  
				  WHERE 
				      PatientID = @i_PatientID 

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update Immunization Details'  
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
    ON OBJECT::[dbo].[usp_Patient_ProfileUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

