CREATE FUNCTION [dbo].[ufn_HEDIS_GetPatients_LabData2_SelectedPopulation]
(
	@ECTTableName varchar(30),

	@PopulationDefinitionID int,
	@AnchorYear_NumYearsOffset int,

	@Num_Months_Prior int,
	@Num_Months_After int,

	@ECTCodeVersion_Year int,
	@ECTCodeStatus varchar(1)
)
RETURNS TABLE
AS

RETURN
(
	/************************************************************ INPUT PARAMETERS ************************************************************

	 @ECTTableName = Name of the ECT Table containing LOINC Codes to be used for selection of Patients for inclusion in the Eligible
					 Population of Patients with qualifying Lab Data are to be drawn or selected from.

	 @PopulationDefinitionID = Handle to the selected Population of Patients from which the Eligible Population of Patients of the Numerator
							   are to be constructed.

	 @AnchorYear_NumYearsOffset = Number of Years of OFFSET -- After (+) or Before (-) -- from the Anchor Year around which the Patients in the
								  selected Population was chosen, serving as the new Anchor Year around which the Eligible Population of
								  Patients is to be constructed.

	 @Num_Months_Prior = Number of Months Before the Anchor Date from which Eligible Population of Patients with Encounters/Event Diagnoses
						 is to be constructed.

	 @Num_Months_After = Number of Months After the Anchor Date from which Eligible Population of Patients with Encounters/Diagnoses
						 is to be constructed.

	 @ECTCodeVersion_Year = Code Version Year from which HEDIS-associated ECT Codes (e.g. ICD-9-CM, ICD-10-CM, etc.) that are to be used to
							select Patients for inclusion in the Eligible Population of Patients, with health claims for Encounters/Event
							Diagnoses that are for Diseases and Health Conditions associated with the Measure, to be constructed for the
							Measurement Period.

	 @ECTCodeStatus = Status of HEDIS-associated ECT Codes (e.g. ICD-9-CM, ICD-10-CM, etc.) that are to be used to select Patients for inclusion
					  in the Eligible Population of Patients, with health claims for Encounters/Event Diagnoses that are for Diseases and Health
					  Conditions associated with the Measure, to be constructed for the Measurement Period.
					  Examples = 'A' (for 'Active') or 'I' (for 'Inactive').

	 *********************************************************************************************************************************************/


	SELECT pm.[PatientID], pm.[MeasureID], m.[Name] AS 'MeasureName', muom.[UOMText], pm.[MeasureValueText],
		   pm.[MeasureValueNumeric], pm.[DateTaken], pm.[IsPatientAdministered], pm.[LOINCCodeID],
		   cod_loinc.[LOINCCode], cod_loinc.[ShortDescription], pm.[ProcedureCodeID], cod_proc.[ProcedureCode],
		   cod_proc.[ProcedureName], cod_proc.[ProcedureShortDescription], pat.[UserID], u.[UserLoginName], pat.[NamePrefix],
		   pat.[FirstName], pat.[MiddleName], pat.[LastName], pat.[NameSuffix], pat.[Title], pat.[PreferredName], pat.[SSN],
		   pat.[DateOfBirth], DATEDIFF(yyyy, pat.[DateOfBirth], GETDATE()) AS 'PresentAge',
		   (CASE WHEN pat.[IsDeceased] = 1 THEN 'Yes' ELSE 'No' END) AS 'IsDeceased', pat.[DateDeceased],
		   pat.[Gender], CSR.RaceName AS [Race], CSE.EthnicityName AS [Ethnicity], pat.[BloodType], CMS.MaritalStatusName [MaritalStatus], pat.[NoOfDependents],
		   pat.[EmploymentStatus], CSPT.ProfessionalType [ProfessionalType], pat.[MedicalRecordNumber], pat.[PCPName], pat.[PCPNPI],
		   pat.[PCPInternalProviderID], pat.[DefaultTaskCareProviderID], pm.[StatusCode], pm.[DataSourceID],
		   dat_src.[SourceName], pm.[DataSourceFileID], src_file.[DataSourceFileName], src_file.[FileLocation],
		   pm.[RecordTag_FileID], pm.[CreatedByUserID] AS 'LabDataCreateByUserID', pm.[CreatedDate] AS 'LabDataCreateDate',
		   pm.[LastModifiedByUserId] AS 'LabDataLastModifiedByUserID', pm.[LastModifiedDate] AS 'LabDataLastModifiedDate'

	FROM [dbo].[PatientMeasure] pm
	INNER JOIN [dbo].[PopulationDefinitionPatients] p ON p.[PatientID] = pm.[PatientID]
	INNER JOIN [dbo].[PopulationDefinitionPatientAnchorDate] pa ON pa.[PopulationDefinitionPatientID] = p.[PopulationDefinitionPatientID]
	INNER JOIN [Patient] pat ON pat.[PatientID] = p.[PatientID]

	LEFT OUTER JOIN [Users] u ON u.[UserID] = pat.[UserID]

	LEFT OUTER JOIN [dbo].[Measure] m ON m.[MeasureId] = pm.[MeasureId]

	LEFT OUTER JOIN [dbo].[MeasureUOM] muom ON muom.[MeasureUOMId] = pm.[MeasureUOMId]

	LEFT OUTER JOIN [dbo].[CodeSetLOINC] cod_loinc ON cod_loinc.[LOINCCodeID] = pm.[LOINCCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetProcedure] cod_proc ON cod_proc.[ProcedureCodeID] = pm.[ProcedureCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetDataSource] dat_src ON (dat_src.[DataSourceID] = pm.[DataSourceID]) AND
														 (dat_src.[StatusCode] = 'A')

	LEFT OUTER JOIN [dbo].[DataSourceFile] src_file ON (src_file.[DataSourceFileID] = pm.[DataSourceFileID])
	
	LEFT OUTER JOIN CodeSetRace CSR ON CSR.RaceId = pat.RaceId

	LEFT OUTER JOIN CodeSetEthnicity CSE ON CSE.EthnicityId = pat.EthnicityId
	
	LEFT OUTER JOIN CodeSetMaritalStatus CMS ON CMS.MaritalStatusID = pat.MaritalStatusID
	
	LEFT OUTER JOIN CodeSetProfessionalType CSPT ON CSPT.ProfessionalTypeID = pat.ProfessionalTypeID

	WHERE (pm.[DateTaken] BETWEEN (DATEADD(YYYY, -@Num_Months_Prior, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate]))) AND
								  (DATEADD(YYYY, @Num_Months_After, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate])))) AND

		  (cod_loinc.[LOINCCode] IN (SELECT [ECTCode]
									 FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName(@ECTTableName, @ECTCodeVersion_Year, @ECTCodeStatus)
									 WHERE [ECTHedisCodeTypeCode] = 'LOINC'))

);
