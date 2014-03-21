



CREATE FUNCTION [dbo].[ufn_GetAgeEligiblePopulation2]
(
	@AnchorDate_Year int,
	@AnchorDate_Month int,
	@AnchorDate_Day int,

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

	 @AnchorDate_Year = Year of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Month = Month of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Day = Day in the Month of the Anchor Date for which Eligible Population is to be constructed.

	 @Num_Months_Prior_EligiblePop int = Number of Months Before the Anchor Date from which Age-Eligible Population is to be constructed.

	 @Num_Months_After_EligiblePop int = Number of Months After the Anchor Date from which Age-Eligible Population is to be constructed.

	 @EligibleAge_MIN = Minimum Age at which an Individual can be included in the Age-Eligible Population to be constructed.

	 @EligibleAge_MAX - Maximum Age at which an Individual can be included in the Age-Eligible Population to be constructed.

	 @IsDeceased = Deceased Status of Individuals selected for inclusion in the Age-Eligible Population.
				   Examples = 1 ('Yes, Is DEAD'), 0 ('No, Is ALIVE'), or NULL (unspecified).

	 @PatientStatus = Status of Individual Patients selected for inclusion in the Age-Eligible Population.
					  Examples = 'A' ('Yes, Patient is Active'), 'I' ('No, Accout is Inactive/Disabled'), etc.

	 *********************************************************************************************************************************************/


	SELECT pat.[PatientID], pat.[AccountStatusCode] AS 'PatientStatus', pat.[UserID], u.[UserLoginName],
		   pat.[NamePrefix], pat.[FirstName], pat.[MiddleName], pat.[LastName], pat.[NameSuffix],
		   pat.[Title], pat.[PreferredName], pat.[SSN], pat.[DateOfBirth], DATEDIFF(yyyy, pat.[DateOfBirth],
		   GETDATE()) AS 'PresentAge', csc.[CountryName] AS [CountryOfBirth], (CASE WHEN pat.[IsDeceased] = 1 THEN 'Yes' ELSE 'No' END) AS 'IsDeceased',
		   pat.[DateDeceased], pat.[Gender],csr.[RaceName] AS [Race], cse.[EthnicityName] AS [Ethnicity], pat.[BloodType],
		   csms.MaritalStatusName AS [MaritalStatus], pat.[NoOfDependents], pat.[EmploymentStatus], cspt.ProfessionalType AS [ProfessionalType],
		   pat.[InsuranceGroupID], ig.[GroupName] AS 'InsuranceGroupName', pat.[MemberID],
		   pat.[PolicyNumber], pat.[GroupNumber], pat.[PCPName], pat.[PCPNPI], pat.[PCPInternalProviderID],
		   pat.[MedicalRecordNumber], pat.[DefaultTaskCareProviderID], pat.[PrimaryAddressContactName],
		   csre.RelationCode AS [PrimaryAddressContactRelationshipToPatient], lkat.[AddressTypeCode] AS [PrimaryAddressType], pat.[PrimaryAddressLine1],
		   pat.[PrimaryAddressLine2], pat.[PrimaryAddressLine3], pat.[PrimaryAddressCity],
		  csca.[CountryName] AS [PrimaryAddressCounty], pat.[PrimaryAddressPostalCode],csca.[CountryCode] AS [PrimaryAddressCountryCode],
		   pat.[SecondaryAddressContactName], csrs.RelationCode AS [SecondaryAddressContactRelationshipToPatient],
		   lkt.[AddressTypeCode] AS [SecondaryAddressType], pat.[SecondaryAddressLine1], pat.[SecondaryAddressLine2],
		   pat.[SecondaryAddressLine3], pat.[SecondaryAddressCity], css.[StateCode] AS [SecondaryAddressStateCode],
		   cscs.[CountryName] AS [SecondaryAddressCounty], pat.[SecondaryAddressPostalCode],cscs.[CountryCode] AS [SecondaryAddressCountryCode],
		   pat.[PrimaryPhoneContactName], ppcr.RelationCode AS [PrimaryPhoneContactRelationshipToPatient], lkp.PhoneTypeCode AS [PrimaryPhoneType],
		   pat.[PrimaryPhoneNumber], pat.[PrimaryPhoneNumberExtension], pat.[SecondaryPhoneContactName],
		   ppcs.RelationCode [SecondaryPhoneContactRelationshipToPatient], lkps.PhoneTypeCode AS [SecondaryPhoneType], pat.[SecondaryPhoneNumber],
		   pat.[SecondaryPhoneNumberExtension], pat.[TertiaryPhoneContactName],
		   tpc.RelationCode AS [TertiaryPhoneContactRelationshipToPatient],lkpt.PhoneTypeCode AS [TertiaryPhoneType], pat.[TertiaryPhoneNumber],
		   pat.SecondaryPhoneNumberExtension AS [TertiaryPhoneNumberExtension], pat.[PrimaryEmailAddressContactName],
		   lket.EmailAddressTypeName AS [PrimaryEmailAddressContactRelationshipToPatient],  lket.EmailAddressTypeCode AS [PrimaryEmailAddressType],
		   pat.[PrimaryEmailAddress], pat.[SecondaryEmailAddressContactName],
		   lkes.EmailAddressTypeName AS [SecondaryEmailAddressContactRelationshipToPatient], lkes.EmailAddressTypeCode AS [SecondaryEmailAddresType],
		   pat.[SecondaryEmailAddress], pat.[MedicarePrimeIndicator], pat.[MedicarePrimeBeginDate],
		   pat.[MedicarePrimeEndDate],

		   (CASE WHEN p_hib1.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'IsMedicaidInsured',
		   (CASE WHEN p_hib2.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'IsMedicareInsured',
		   (CASE WHEN p_hib3.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'IsMedicarePrimeIndicator',
		   (CASE WHEN p_hib4.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'IsFrequentNoShow',
		   (CASE WHEN p_hib5.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'IsVisionImpaired',
		   (CASE WHEN p_hib6.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'IsHearingImpaired',
		   (CASE WHEN p_hib7.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'IsTobaccoUser',
		   (CASE WHEN p_hib8.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'IsObesed',
		   (CASE WHEN p_hib9.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasSignificantAlcoholUse',
		   (CASE WHEN p_hib10.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasDrugDependency',
		   (CASE WHEN p_hib11.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasInactiveLifeStyle',
		   (CASE WHEN p_hib12.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasHeartDisease',
		   (CASE WHEN p_hib13.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasLiverDisease',
		   (CASE WHEN p_hib14.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasKidneyDisease',
		   (CASE WHEN p_hib15.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasLungDisease',
		   (CASE WHEN p_hib16.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasCancerHistory',
		   (CASE WHEN p_hib17.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasFinancialBarrier',
		   (CASE WHEN p_hib18.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasMentalHealthBarrier',
		   (CASE WHEN p_hib19.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasEducationLiteracyBarrier',
		   (CASE WHEN p_hib20.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasLanguageCulturalBarrier',
		   (CASE WHEN p_hib21.[StatusCode] = 'A' THEN 'Yes' ELSE 'No' END) AS 'HasTransportationIssuesBarrier',

		   (CASE WHEN pat.[AcceptsFaxCommunications] = 1 THEN 'Yes' ELSE 'No' END) AS 'AcceptsFaxCommunications',
		   (CASE WHEN pat.[AcceptsEmailCommunications] = 1 THEN 'Yes' ELSE 'No' END) AS 'AcceptsEmailCommunications',
		   (CASE WHEN pat.[AcceptsSMSCommunications] = 1 THEN 'Yes' ELSE 'No' END) AS 'AcceptsSMSCommunications',
		   (CASE WHEN pat.[AcceptsMassCommunications] = 1 THEN 'Yes' ELSE 'No' END) AS 'AcceptsMassCommunications',
		   (CASE WHEN pat.[AcceptsPreventativeCommunications] = 1 THEN 'Yes' ELSE 'No' END) AS 'AcceptsPreventativeCommunications',

		   pat.[BarrierComments], pat.[SocialAssessmentText], pat.[FunctionalAssessmentText],
		   pat.[EnvironmentalAssessmentText], pat.[GeneralComments],
		   comm_type.[CommunicationType] AS 'PreferredCommunicationType', ctp.[CallTimeName],
		   pat.[PreferredCallTime], pat.[UnderWriter], u.[AvatarInfo], u.[ThemeColorInfo],
		   u.[UserBySkin], u.[StartDate] AS 'UserAccountActiveDate', u.[EndDate] AS 'UserAccountExpirationDate',
		   u.[LastGoodLoginDateTime] AS 'UserAccountLastSuccessfulLoginDateTime',
		   pat.[CreatedByUserID] AS 'PatientCreateByUserID', pat.[DataSourceID] AS 'PatientDataSourceID',
		   dat_src.[SourceName] AS 'PatientDataSourceName', pat.[DataSourceFileID] AS 'PatientDataSourceFileID',
		   src_file.[DataSourceFileName] AS 'PatientDataSourceFileName',
		   src_file.[FileLocation] AS 'PatientDataSourceFileLocation', pat.[RecordTag_FileID] AS 'PatientRecordTag_FileID',
		   pat.[CreatedByUserId] AS 'PatientCreatedByUserID', pat.[CreatedDate] AS 'PatientCreatedDate',
		   pat.[LastModifiedByUserId] AS 'PatientLastModifiedByUserID', pat.[LastModifiedDate] AS 'PatientLastModifiedDate',
		   u.[CreatedByUserID] AS 'UserAccountCreatedByUserID', u.[CreatedDate] AS 'UserAccountCreatedDate',
		   u.[LastModifiedByUserId] AS 'UserAccountLastModifiedByUserID', u.[LastModifiedDate] AS 'UserAccountLastModifiedDate'

	FROM [dbo].[Patient] pat
	LEFT OUTER JOIN [dbo].[Users] u ON u.[UserID] = pat.[UserID]

	LEFT OUTER JOIN [dbo].[InsuranceGroup] ig ON ig.[InsuranceGroupID] = pat.[InsuranceGroupID]

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib1 ON p_hib1.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib1 ON (hib1.[HealthIndicatorsAndBarriersID] = p_hib1.[HealthIndicatorsAndBarriersID]) AND
																(hib1.[Name] = 'IsMedicaidInsured')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib2 ON p_hib2.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib2 ON (hib2.[HealthIndicatorsAndBarriersID] = p_hib2.[HealthIndicatorsAndBarriersID]) AND
																(hib2.[Name] = 'IsMedicareInsured')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib3 ON p_hib3.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib3 ON (hib3.[HealthIndicatorsAndBarriersID] = p_hib3.[HealthIndicatorsAndBarriersID]) AND
																(hib3.[Name] = 'IsMedicarePrimeIndicator')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib4 ON p_hib4.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib4 ON (hib4.[HealthIndicatorsAndBarriersID] = p_hib4.[HealthIndicatorsAndBarriersID]) AND
																(hib4.[Name] = 'IsFrequentNoShow')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib5 ON p_hib5.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib5 ON (hib5.[HealthIndicatorsAndBarriersID] = p_hib5.[HealthIndicatorsAndBarriersID]) AND
																(hib5.[Name] = 'IsVisionImpaired')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib6 ON p_hib6.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib6 ON (hib6.[HealthIndicatorsAndBarriersID] = p_hib6.[HealthIndicatorsAndBarriersID]) AND
																(hib6.[Name] = 'IsHearingImpaired')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib7 ON p_hib7.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib7 ON (hib7.[HealthIndicatorsAndBarriersID] = p_hib7.[HealthIndicatorsAndBarriersID]) AND
																(hib7.[Name] = 'IsTobaccoUser')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib8 ON p_hib8.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib8 ON (hib8.[HealthIndicatorsAndBarriersID] = p_hib8.[HealthIndicatorsAndBarriersID]) AND
																(hib8.[Name] = 'IsObesed')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib9 ON p_hib9.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib9 ON (hib9.[HealthIndicatorsAndBarriersID] = p_hib9.[HealthIndicatorsAndBarriersID]) AND
																(hib9.[Name] = 'HasSignificantAlcoholUse')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib10 ON p_hib10.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib10 ON (hib10.[HealthIndicatorsAndBarriersID] = p_hib10.[HealthIndicatorsAndBarriersID]) AND
																 (hib10.[Name] = 'HasDrugDependency')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib11 ON p_hib11.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib11 ON (hib11.[HealthIndicatorsAndBarriersID] = p_hib11.[HealthIndicatorsAndBarriersID]) AND
																 (hib11.[Name] = 'HasInactiveLifeStyle')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib12 ON p_hib12.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib12 ON (hib12.[HealthIndicatorsAndBarriersID] = p_hib12.[HealthIndicatorsAndBarriersID]) AND
																 (hib12.[Name] = 'HasHeartDisease')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib13 ON p_hib13.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib13 ON (hib13.[HealthIndicatorsAndBarriersID] = p_hib13.[HealthIndicatorsAndBarriersID]) AND
																 (hib13.[Name] = 'HasLiverDisease')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib14 ON p_hib14.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib14 ON (hib14.[HealthIndicatorsAndBarriersID] = p_hib14.[HealthIndicatorsAndBarriersID]) AND
																 (hib14.[Name] = 'HasKidneyDisease')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib15 ON p_hib15.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib15 ON (hib15.[HealthIndicatorsAndBarriersID] = p_hib15.[HealthIndicatorsAndBarriersID]) AND
																 (hib15.[Name] = 'HasLungDisease')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib16 ON p_hib16.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib16 ON (hib16.[HealthIndicatorsAndBarriersID] = p_hib16.[HealthIndicatorsAndBarriersID]) AND
																 (hib16.[Name] = 'HasCancerHistory')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib17 ON p_hib17.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib17 ON (hib17.[HealthIndicatorsAndBarriersID] = p_hib17.[HealthIndicatorsAndBarriersID]) AND
																 (hib17.[Name] = 'HasFinancialBarrier')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib18 ON p_hib18.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib18 ON (hib18.[HealthIndicatorsAndBarriersID] = p_hib18.[HealthIndicatorsAndBarriersID]) AND
																 (hib18.[Name] = 'HasMentalHealthBarrier')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib19 ON p_hib19.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib19 ON (hib19.[HealthIndicatorsAndBarriersID] = p_hib19.[HealthIndicatorsAndBarriersID]) AND
																 (hib19.[Name] = 'HasEducationLiteracyBarrier')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib20 ON p_hib20.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib20 ON (hib20.[HealthIndicatorsAndBarriersID] = p_hib20.[HealthIndicatorsAndBarriersID]) AND
																 (hib20.[Name] = 'HasLanguageCulturalBarrier')

	LEFT OUTER JOIN [dbo].[PatientHealthindicatorsBarriers] p_hib21 ON p_hib21.[PatientID] = pat.[PatientID]
	LEFT OUTER JOIN [dbo].[HealthIndicatorsAndBarriers] hib21 ON (hib21.[HealthIndicatorsAndBarriersID] = p_hib21.[HealthIndicatorsAndBarriersID]) AND
																 (hib21.[Name] = 'HasTransportationIssuesBarrier')

	LEFT OUTER JOIN [CommunicationType] comm_type ON comm_type.[CommunicationTypeId] = pat.[PreferredCommunicationTypeID]
	LEFT OUTER JOIN [CallTimePreference] ctp ON ctp.[CallTimePreferenceID] = pat.[CallTimePreferenceID]

	LEFT OUTER JOIN [dbo].[CodeSetDataSource] dat_src ON (dat_src.[DataSourceID] = pat.[DataSourceID]) AND
														 (dat_src.[StatusCode] = 'A')
	LEFT OUTER JOIN [dbo].[DataSourceFile] src_file ON (src_file.[DataSourceFileID] = pat.[DataSourceFileID])
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

	WHERE (((@IsDeceased IS NULL) OR (@IsDeceased = 0)) AND ((pat.[IsDeceased] IS NULL) OR
															 (pat.[IsDeceased] = 0) OR
															 (pat.[DateDeceased] > (CONVERT(varchar, @AnchorDate_Year) + '-' +
																					CONVERT(varchar, @AnchorDate_Month) + '-' +
																					CONVERT(varchar, @AnchorDate_Day))))) AND

		  ((@EligibleAge_MIN IS NULL) OR
		   (DateDIFF(YYYY, pat.[DateOfBirth], (CONVERT(varchar, @AnchorDate_Year) + '-' +
											   CONVERT(varchar, @AnchorDate_Month) + '-' +
											   CONVERT(varchar, @AnchorDate_Day))) >= @EligibleAge_MIN) OR
		   (DateDIFF(YYYY, pat.[DateOfBirth], DATEADD(MM, @Num_Months_After, (CONVERT(varchar, @AnchorDate_Year) + '-' +
																			  CONVERT(varchar, @AnchorDate_Month) + '-' +
																			  CONVERT(varchar, @AnchorDate_Day)))) >= @EligibleAge_MIN)) AND

		  ((@EligibleAge_MAX IS NULL) OR
		   (DateDIFF(YYYY, pat.[DateOfBirth], DATEADD(MM, -@Num_Months_Prior, (CONVERT(varchar, @AnchorDate_Year) + '-' +
																			   CONVERT(varchar, @AnchorDate_Month) + '-' +
																			   CONVERT(varchar, @AnchorDate_Day)))) <= @EligibleAge_MAX) OR
		   (DateDIFF(YYYY, pat.[DateOfBirth], (CONVERT(varchar, @AnchorDate_Year) + '-' +
											   CONVERT(varchar, @AnchorDate_Month) + '-' +
											   CONVERT(varchar, @AnchorDate_Day))) <= @EligibleAge_MAX))

);


