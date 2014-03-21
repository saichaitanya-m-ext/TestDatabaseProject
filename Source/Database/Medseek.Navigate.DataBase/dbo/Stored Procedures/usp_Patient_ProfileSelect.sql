/*    
----------------------------------------------------------------------------------    
Procedure Name: [usp_Patient_ProfileSelect] 2,2
Description   : This procedure is used to get PatientID and Records  from Patient    
Created By    : P.V.P.Mohan    
Created Date  : 26-Mar-2013    
----------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
15-Apr-2013   : Changed Column name DateDeceased 
----------------------------------------------------------------------------------    
*/    
CREATE PROCEDURE [dbo].[usp_Patient_ProfileSelect]
(
  @i_AppUserId KEYID ,
  @i_PatientID KEYID
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
            PatientID,
		    Patient.NamePrefix,
			Patient.NameSuffix,
			Patient.LastName ,         
			Patient.MiddleName ,        
			Patient.FirstName ,             
			Patient.PreferredName,
			'**********' AS SSN,
			Patient.DateOfBirth,
			Patient.CountryOfBirthID,
			MaritalStatusID,
			BloodTypeID,
			[dbo].[ufn_GetPCPName](ISNULL(@i_PatientID,PCPName))AS PCPName,
			PreferredCommunicationTypeID,
			NoOfDependents,
			CodeSetEmploymentStatus.EmploymentStatusID,
			CodeSetProfessionalType.ProfessionalTypeID,
			IsDeceased,
			DateDeceased As DeceasedDate,
			MedicalRecordNumber,
			Title,
			Patient.Gender,			
			DATEDIFF( YEAR, Patient.DateOfBirth, GETDATE()) AS Age,
			RaceID,
			EthnicityID,
			PCPNPI,
			CallTimePreferenceID,			
			AcceptsFaxCommunications,
			AcceptsEmailCommunications,
			AcceptsSMSCommunications,
			AcceptsMassCommunications,
			AcceptsPreventativeCommunications,
			Patient.PrimaryAddressContactName,
			Patient.PrimaryAddressContactRelationshipToPatientID,
			Patient.PrimaryAddressTypeID,
			Patient.PrimaryAddressLine1,
			Patient.PrimaryAddressLine2,
			Patient.PrimaryAddressLine3,
			Patient.PrimaryAddressCity,
			Patient.PrimaryAddressStateCodeID,
			Patient.PrimaryAddressCountyID,
			Patient.PrimaryAddressCountryCodeID,
			Patient.PrimaryAddressPostalCode,
			Patient.SecondaryAddressContactName,
			Patient.SecondaryAddressContactRelationshipToPatientID	,
			Patient.SecondaryAddressTypeID,
			Patient.SecondaryAddressLine1,
			Patient.SecondaryAddressLine2,
			Patient.SecondaryAddressLine3,
			Patient.SecondaryAddressCity,
			Patient.SecondaryAddressStateCodeID,
			Patient.SecondaryAddressCountyID,
			Patient.SecondaryAddressCountryCodeID,
			Patient.SecondaryAddressPostalCode,	
		    patient.PrimaryPhoneContactName,
			Patient.PrimaryPhoneContactRelationshipToPatientID,
			Patient.PrimaryPhoneTypeID,
			Patient.PrimaryPhoneNumber,
			Patient.PrimaryPhoneNumberExtension,
			Patient.SecondaryPhoneContactName,
			Patient.SecondaryPhoneContactRelationshipToPatientID,
			Patient.SecondaryPhoneTypeID,
			Patient.SecondaryPhoneNumber,
			Patient.SecondaryPhoneNumberExtension,
			Patient.TertiaryPhoneContactName,
			Patient.TertiaryPhoneContactRealtionToPatientID,
			Patient.TertiaryPhoneTypeID,
			Patient.TertiaryPhoneNumber,
			Patient.TeritaryPhoneNumberExtension,
			Patient.PrimaryEmailAddressContactName,
			Patient.PrimaryEmailAddressContactRelationshipToPatientID,
			Patient.PrimaryEmailAddressTypeID,
			Patient.PrimaryEmailAddress,
			Patient.SecondaryEmailAddressContactName,
			Patient.SecondaryEmailAddressContactRelationshipToPatientID,
			Patient.SecondaryEmailAddresTypeID,
			Patient.SecondaryEmailAddress,
			Patient.PCPInternalProviderID,
			patient.AccountStatusCode
   
	  FROM 
	      Patient
					LEFT OUTER JOIN  LkUpPhoneType
						ON LkUpPhoneType.PhoneTypeID = Patient.PrimaryPhoneTypeID
					LEFT OUTER JOIN  LkUpAddressType
						ON LkUpAddressType.AddressTypeID = Patient.PrimaryAddressTypeID
					LEFT OUTER JOIN  LkUpEmailAddressType
						ON LkUpEmailAddressType.EmailAddressTypeID = Patient.PrimaryEmailAddressTypeID
					LEFT OUTER JOIN  CodeSetCountry
						ON CodeSetCountry.CountryID = Patient.PrimaryAddressCountryCodeID
					LEFT OUTER JOIN  CodeSetCounty
						ON CodeSetCounty.CountyID = Patient.PrimaryAddressCountyID
					LEFT OUTER JOIN  CodeSetRelation
						ON CodeSetRelation.RelationId = Patient.PrimaryAddressContactRelationshipToPatientID
					LEFT OUTER JOIN  CodeSetState
						ON CodeSetState.StateID	 = Patient.PrimaryAddressStateCodeID 
					LEFT OUTER JOIN  CodeSetProfessionalType
						ON CodeSetProfessionalType.ProfessionalTypeID	 = Patient.ProfessionalTypeID 
					LEFT OUTER JOIN  CodeSetEmploymentStatus
						ON CodeSetEmploymentStatus.EmploymentStatusID	 = Patient.EmploymentStatusID 
					LEFT OUTER JOIN Provider
					    ON Provider.ProviderID=Patient.PCPInternalProviderID
	        WHERE
           ( Patient.PatientID = @i_PatientID OR @i_PatientID IS NULL )
          
END TRY    
--------------------------------------------------------     
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID     
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Patient_ProfileSelect] TO [FE_rohit.r-ext]
    AS [dbo];

