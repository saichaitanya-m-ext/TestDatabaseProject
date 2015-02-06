CREATE FUNCTION [dbo].[ufn_HEDIS_GetPatients_EncouterClaims2_SelectedPopulation]
(
	@ECTTableName varchar(30),

	@PopulationDefinitionID int,
	@AnchorYear_NumYearsOffset int,

	@Num_Months_Prior int,
	@Num_Months_After int,

	@ECTCodeVersion_Year int,
	@ECTCodeStatus varchar(1)
   ,@c_ReportType CHAR(1) = 'P' --P For Population ,S- stratagic 
)
RETURNS TABLE
AS

RETURN
(
	/************************************************************ INPUT PARAMETERS ************************************************************

	 @ECTTableName = Name of the ECT Table containing Medical Codes (i.e. CPT, CPT-II, HCPCS, and ICD Procedure) to be used for
					 determining Eligible Population of Patients with qualifying Medical Claims.

	 @PopulationDefinitionID = Handle to the selected Population of Patients from which the Eligible Population of Patients of the Numerator
							   are to be constructed.

	 @AnchorYear_NumYearsOffset = Number of Years of OFFSET -- After (+) or Before (-) -- from the Anchor Year around which the Patients in the
								  selected Population was chosen, serving as the new Anchor Year around which the Eligible Population of
								  Patients is to be constructed.

	 @Num_Months_Prior = Number of Months Prior to the Anchor Date from which Eligible Population of Patients with Encounters/Event
						 Diagnoses is to be constructed.

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


	SELECT ci.[PatientID], ci.[ClaimInfoId], ci.[ClaimNumber], ci.[EDIClaimTypeID], cod_edi.[EDIClaimTypeCode],
		   cod_edi.[EDIClaimTypeName], ci.[TypeOfBillCodeID], cod_tob.[TypeOfBillCode], ci.[AdmissionTypeCodeID],
		   cod_adm_typ.[AdmissionTypeCode], cod_adm_typ.[AdmissionType], NULL AS [EmployerGroupID], NULL AS [InsuranceGroupID],
		   NULL AS [MemberID], NULL AS [PolicyNumber], NULL AS [MedicalRecordNumber], NULL AS [PatientControlNumber],
		   NULL AS [DocumentControlNumber], ci.[ClaimStatusCodeID], cod_clm_stat.[ClaimStatusCode],
		   ci.[PatientStatusCodeID], cod_pat_stat.[PatientStatusCode], cod_pat_stat.[PatientStatus],
		   ci.[AdmissionSourceCodeID], cod_adm_src.[AdmissionSourceCode], cod_adm_src.[AdmissionSource],
		   ci.[ClaimSourceCodeID], cod_clm_src.[ClaimSourceCode], ci.[MDCCodeID], cod_mdc.[MDCCode],
		   ci.[MSDRGCodeID], cod_msdrg.[MSDRGCode], ci.[DRGCodeID], cod_drg.[DRGCode], ci.[APRDRGCodeID],
		   cod_aprdrg.[APRDRGCode], ci.[APCCodeID], cod_apc.[APCCode], ci.[StatementDateFrom],
		   ci.[StatementDateTo], ci.[DateOfAdmit], ci.[DateOfDischarge], NULL AS [EnteredDate], NULL AS [ReceivedDate],
		   ci.[PaidDate], NULL AS [IncurredDate], NULL AS [ClaimProcessedDate], ci.[LengthOfStay], ci.[PaidDays],
		   cp.[ClaimProcedureID], cp.[ProcedureCodeID] AS 'ICDProcedureCodeID', cod_iproc.[ProcedureCode] AS 'ICDProcedureCode',
		   ct3.[CodeTypeCode] AS 'ICDProcedureCodeType', cp.[RankOrder] AS 'ICDProcedureCodeRankOrder',
		   ci.[DataSourceID] AS 'ClaimDataSourceID', dat_src2.[SourceName] AS 'ClaimDataSourceName', 
		   ci.[DataSourceFileID] AS 'ClaimDataSourceFileID', src_file2.[DataSourceFileName] AS 'ClaimDataSourceFileName',
		   src_file2.[FileLocation] AS 'ClaimDataSourceFileLocation', NULL AS'ClaimRecordTag_FileID',
		   ci.[CreatedByUserID] AS 'ClaimCreatedByUserID', ci.[CreatedDate] AS 'ClaimCreatedDate',
		   ci.[LastModifiedByUserID] AS 'ClaimLastModifiedByUserID', ci.[LastModifiedDate] AS 'ClaimLastModifiedDate',
		   cl.[ClaimLineID], cl.[ProcedureCodeID], cod_proc.[ProcedureCode], cod_proc.[ProcedureName],
		   ct.[CodeTypeCode] AS 'ProcedureCodeType', cld.[ClaimLineDiagnosisID], cld.[DiagnosisCodeID] AS 'ICDDiagnosisCodeID',
		   cod_idiag.[DiagnosisCode] AS 'ICDDiagnosisCode', ct2.[CodeTypeCode] AS 'ICDDiagnosisCodeType',
		   cld.[PurposeCodeID] AS 'ICDDiagnosisPurposeCodeID', cod_purp.[PurposeCode] AS 'ICDDiagnosisPurposeCode',
		   cld.[RankOrder] AS 'ICDDiagnosisCodeRankOrder', cl.[RevenueCodeID], cod_rev.[RevenueCode],
		   cl.[PlaceOfServiceCodeID], cod_pos.[PlaceOfServiceCode], cod_pos.[PlaceOfServiceName],
		   cl.[ServiceTypeCodeID], cod_srv_typ.[ServiceTypeCode], cod_srv_typ.[ServiceTypeName],
		   cl.[BeginServiceDate], cl.[EndServiceDate], cl.[DataSourceID] AS 'ClaimLineDataSourceID',
		   dat_src1.[SourceName] AS 'ClaimLineDataSourceName', cl.[DataSourceFileID] AS 'ClaimLineDataSourceFileID',
		   src_file1.[DataSourceFileName] AS 'ClaimLineDataSourceFileName',
		   src_file1.[FileLocation] AS 'ClaimLineDataSourceFileLocation', cl.[RecordTag_FileID] AS 'ClaimLineRecordTag_FileID',
		   cl.[CreatedByUserID] AS 'ClaimLineCreatedByUserID', cl.[CreatedDate] AS 'ClaimLineCreatedDate',
		   cl.[LastModifiedByUserId] AS 'ClaimLineLastModifiedByUserID', cl.[LastModifiedDate] AS 'ClaimLineLastModifiedDate'

	FROM [dbo].[ClaimLine] cl
	INNER JOIN [dbo].[ClaimInfo] ci ON ci.[ClaimInfoID] = cl.[ClaimInfoID]
	INNER JOIN [dbo].[PopulationDefinitionPatients] p ON p.[PatientID] = ci.[PatientID]
    INNER JOIN [dbo].[PopulationDefinitionPatientAnchorDate] pa ON pa.PopulationDefinitionPatientID = p.PopulationDefinitionPatientID
	LEFT OUTER JOIN [dbo].[CodeSetProcedure] cod_proc ON (cod_proc.[ProcedureCodeID] = cl.[ProcedureCodeID]) AND
														 (cl.[BeginServiceDate] BETWEEN cod_proc.[BeginDate] AND cod_proc.[EndDate])

	LEFT OUTER JOIN [dbo].[LkUpCodeType] ct ON ct.[CodeTypeID] = cod_proc.[CodeTypeID]

	LEFT OUTER JOIN [dbo].[ClaimLineDiagnosis] cld ON cld.[ClaimLineID] = cl.[ClaimLineID]

	LEFT OUTER JOIN [dbo].[LkUpPurposeCode] cod_purp ON cod_purp.[PurposeCodeID] = cld.[PurposeCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetICDDiagnosis] cod_idiag ON (cod_idiag.[DiagnosisCodeID] = cld.[DiagnosisCodeID]) AND
															 (cl.[BeginServiceDate] BETWEEN cod_idiag.[BeginDate] AND cod_idiag.[EndDate])

	LEFT OUTER JOIN [dbo].[LkUpCodeType] ct2 ON ct2.[CodeTypeID] = cod_idiag.[CodeTypeID]

	LEFT OUTER JOIN [dbo].[CodeSetRevenue] cod_rev ON (cod_rev.[RevenueCodeID] = cl.[RevenueCodeID]) AND
													  (cl.[BeginServiceDate] BETWEEN cod_rev.[BeginDate] AND cod_rev.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetCMSPlaceOfService] cod_pos ON cod_pos.[PlaceOfServiceCodeID] = cl.[PlaceOfServiceCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetServiceType] cod_srv_typ ON cod_srv_typ.[ServiceTypeCodeID] = cl.[ServiceTypeCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetDataSource] dat_src1 ON (dat_src1.[DataSourceID] = cl.[DataSourceID]) AND
														  (dat_src1.[StatusCode] = 'A')

	LEFT OUTER JOIN [dbo].[DataSourceFile] src_file1 ON (src_file1.[DataSourceFileID] = cl.[DataSourceFileID])


	LEFT OUTER JOIN [dbo].[LkUpEDIClaimType] cod_edi ON cod_edi.[EDIClaimTypeID] = ci.[EDIClaimTypeID]

	LEFT OUTER JOIN [dbo].[CodeSetTypeOfBill] cod_tob ON cod_tob.[TypeOfBillCodeID] = ci.[TypeOfBillCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetAdmissionType] cod_adm_typ ON cod_adm_typ.[AdmissionTypeCodeID] = ci.[AdmissionTypeCodeID]

	LEFT OUTER JOIN [dbo].[ClaimProcedure] cp ON cp.[ClaimInfoID] = ci.[ClaimInfoID]

	LEFT OUTER JOIN [dbo].[CodeSetICDProcedure] cod_iproc ON (cod_iproc.[ProcedureCodeID] = cp.[ProcedureCodeID]) AND
															 (ci.[DateOfAdmit] BETWEEN cod_iproc.[BeginDate] AND cod_iproc.[EndDate])

	LEFT OUTER JOIN [dbo].[LkUpCodeType] ct3 ON ct3.[CodeTypeID] = cod_iproc.[CodeTypeID]

	LEFT OUTER JOIN [dbo].[CodeSetClaimStatus] cod_clm_stat ON cod_clm_stat.[ClaimStatusCodeID] = ci.[ClaimStatusCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetPatientStatus] cod_pat_stat ON cod_pat_stat.[PatientStatusCodeID] = ci.[PatientStatusCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetAdmissionSource] cod_adm_src ON cod_adm_src.[AdmissionSourceCodeID] = ci.[AdmissionSourceCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetClaimSource] cod_clm_src ON cod_clm_src.[ClaimSourceCodeID] = ci.[ClaimSourceCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetMDC] cod_mdc ON (cod_mdc.[MDCCodeID] = ci.[MDCCodeID]) AND
												  (ci.[DateOfAdmit] BETWEEN cod_mdc.[BeginDate] AND cod_mdc.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetMSDRG] cod_msdrg ON (cod_msdrg.[MSDRGCodeID] = ci.[MSDRGCodeID]) AND
												  (ci.[DateOfAdmit] BETWEEN cod_msdrg.[BeginDate] AND cod_msdrg.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetDRG] cod_drg ON (cod_drg.[DRGCodeID] = ci.[DRGCodeID]) AND
												  (ci.[DateOfAdmit] BETWEEN cod_drg.[BeginDate] AND cod_drg.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetAPRDRG] cod_aprdrg ON (cod_aprdrg.[APRDRGCodeID] = ci.[APRDRGCodeID]) AND
														(ci.[DateOfAdmit] BETWEEN cod_aprdrg.[BeginDate] AND cod_aprdrg.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetAPC] cod_apc ON (cod_apc.[APCCodeID] = ci.[APCCodeID]) AND
												  (ci.[DateOfAdmit] BETWEEN cod_apc.[BeginDate] AND cod_apc.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetDataSource] dat_src2 ON (dat_src2.[DataSourceID] = ci.[DataSourceID]) AND
														  (dat_src2.[StatusCode] = 'A')

	LEFT OUTER JOIN [dbo].[DataSourceFile] src_file2 ON (src_file2.[DataSourceFileID] = ci.[DataSourceFileID])

	WHERE (cl.[BeginServiceDate] BETWEEN (DATEADD(MM, -@Num_Months_Prior, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate]))) AND
										 (DATEADD(MM, @Num_Months_After, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate])))) AND

		  ((cod_proc.[ProcedureCode] IN (SELECT [ECTCode]
										 FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName(@ECTTableName, @ECTCodeVersion_Year, @ECTCodeStatus)
										 WHERE [ECTHedisCodeTypeCode] IN ('CPT', 'CPT-CAT-II', 'HCPCS'))) OR

		   (cod_idiag.[DiagnosisCode] IN (SELECT [ECTCode]
										  FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName(@ECTTableName, @ECTCodeVersion_Year, @ECTCodeStatus)
										  WHERE [ECTHedisCodeTypeCode] IN ('ICD9-Diag', 'ICD10-Diag'))) OR

		   (cod_rev.[RevenueCode] IN (SELECT [ECTCode]
									  FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName(@ECTTableName, @ECTCodeVersion_Year, @ECTCodeStatus)
									  WHERE [ECTHedisCodeTypeCode] = 'RevCode')))

	UNION

	SELECT ci.[PatientID], ci.[ClaimInfoId], ci.[ClaimNumber], ci.[EDIClaimTypeID], cod_edi.[EDIClaimTypeCode],
		   cod_edi.[EDIClaimTypeName], ci.[TypeOfBillCodeID], cod_tob.[TypeOfBillCode], ci.[AdmissionTypeCodeID],
		   cod_adm_typ.[AdmissionTypeCode], cod_adm_typ.[AdmissionType], NULL AS [EmployerGroupID], NULL AS [InsuranceGroupID],
		   NULL AS [MemberID], NULL AS [PolicyNumber], NULL AS [MedicalRecordNumber], NULL AS [PatientControlNumber],
		   NULL AS [DocumentControlNumber], ci.[ClaimStatusCodeID], cod_clm_stat.[ClaimStatusCode],
		   ci.[PatientStatusCodeID], cod_pat_stat.[PatientStatusCode], cod_pat_stat.[PatientStatus],
		   ci.[AdmissionSourceCodeID], cod_adm_src.[AdmissionSourceCode], cod_adm_src.[AdmissionSource],
		   ci.[ClaimSourceCodeID], cod_clm_src.[ClaimSourceCode], ci.[MDCCodeID], cod_mdc.[MDCCode],
		   ci.[MSDRGCodeID], cod_msdrg.[MSDRGCode], ci.[DRGCodeID], cod_drg.[DRGCode], ci.[APRDRGCodeID],
		   cod_aprdrg.[APRDRGCode], ci.[APCCodeID], cod_apc.[APCCode], ci.[StatementDateFrom],
		   ci.[StatementDateTo], ci.[DateOfAdmit], ci.[DateOfDischarge], NULL AS [EnteredDate], NULL AS [ReceivedDate],
		   ci.[PaidDate], NULL AS [IncurredDate], NULL AS [ClaimProcessedDate], ci.[LengthOfStay], ci.[PaidDays],
		   cp.[ClaimProcedureID], cp.[ProcedureCodeID] AS 'ICDProcedureCodeID', cod_iproc.[ProcedureCode] AS 'ICDProcedureCode',
		   ct1.[CodeTypeCode] AS 'ICDProcedureCodeType', cp.[RankOrder] AS 'ICDProcedureCodeRankOrder',
		   ci.[DataSourceID] AS 'ClaimDataSourceID', dat_src1.[SourceName] AS 'ClaimDataSourceName', 
		   ci.[DataSourceFileID] AS 'ClaimDataSourceFileID', src_file1.[DataSourceFileName] AS 'ClaimDataSourceFileName',
		   src_file1.[FileLocation] AS 'ClaimDataSourceFileLocation', NULL AS'ClaimRecordTag_FileID',
		   ci.[CreatedByUserID] AS 'ClaimCreatedByUserID', ci.[CreatedDate] AS 'ClaimCreatedDate',
		   ci.[LastModifiedByUserID] AS 'ClaimLastModifiedByUserID', ci.[LastModifiedDate] AS 'ClaimLastModifiedDate',
		   cl.[ClaimLineID], cl.[ProcedureCodeID], cod_proc.[ProcedureCode], cod_proc.[ProcedureName],
		   ct2.[CodeTypeCode] AS 'ProcedureCodeType', cld.[ClaimLineDiagnosisID], cld.[DiagnosisCodeID] AS 'ICDDiagnosisCodeID',
		   cod_idiag.[DiagnosisCode] AS 'ICDDiagnosisCode', ct3.[CodeTypeCode] AS 'ICDDiagnosisCodeType',
		   cld.[PurposeCodeID] AS 'ICDDiagnosisPurposeCodeID', cod_purp.[PurposeCode] AS 'ICDDiagnosisPurposeCode',
		   cld.[RankOrder] AS 'ICDDiagnosisCodeRankOrder', cl.[RevenueCodeID], cod_rev.[RevenueCode],
		   cl.[PlaceOfServiceCodeID], cod_pos.[PlaceOfServiceCode], cod_pos.[PlaceOfServiceName],
		   cl.[ServiceTypeCodeID], cod_srv_typ.[ServiceTypeCode], cod_srv_typ.[ServiceTypeName],
		   cl.[BeginServiceDate], cl.[EndServiceDate], cl.[DataSourceID] AS 'ClaimLineDataSourceID',
		   dat_src2.[SourceName] AS 'ClaimLineDataSourceName', cl.[DataSourceFileID] AS 'ClaimLineDataSourceFileID',
		   src_file2.[DataSourceFileName] AS 'ClaimLineDataSourceFileName',
		   src_file2.[FileLocation] AS 'ClaimLineDataSourceFileLocation', cl.[RecordTag_FileID] AS 'ClaimLineRecordTag_FileID',
		   cl.[CreatedByUserID] AS 'ClaimLineCreatedByUserID', cl.[CreatedDate] AS 'ClaimLineCreatedDate',
		   cl.[LastModifiedByUserId] AS 'ClaimLineLastModifiedByUserID', cl.[LastModifiedDate] AS 'ClaimLineLastModifiedDate'

	FROM [dbo].[ClaimInfo] ci
	INNER JOIN [dbo].[PopulationDefinitionPatients] p ON p.[PatientID] = ci.[PatientID]
	INNER JOIN [Dbo].[PopulationDefinitionPatientAnchorDate] pa ON p.PopulationDefinitionPatientID = pa.PopulationDefinitionPatientID
	LEFT OUTER JOIN [dbo].[ClaimLine] cl ON cl.[ClaimInfoID] = ci.[ClaimInfoID]

	LEFT OUTER JOIN [dbo].[LkUpEDIClaimType] cod_edi ON cod_edi.[EDIClaimTypeID] = ci.[EDIClaimTypeID]

	LEFT OUTER JOIN [dbo].[CodeSetTypeOfBill] cod_tob ON cod_tob.[TypeOfBillCodeID] = ci.[TypeOfBillCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetAdmissionType] cod_adm_typ ON cod_adm_typ.[AdmissionTypeCodeID] = ci.[AdmissionTypeCodeID]

	LEFT OUTER JOIN [dbo].[ClaimProcedure] cp ON cp.[ClaimInfoID] = ci.[ClaimInfoID]

	LEFT OUTER JOIN [dbo].[CodeSetICDProcedure] cod_iproc ON (cod_iproc.[ProcedureCodeID] = cp.[ProcedureCodeID]) AND
															 (ci.[DateOfAdmit] BETWEEN cod_iproc.[BeginDate] AND cod_iproc.[EndDate])

	LEFT OUTER JOIN [dbo].[LkUpCodeType] ct1 ON ct1.[CodeTypeID] = cod_iproc.[CodeTypeID]

	LEFT OUTER JOIN [dbo].[CodeSetClaimStatus] cod_clm_stat ON cod_clm_stat.[ClaimStatusCodeID] = ci.[ClaimStatusCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetPatientStatus] cod_pat_stat ON cod_pat_stat.[PatientStatusCodeID] = ci.[PatientStatusCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetAdmissionSource] cod_adm_src ON cod_adm_src.[AdmissionSourceCodeID] = ci.[AdmissionSourceCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetClaimSource] cod_clm_src ON cod_clm_src.[ClaimSourceCodeID] = ci.[ClaimSourceCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetMDC] cod_mdc ON (cod_mdc.[MDCCodeID] = ci.[MDCCodeID]) AND
												  (ci.[DateOfAdmit] BETWEEN cod_mdc.[BeginDate] AND cod_mdc.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetMSDRG] cod_msdrg ON (cod_msdrg.[MSDRGCodeID] = ci.[MSDRGCodeID]) AND
												  (ci.[DateOfAdmit] BETWEEN cod_msdrg.[BeginDate] AND cod_msdrg.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetDRG] cod_drg ON (cod_drg.[DRGCodeID] = ci.[DRGCodeID]) AND
												  (ci.[DateOfAdmit] BETWEEN cod_drg.[BeginDate] AND cod_drg.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetAPRDRG] cod_aprdrg ON (cod_aprdrg.[APRDRGCodeID] = ci.[APRDRGCodeID]) AND
														(ci.[DateOfAdmit] BETWEEN cod_aprdrg.[BeginDate] AND cod_aprdrg.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetAPC] cod_apc ON (cod_apc.[APCCodeID] = ci.[APCCodeID]) AND
												  (ci.[DateOfAdmit] BETWEEN cod_apc.[BeginDate] AND cod_apc.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetDataSource] dat_src1 ON (dat_src1.[DataSourceID] = ci.[DataSourceID]) AND
														  (dat_src1.[StatusCode] = 'A')

	LEFT OUTER JOIN [dbo].[DataSourceFile] src_file1 ON (src_file1.[DataSourceFileID] = ci.[DataSourceFileID])


	LEFT OUTER JOIN [dbo].[CodeSetProcedure] cod_proc ON (cod_proc.[ProcedureCodeID] = cl.[ProcedureCodeID]) AND
														 (cl.[BeginServiceDate] BETWEEN cod_proc.[BeginDate] AND cod_proc.[EndDate])

	LEFT OUTER JOIN [dbo].[LkUpCodeType] ct2 ON ct2.[CodeTypeID] = cod_proc.[CodeTypeID]

	LEFT OUTER JOIN [dbo].[ClaimLineDiagnosis] cld ON cld.[ClaimLineID] = cl.[ClaimLineID]

	LEFT OUTER JOIN [dbo].[LkUpPurposeCode] cod_purp ON cod_purp.[PurposeCodeID] = cld.[PurposeCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetICDDiagnosis] cod_idiag ON (cod_idiag.[DiagnosisCodeID] = cld.[DiagnosisCodeID]) AND
															 (cl.[BeginServiceDate] BETWEEN cod_idiag.[BeginDate] AND cod_idiag.[EndDate])

	LEFT OUTER JOIN [dbo].[LkUpCodeType] ct3 ON ct3.[CodeTypeID] = cod_idiag.[CodeTypeID]

	LEFT OUTER JOIN [dbo].[CodeSetRevenue] cod_rev ON (cod_rev.[RevenueCodeID] = cl.[RevenueCodeID]) AND
													  (cl.[BeginServiceDate] BETWEEN cod_rev.[BeginDate] AND cod_rev.[EndDate])

	LEFT OUTER JOIN [dbo].[CodeSetCMSPlaceOfService] cod_pos ON cod_pos.[PlaceOfServiceCodeID] = cl.[PlaceOfServiceCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetServiceType] cod_srv_typ ON cod_srv_typ.[ServiceTypeCodeID] = cl.[ServiceTypeCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetDataSource] dat_src2 ON (dat_src2.[DataSourceID] = cl.[DataSourceID]) AND
														  (dat_src2.[StatusCode] = 'A')

	LEFT OUTER JOIN [dbo].[DataSourceFile] src_file2 ON (src_file2.[DataSourceFileID] = cl.[DataSourceFileID])

	WHERE (ci.[DateOfAdmit] BETWEEN (DATEADD(MM, -@Num_Months_Prior, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate]))) AND
									(DATEADD(MM, @Num_Months_After, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate])))) AND

		  (cod_iproc.[ProcedureCode] IN (SELECT [ECTCode]
										 FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName(@ECTTableName, @ECTCodeVersion_Year, @ECTCodeStatus)
										 WHERE [ECTHedisCodeTypeCode] IN ('ICD9-Proc', 'ICD10-Proc')))

);
