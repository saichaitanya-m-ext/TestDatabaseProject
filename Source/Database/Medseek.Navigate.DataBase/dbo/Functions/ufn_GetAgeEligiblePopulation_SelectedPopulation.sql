


CREATE FUNCTION [dbo].[ufn_GetAgeEligiblePopulation_SelectedPopulation]
(
	@PopulationDefinitionID int,
	@AnchorYear_NumYearsOffset int,

	@Num_Months_Prior int,
	@Num_Months_After int,

	@EligibleAge_MIN int,
	@EligibleAge_MAX int,

	@IsDeceased bit,
	@PatientStatus varchar(1)
)
RETURNS TABLE
AS

RETURN
(
	/************************************************************ INPUT PARAMETERS ************************************************************

	 @PopulationDefinitionID = Handle to the selected Population of Patients from which the Eligible Population of Patients of the Numerator
							   are to be constructed.

	 @AnchorYear_NumYearsOffset = Number of Years of OFFSET -- After (+) or Before (-) -- from the Anchor Year around which the Patients in the
								  selected Population was chosen, serving as the new Anchor Year around which the Eligible Population of
								  Patients is to be constructed.

	 @Num_Months_Prior_EligiblePop int = Number of Months Before the Anchor Date from which Age-Eligible Population is to be constructed.

	 @Num_Months_After_EligiblePop int = Number of Months After the Anchor Date from which Age-Eligible Population is to be constructed.

	 @EligibleAge_MIN = Minimum Age at which an Individual can be included in the Age-Eligible Population to be constructed.

	 @EligibleAge_MAX - Maximum Age at which an Individual can be included in the Age-Eligible Population to be constructed.

	 @IsDeceased = Deceased Status of Individuals selected for inclusion in the Age-Eligible Population.
				   Examples = 1 ('Yes, Is DEAD'), 0 ('No, Is ALIVE'), or NULL (unspecified).

	 @PatientStatus = Status of Individual Patients selected for inclusion in the Age-Eligible Population.
					  Examples = 'A' ('Yes, Patient is Active'), 'I' ('No, Accout is Inactive/Disabled'), etc.

	 *********************************************************************************************************************************************/


	SELECT p.[PatientID], pat.[AccountStatusCode] AS 'PatientStatus', pat.[UserID], u.[UserLoginName],
		   pat.[NamePrefix], pat.[FirstName], pat.[MiddleName], pat.[LastName], pat.[NameSuffix],
		   pat.[Title], pat.[PreferredName], pat.[SSN], pat.[DateOfBirth], DATEDIFF(yyyy, pat.[DateOfBirth],
		   GETDATE()) AS 'PresentAge', csc.[CountryName] AS [CountryOfBirth],
		   (CASE WHEN pat.[IsDeceased] = 1 THEN 'Yes' ELSE 'No' END) AS 'IsDeceased', pat.[DateDeceased],
		   pat.[Gender], csr.[RaceName] AS [Race], cse.[EthnicityName] AS [Ethnicity], pat.[BloodType], csms.MaritalStatusName AS [MaritalStatus],
		   pat.[NoOfDependents], pat.[EmploymentStatus], cspt.ProfessionalType AS [ProfessionalType], pat.[InsuranceGroupID],
		   pat.[MemberID], pat.[PolicyNumber], pat.[GroupNumber], pat.[PCPName], pat.[PCPNPI],
		   pat.[PCPInternalProviderID], pat.[MedicalRecordNumber], pat.[DefaultTaskCareProviderID],
		   pat.[PrimaryAddressContactName], csre.RelationCode AS [PrimaryAddressContactRelationshipToPatient],
		   lkat.[AddressTypeCode] AS [PrimaryAddressType], pat.[PrimaryAddressLine1], pat.[PrimaryAddressLine2],
		   pat.[PrimaryAddressLine3], pat.[PrimaryAddressCity], csca.[CountryName] AS [PrimaryAddressCounty],
		   pat.[PrimaryAddressPostalCode], csca.[CountryCode] AS [PrimaryAddressCountryCode], pat.[SecondaryAddressContactName],
		   csrs.RelationCode AS [SecondaryAddressContactRelationshipToPatient], lkt.[AddressTypeCode] AS [SecondaryAddressType],
		   pat.[SecondaryAddressLine1], pat.[SecondaryAddressLine2], pat.[SecondaryAddressLine3],
		   pat.[SecondaryAddressCity], css.[StateCode] AS [SecondaryAddressStateCode], cscs.[CountryName] AS [SecondaryAddressCounty],
		   pat.[SecondaryAddressPostalCode], cscs.[CountryCode] AS [SecondaryAddressCountryCode], pat.[PrimaryPhoneContactName],
		   ppcr.RelationCode AS [PrimaryPhoneContactRelationshipToPatient], lkp.PhoneTypeCode AS [PrimaryPhoneType], pat.[PrimaryPhoneNumber],
		   pat.[PrimaryPhoneNumberExtension], pat.[SecondaryPhoneContactName],
		   ppcs.RelationCode [SecondaryPhoneContactRelationshipToPatient], lkps.PhoneTypeCode AS [SecondaryPhoneType], pat.[SecondaryPhoneNumber],
		   pat.[SecondaryPhoneNumberExtension], pat.[TertiaryPhoneContactName],
		   tpc.RelationCode AS [TertiaryPhoneContactRelationshipToPatient], lkpt.PhoneTypeCode AS [TertiaryPhoneType], pat.[TertiaryPhoneNumber],
		   pat.SecondaryPhoneNumberExtension AS [TertiaryPhoneNumberExtension], pat.[PrimaryEmailAddressContactName],
		   lket.EmailAddressTypeName AS [PrimaryEmailAddressContactRelationshipToPatient], lket.EmailAddressTypeCode AS [PrimaryEmailAddressType],
		   pat.[PrimaryEmailAddress], pat.[SecondaryEmailAddressContactName],
		   lkes.EmailAddressTypeName AS [SecondaryEmailAddressContactRelationshipToPatient], lkes.EmailAddressTypeCode AS [SecondaryEmailAddresType],
		   pat.[SecondaryEmailAddress], pat.[MedicarePrimeIndicator], pat.[MedicarePrimeBeginDate],
		   pat.[MedicarePrimeEndDate], u.[StartDate] AS 'UserAccountActiveDate', u.[EndDate] AS 'UserAccountExpirationDate',
		   u.[LastGoodLoginDateTime] AS 'UserAccountLastSuccessfulLoginDateTime', pat.[CreatedByUserID] AS 'PatientCreateByUserID',
		   pat.[DataSourceID] AS 'PatientDataSourceID', pat.[DataSourceFileID] AS 'PatientDataSourceFileID',
		   pat.[RecordTag_FileID] AS 'PatientRecordTag_FileID', pat.[CreatedByUserId] AS 'PatientCreatedByUserID',
		   pat.[CreatedDate] AS 'PatientCreatedDate', pat.[LastModifiedByUserId] AS 'PatientLastModifiedByUserID',
		   pat.[LastModifiedDate] AS 'PatientLastModifiedDate', u.[CreatedByUserID] AS 'UserAccountCreatedByUserID',
		   u.[CreatedDate] AS 'UserAccountCreatedDate', u.[LastModifiedByUserId] AS 'UserAccountLastModifiedByUserID',
		   u.[LastModifiedDate] AS 'UserAccountLastModifiedDate' 

	FROM [dbo].[PopulationDefinitionPatients] p
	INNER JOIN [dbo].[PopulationDefinitionPatientAnchorDate] pa ON pa.PopulationDefinitionPatientID = p.PopulationDefinitionPatientID
	LEFT OUTER JOIN [dbo].[Patient] pat ON pat.[PatientID] = p.[PatientID]
	LEFT OUTER JOIN CodeSetCountry csc ON csc.[CountryID] = pat.[CountryOfBirthID]
	LEFT OUTER JOIN CodeSetRace csr ON csr.[RaceID] = pat.[RaceID]
	LEFT OUTER JOIN CodeSetEthnicity cse ON cse.[EthnicityID] = pat.[EthnicityID]	
	LEFT OUTER JOIN CodeSetMaritalStatus csms ON csms.[MaritalStatusID] = pat.[MaritalStatusID]	
	LEFT OUTER JOIN CodeSetProfessionalType cspt ON cspt.[ProfessionalTypeID] = pat.[ProfessionalTypeID]	
	LEFT OUTER JOIN CodeSetRelation csre ON csre.[RelationId] = pat.[PrimaryAddressContactRelationshipToPatientID]	
	LEFT OUTER JOIN LkUpAddressType lkat ON lkat.[AddressTypeID] = pat.[PrimaryAddressTypeID]	
	LEFT OUTER JOIN CodeSetCountry csca ON csca.[CountryID] = pat.[PrimaryAddressCountyID]
	LEFT OUTER JOIN CodeSetRelation csrs ON csrs.[RelationId] = pat.[SecondaryAddressContactRelationshipToPatientID]	
	LEFT OUTER JOIN LkUpAddressType lkt ON lkt.[AddressTypeID] = pat.[SecondaryAddressTypeID]	
	LEFT OUTER JOIN CodeSetState css ON css.[StateID] = pat.[SecondaryAddressStateCodeID]	
	LEFT OUTER JOIN CodeSetCountry cscs ON cscs.[CountryID] = pat.[SecondaryAddressCountyID]
	LEFT OUTER JOIN CodeSetRelation ppcr ON ppcr.[RelationId] = pat.[PrimaryPhoneContactRelationshipToPatientID]	
	LEFT OUTER JOIN LkUpPhoneType lkp ON lkp.[PhoneTypeID] = pat.[PrimaryPhoneTypeID]	
	LEFT OUTER JOIN CodeSetRelation ppcs ON ppcs.[RelationId] = pat.[SecondaryPhoneContactRelationshipToPatientID]		
	LEFT OUTER JOIN LkUpPhoneType lkps ON lkps.[PhoneTypeID] = pat.[SecondaryPhoneTypeID]	
	LEFT OUTER JOIN CodeSetRelation tpc ON tpc.[RelationId] = pat.[TertiaryPhoneContactRealtionToPatientID]	
	LEFT OUTER JOIN LkUpPhoneType lkpt ON lkpt.[PhoneTypeID] = pat.[TertiaryPhoneTypeID]	
	LEFT OUTER JOIN LkUpEmailAddressType lket ON lket.[EmailAddressTypeID] = pat.[PrimaryEmailAddressContactRelationshipToPatientID]	
	LEFT OUTER JOIN LkUpEmailAddressType lkes ON lkes.[EmailAddressTypeID] = pat.[SecondaryEmailAddressContactRelationshipToPatientID]	
	
	
	-- csac

	LEFT OUTER JOIN [dbo].[Users] u ON u.[UserID] = pat.[UserID]

	WHERE (((@IsDeceased IS NULL) OR (@IsDeceased = 0)) AND ((pat.[IsDeceased] IS NULL) OR
															 (pat.[IsDeceased] = 0) OR
															 (pat.[DateDeceased] > DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate])))) AND

		  ((@EligibleAge_MIN IS NULL) OR
		   (DateDIFF(YYYY, pat.[DateOfBirth], DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate])) >= @EligibleAge_MIN) OR
		   (DateDIFF(YYYY, pat.[DateOfBirth], DATEADD(MM, @Num_Months_After, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate]))) >= @EligibleAge_MIN)) AND

		  ((@EligibleAge_MAX IS NULL) OR
		   (DateDIFF(YYYY, pat.[DateOfBirth], DATEADD(MM, -@Num_Months_Prior, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate]))) <= @EligibleAge_MAX) OR
		   (DateDIFF(YYYY, pat.[DateOfBirth], DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate])) <= @EligibleAge_MAX))

);



