CREATE FUNCTION [dbo].[ufn_HEDIS_GetPatients_RxClaims2_SelectedPopulation]
(
	@ECTTableName varchar(30),

	@PopulationDefinitionID int,
	@AnchorYear_NumYearsOffset int,

	@Num_Months_Prior int,
	@Num_Months_After int,

	@ECTCodeVersion_Year int,
	@ECTCodeStatus varchar(1),
	@c_ReportType CHAR(1)='P'
)
RETURNS TABLE
AS

RETURN
(
	/************************************************************ INPUT PARAMETERS ************************************************************

	 @ECTTableName = Name of the ECT Table containing NDC Drug Codes to be used for selection of Patients for inclusion in the Eligible
					 Population of Patients with qualifying Rx/Pharmacy Claims are to be drawn or selected from.

	 @PopulationDefinitionID = Handle to the selected Population of Patients from which the Eligible Population of Patients of the Numerator
							   are to be constructed.

	 @AnchorYear_NumYearsOffset = Number of Years of OFFSET -- After (+) or Before (-) -- from the Anchor Year around which the Patients in the
								  selected Population was chosen, serving as the new Anchor Year around which the Eligible Population of
								  Patients is to be constructed.

	 @Num_Months_Prior = Number of Months Before the Anchor Date from which Eligible Population of Patients with "Diabetes" Pharmacy/Rx Claims
						 is to be constructed.

	 @Num_Months_After = Number of Months After the Anchor Date from which Eligible Population of Patients with "Diabetes" Pharmacy/Rx Claims
						 is to be constructed.

	 @ECTCodeVersion_Year = Code Version Year from which HEDIS-associated NDC Drug Codes that are used to select Patients for inclusion in
							the Eligible Population of Patients, with Rx/Pharmacy claims that are for Diseases and Health Conditions
							associated with the Measure, to be constructed for the Measurement Year/Period.

	 @ECTCodeStatus = Status of HEDIS-associated NDC Drug Codes that are used to select Patients for inclusion in the Eligible Population of
					  Patients, with Rx/Pharmacy claims that are for Diseases and Health Conditions associated with the Measure, to be
					  constructed for the Measurement Year/Period.
					  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 *********************************************************************************************************************************************/


	SELECT 
		rx_clm.[PatientID], 
		rx_clm.[RxClaimNumber],
		'' AS ClaimLineID,
		'' AS 'NDCCode',
		--rx_clm.[ClaimLineID],
		--rx_clm.[NDC] AS 'NDCCode',
		rx.[DrugName],
		-- rx_clm.[BrandName],
		'' AS [BrandName],
		 rx.[DrugDescription], 
		 --rx_clm.
		 '' AS [NDCLabel], 
		 rx.[DrugCodeType],
		   rx_clm.[DateFilled], rx_clm.[DaysSupply], rx_clm.[QuantityDispensed], rx_clm.[IsGeneric],
		   --rx_clm.[Formulary],
		   '' AS [Formulary],
		    pat.[UserID], u.[UserLoginName], pat.[NamePrefix], pat.[FirstName],
		   pat.[MiddleName], pat.[LastName], pat.[NameSuffix], pat.[Title], pat.[PreferredName],
		   pat.[SSN], pat.[DateOfBirth], DATEDIFF(yyyy, pat.[DateOfBirth], GETDATE()) AS 'PresentAge',
		   (CASE WHEN pat.[IsDeceased] = 1 THEN 'Yes' ELSE 'No' END) AS 'IsDeceased', pat.[DateDeceased],
		   --rx_clm.[InsuranceGroupID], 
		   '' AS [InsuranceGroupID],
		   '' AS MemberId,
		   
		   --rx_clm.[MemberID],
		   '' AS PolicyNumber,
		   '' AS GroupNumber,
		   
		   '' AS DependentSequenceNO,
		   '' AS IngredientCost,
		   '' AS PaidAmount,
		   '' AS ApprovedCopay,
		   '' AS TherapyClassSpecific,
		    '' AS [TherapyClassStandard],
		    --rx_clm.[PolicyNumber], 
		   --rx_clm.[GroupNumber],
		   --rx_clm.[DependentSequenceNo], 
		   --rx_clm.[IngredientCost], 
--		   rx_clm.[PaidAmount],
		    --rx_clm.ApprovedCopay,
		   --rx_clm.[TherapyClassSpecific], rx_clm.[TherapyClassStandard], 
		   rx_clm.[PrescriberID] AS 'Prescribing Physician ID',
		   --rx_clm.[PharmacyName], 
		   '' AS [PharmacyName],
		   '' AS 'Pharmacy Provider ID',
		   --rx_clm.[Pharamacy] AS 'Pharmacy Provider ID',
		    pat.[Gender], CSR.RaceName AS [Race], CSE.EthnicityName AS [Ethnicity], pat.[BloodType], CMS.MaritalStatusName [MaritalStatus], pat.[NoOfDependents], pat.[EmploymentStatus],
		   CSPT.ProfessionalType [ProfessionalType], pat.[MedicalRecordNumber], pat.[PCPName], pat.[PCPNPI], pat.[PCPInternalProviderID],
		   pat.[DefaultTaskCareProviderID], rx_clm.[StatusCode], rx_clm.[RxClaimSourceID], rx_src.[RxClaimSource],
		   rx_clm.[DataSourceID], dat_src.[SourceName], rx_clm.[DataSourceFileID], src_file.[DataSourceFileName],
		   src_file.[FileLocation], 
		   '' AS [RecordTag_FileID],
		   --rx_clm.[RecordTag_FileID],
		    rx_clm.[CreatedByUserID] AS 'RxClaimCreateByUserID',
		   rx_clm.[CreatedDate] AS 'RxClaimCreateDate', rx_clm.[LastModifiedByUserId] AS 'RxClaimLastModifiedByUserID',
		   rx_clm.[LastModifiedDate] AS 'RxClaimLastModifiedDate'

	FROM [RxClaim] rx_clm
	INNER JOIN [dbo].[PopulationDefinitionPatients] p ON p.[PatientID] = rx_clm.[PatientID]
	INNER JOIN [dbo].[PopulationDefinitionPatientAnchorDate] pa ON pa.[PopulationDefinitionPatientID] = p.[PopulationDefinitionPatientID]
	INNER JOIN [Patient] pat ON pat.[PatientID] = p.[PatientID]

	LEFT OUTER JOIN [Users] u ON u.[UserID] = pat.[UserID]

	LEFT OUTER JOIN [CodeSetDrug] rx ON (rx.[DrugCodeId] = rx_clm.[DrugCodeId]) AND
										(rx_clm.[DateFilled] BETWEEN rx.[BeginDate] AND rx.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetRxClaimSource] rx_src ON rx_src.[RxClaimSourceID] = rx_clm.[RxClaimSourceID]

	LEFT OUTER JOIN [dbo].[CodeSetDataSource] dat_src ON (dat_src.[DataSourceID] = rx_clm.[DataSourceID]) AND
														 (dat_src.[StatusCode] = 'A')

	LEFT OUTER JOIN [dbo].[DataSourceFile] src_file ON (src_file.[DataSourceFileID] = rx_clm.[DataSourceFileID])
	
	LEFT OUTER JOIN CodeSetRace CSR ON CSR.RaceId = pat.RaceId

	LEFT OUTER JOIN CodeSetEthnicity CSE ON CSE.EthnicityId = pat.EthnicityId
	
	LEFT OUTER JOIN CodeSetMaritalStatus CMS ON CMS.MaritalStatusID = pat.MaritalStatusID
	
	LEFT OUTER JOIN CodeSetProfessionalType CSPT ON CSPT.ProfessionalTypeID = pat.ProfessionalTypeID

	WHERE (rx_clm.[DateFilled] BETWEEN (DATEADD(YYYY, -@Num_Months_Prior, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate]))) AND
									   (DATEADD(YYYY, @Num_Months_After, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate])))) AND

		  (rx.[DrugCode] IN (SELECT [DrugCode]
							 FROM dbo.ufn_HEDIS_GetDrugInfo_ByTableName(@ECTTableName, @ECTCodeVersion_Year, @ECTCodeStatus)))

);
