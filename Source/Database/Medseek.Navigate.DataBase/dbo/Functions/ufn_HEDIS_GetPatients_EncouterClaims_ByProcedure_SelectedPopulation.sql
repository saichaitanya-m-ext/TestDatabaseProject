﻿CREATE FUNCTION [dbo].[ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure_SelectedPopulation] 
(
	@ECTTableName VARCHAR(30)
	,@PopulationDefinitionID INT
	,@AnchorYear_NumYearsOffset INT
	,@Num_Months_Prior INT
	,@Num_Months_After INT
	,@ECTCodeVersion_Year INT
	,@ECTCodeStatus VARCHAR(1)
	,@AnchorDate_Year INT = 2012
	,@AnchorDate_Month VARCHAR(2) = 12
	,@AnchorDate_Day VARCHAR(2) = 31
	,@c_ReportType CHAR(1)='P' --P For Population ,S- stratagic 
	)
	

RETURNS @OUTPUT TABLE
(
PatientID INT,
ProcedureCode VARCHAR(10) NULL,
BeginServiceDate DATE

)
BEGIN



		/************************************************************ INPUT PARAMETERS ************************************************************  
  
  @PopulationDefinitionID = Handle to the selected Population of Patients from which the Eligible Population of Patients of the Numerator  
          are to be constructed.  
  
  @AnchorYear_NumYearsOffset = Number of Years of OFFSET -- After (+) or Before (-) -- from the Anchor Year around which the Patients in the  
          selected Population was chosen, serving as the new Anchor Year around which the Eligible Population of  
          Patients is to be constructed.  
  
  @ECTTableName = Name of the ECT Table containing Medical Codes (i.e. CPT, CPT-II, HCPCS, and ICD Procedure) to be used for  
      determining Eligible Population of Patients with qualifying Medical Claims.  
  
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
		DECLARE @DateKey VARCHAR(10)
		
		--SELECT @DateKey = MAX(DateKey) FROM PopulationDefinition p
		--INNER JOIN PopulationDefinitionPatients ps
		--on p.PopulationDefinitionID = ps.PopulationDefinitionID
		--INNER JOIN PopulationDefinitionPatientAnchorDate pd
		--ON pd.PopulationDefinitionPatientID = ps.PopulationDefinitionPatientID
		-- WHERE p.PopulationDefinitionID = @PopulationDefinitionID
		
		
		--SET @OutPutAnchorDate =  CONVERT(DATE, SUBSTRING(@DateKey, 1, 4) + '-' + SUBSTRING(@DateKey, 5, 2) + '-' + SUBSTRING(@DateKey, 7, 2))
		SET @DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10),@AnchorDate_Month) + CONVERT(VARCHAR(10),@AnchorDate_Day)
	
	
		
		INSERT INTO @OUTPUT
		SELECT ci.[PatientID]
			--,ci.[ClaimInfoId]
			--,ci.[ClaimNumber]
			--,ci.[EDIClaimTypeID]
			--,cod_edi.[EDIClaimTypeCode]
			--,cod_edi.[EDIClaimTypeName]
			--,ci.[TypeOfBillCodeID]
			--,cod_tob.[TypeOfBillCode]
			--,ci.[AdmissionTypeCodeID]
			--,cod_adm_typ.[AdmissionTypeCode]
			--,cod_adm_typ.[AdmissionType]
			--,NULL AS [EmployerGroupID]
			--,NULL AS [InsuranceGroupID]
			--,NULL AS [MemberID]
			--,NULL AS [PolicyNumber]
			--,NULL AS [MedicalRecordNumber]
			--,NULL AS [PatientControlNumber]
			--,NULL AS [DocumentControlNumber]
			--,ci.[ClaimStatusCodeID]
			--,cod_clm_stat.[ClaimStatusCode]
			--,ci.[PatientStatusCodeID]
			--,cod_pat_stat.[PatientStatusCode]
			--,cod_pat_stat.[PatientStatus]
			--,ci.[AdmissionSourceCodeID]
			--,ci.[ClaimSourceCodeID]
			--,ci.[MDCCodeID]
			--,ci.[MSDRGCodeID]
			--,ci.[DRGCodeID]
			--,ci.[APRDRGCodeID]
			--,ci.[APCCodeID]
			--,ci.[StatementDateFrom]
			--,ci.[StatementDateTo]
			--,ci.[DateOfAdmit]
			--,ci.[DateOfDischarge]
			--,NULL AS [EnteredDate]
			--,NULL AS [ReceivedDate]
			--,ci.[PaidDate]
			--,NULL AS [IncurredDate]
			--,NULL AS [ClaimProcessedDate]
			--,ci.[LengthOfStay]
			--,ci.[PaidDays]
			--,cp.[ClaimProcedureID]
			--,cp.[ProcedureCodeID] AS 'ICDProcedureCodeID'
			--,cod_iproc.[ProcedureCode] AS 'ICDProcedureCode'
			--,ct3.[CodeTypeCode] AS 'ICDProcedureCodeType'
			--,cp.[RankOrder] AS 'ICDProcedureCodeRankOrder'
			--,ci.[DataSourceID] AS 'ClaimDataSourceID'
			--,ci.[DataSourceFileID] AS 'ClaimDataSourceFileID'
			--,NULL AS'ClaimRecordTag_FileID'
			--,ci.[CreatedByUserID] AS 'ClaimCreatedByUserID'
			--,ci.[CreatedDate] AS 'ClaimCreatedDate'
			--,ci.[LastModifiedByUserID] AS 'ClaimLastModifiedByUserID'
			--,ci.[LastModifiedDate] AS 'ClaimLastModifiedDate'
			--,cl.[ClaimLineID]
			--,cl.[ProcedureCodeID]
			,cod_proc.[ProcedureCode]
			--,cod_proc.[ProcedureName]
			--,ct.[CodeTypeCode] AS 'ProcedureCodeType'
			--,cld.[ClaimLineDiagnosisID]
			--,cld.[DiagnosisCodeID] AS 'ICDDiagnosisCodeID'
			--,cod_idiag.[DiagnosisCode] AS 'ICDDiagnosisCode'
			--,ct2.[CodeTypeCode] AS 'ICDDiagnosisCodeType'
			--,cld.[PurposeCodeID] AS 'ICDDiagnosisPurposeCodeID'
			--,cod_purp.[PurposeCode] AS 'ICDDiagnosisPurposeCode'
			--,cld.[RankOrder] AS 'ICDDiagnosisCodeRankOrder'
			--,cl.[RevenueCodeID]
			--,cod_rev.[RevenueCode]
			--,cl.[PlaceOfServiceCodeID]
			--,cod_pos.[PlaceOfServiceCode]
			--,cod_pos.[PlaceOfServiceName]
			--,cl.[ServiceTypeCodeID]
			,cl.[BeginServiceDate]
			--,cl.[EndServiceDate]
			--,cl.[DataSourceID] AS 'ClaimLineDataSourceID'
			--,cl.[DataSourceFileID] AS 'ClaimLineDataSourceFileID'
			--,cl.[RecordTag_FileID] AS 'ClaimLineRecordTag_FileID'
			--,cl.[CreatedByUserID] AS 'ClaimLineCreatedByUserID'
			--,cl.[CreatedDate] AS 'ClaimLineCreatedDate'
			--,cl.[LastModifiedByUserId] AS 'ClaimLineLastModifiedByUserID'
			--,cl.[LastModifiedDate] AS 'ClaimLineLastModifiedDate'
		FROM [dbo].[ClaimLine] cl WITH(NOLOCK)
		INNER JOIN [dbo].[ClaimInfo] ci WITH(NOLOCK)
			ON ci.[ClaimInfoID] = cl.[ClaimInfoID]
		INNER JOIN [dbo].PopulationDefinitionPatients pdp WITH(NOLOCK)
			ON pdp.[PatientID] = ci.[PatientID]
		INNER JOIN PopulationDefinitionPatientAnchorDate pdpad
		   ON pdpad.PopulationDefinitionPatientID = pdp.PopulationDefinitionPatientID	
		--INNER JOIN ClaimProvider cp1
		--    ON cp1.ClaimInfoID = ci.ClaimInfoID
		--INNER JOIN ProviderSpecialty ps
		--    ON ps.ProviderID = cp1.ProviderID
		--INNER JOIN CodeSetCMSProviderSpecialty cmssp
		--    ON cmssp.CMSProviderSpecialtyCodeID = ps.CMSProviderSpecialtyCodeID        	
		LEFT OUTER JOIN [dbo].[CodeSetProcedure] cod_proc WITH(NOLOCK)
			ON (cod_proc.[ProcedureCodeID] = cl.[ProcedureCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_proc.[BeginDate]
						AND cod_proc.[EndDate]
					)
		LEFT OUTER JOIN [dbo].[LkUpCodeType] ct WITH(NOLOCK)
			ON ct.[CodeTypeID] = cod_proc.[CodeTypeID]
		LEFT OUTER JOIN [dbo].[ClaimLineDiagnosis] cld WITH(NOLOCK)
			ON cld.[ClaimLineID] = cl.[ClaimLineID]
		LEFT OUTER JOIN [dbo].[LkUpPurposeCode] cod_purp WITH(NOLOCK)
			ON cod_purp.[PurposeCodeID] = cld.[PurposeCodeID]
		LEFT OUTER JOIN [dbo].[CodeSetICDDiagnosis] cod_idiag WITH(NOLOCK)
			ON (cod_idiag.[DiagnosisCodeID] = cld.[DiagnosisCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_idiag.[BeginDate]
						AND cod_idiag.[EndDate]
					)
		LEFT OUTER JOIN [dbo].[LkUpCodeType] ct2 WITH(NOLOCK)
			ON ct2.[CodeTypeID] = cod_idiag.[CodeTypeID]
		LEFT OUTER JOIN [dbo].[CodeSetRevenue] cod_rev WITH(NOLOCK)
			ON (cod_rev.[RevenueCodeID] = cl.[RevenueCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_rev.[BeginDate]
						AND cod_rev.[EndDate]
					)
		LEFT OUTER JOIN [dbo].[CodeSetCMSPlaceOfService] cod_pos WITH(NOLOCK)
			ON cod_pos.[PlaceOfServiceCodeID] = cl.[PlaceOfServiceCodeID]
		LEFT OUTER JOIN [dbo].[LkUpEDIClaimType] cod_edi WITH(NOLOCK)
			ON cod_edi.[EDIClaimTypeID] = ci.[EDIClaimTypeID]
		LEFT OUTER JOIN [dbo].[CodeSetTypeOfBill] cod_tob WITH(NOLOCK)
			ON cod_tob.[TypeOfBillCodeID] = ci.[TypeOfBillCodeID]
		LEFT OUTER JOIN [dbo].[CodeSetAdmissionType] cod_adm_typ WITH(NOLOCK)
			ON cod_adm_typ.[AdmissionTypeCodeID] = ci.[AdmissionTypeCodeID]
		LEFT OUTER JOIN [dbo].[ClaimProcedure] cp WITH(NOLOCK)
			ON cp.[ClaimInfoID] = ci.[ClaimInfoID]
		LEFT OUTER JOIN [dbo].[CodeSetICDProcedure] cod_iproc WITH(NOLOCK)
			ON (cod_iproc.[ProcedureCodeID] = cp.[ProcedureCodeID])
				AND (
					ci.[DateOfAdmit] BETWEEN cod_iproc.[BeginDate]
						AND cod_iproc.[EndDate]
					)
		LEFT OUTER JOIN [dbo].[LkUpCodeType] ct3 WITH(NOLOCK)
			ON ct3.[CodeTypeID] = cod_iproc.[CodeTypeID]
		LEFT OUTER JOIN [dbo].[CodeSetClaimStatus] cod_clm_stat WITH(NOLOCK)
			ON cod_clm_stat.[ClaimStatusCodeID] = ci.[ClaimStatusCodeID]
		LEFT OUTER JOIN [dbo].[CodeSetPatientStatus] cod_pat_stat WITH(NOLOCK)
			ON cod_pat_stat.[PatientStatusCodeID] = ci.[PatientStatusCodeID]
		WHERE (
				cl.[BeginServiceDate] BETWEEN (DATEADD(MM, - @Num_Months_Prior, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pdpad.OutPutAnchorDate )))
					AND (DATEADD(MM, @Num_Months_After, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pdpad.OutPutAnchorDate)))
				)
			AND (
				cod_proc.[ProcedureCode] IN (
					SELECT [ECTCode]
					FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName(@ECTTableName, @ECTCodeVersion_Year, @ECTCodeStatus)
					WHERE [ECTHedisCodeTypeCode] IN (
							'CPT'
							,'CPT-CAT-II'
							,'HCPCS'
							)
					)
				)
			AND pdp.PopulationDefinitionID = @PopulationDefinitionID
			AND pdpad.DateKey = @DateKey
			--AND cmssp.ProviderSpecialtyCode IN ('18','41')
			
			
		
		UNION
		
		SELECT ci.[PatientID]
			--,ci.[ClaimInfoId]
			--,ci.[ClaimNumber]
			--,ci.[EDIClaimTypeID]
			--,cod_edi.[EDIClaimTypeCode]
			--,cod_edi.[EDIClaimTypeName]
			--,ci.[TypeOfBillCodeID]
			--,cod_tob.[TypeOfBillCode]
			--,ci.[AdmissionTypeCodeID]
			--,cod_adm_typ.[AdmissionTypeCode]
			--,cod_adm_typ.[AdmissionType]
			--,NULL AS [EmployerGroupID]
			--,NULL AS [InsuranceGroupID]
			--,NULL AS [MemberID]
			--,NULL AS [PolicyNumber]
			--,NULL AS [MedicalRecordNumber]
			--,NULL AS [PatientControlNumber]
			--,NULL AS [DocumentControlNumber]
			--,ci.[ClaimStatusCodeID]
			--,cod_clm_stat.[ClaimStatusCode]
			--,ci.[PatientStatusCodeID]
			--,cod_pat_stat.[PatientStatusCode]
			--,cod_pat_stat.[PatientStatus]
			--,ci.[AdmissionSourceCodeID]
			--,ci.[ClaimSourceCodeID]
			--,ci.[MDCCodeID]
			--,ci.[MSDRGCodeID]
			--,ci.[DRGCodeID]
			--,ci.[APRDRGCodeID]
			--,ci.[APCCodeID]
			--,ci.[StatementDateFrom]
			--,ci.[StatementDateTo]
			--,ci.[DateOfAdmit]
			--,ci.[DateOfDischarge]
			--,NULL AS [EnteredDate]
			--,NULL AS [ReceivedDate]
			--,ci.[PaidDate]
			--,NULL AS [IncurredDate]
			--,NULL AS [ClaimProcessedDate]
			--,ci.[LengthOfStay]
			--,ci.[PaidDays]
			--,cp.[ClaimProcedureID]
			--,cp.[ProcedureCodeID] AS 'ICDProcedureCodeID'
			--,cod_iproc.[ProcedureCode] AS 'ICDProcedureCode'
			--,ct.[CodeTypeCode] AS 'ICDProcedureCodeType'
			--,cp.[RankOrder] AS 'ICDProcedureCodeRankOrder'
			--,ci.[DataSourceID] AS 'ClaimDataSourceID'
			--,ci.[DataSourceFileID] AS 'ClaimDataSourceFileID'
			--,NULL AS'ClaimRecordTag_FileID'
			--,ci.[CreatedByUserID] AS 'ClaimCreatedByUserID'
			--,ci.[CreatedDate] AS 'ClaimCreatedDate'
			--,ci.[LastModifiedByUserID] AS 'ClaimLastModifiedByUserID'
			--,ci.[LastModifiedDate] AS 'ClaimLastModifiedDate'
			--,cl.[ClaimLineID]
			--,cl.[ProcedureCodeID]
			,cod_proc.[ProcedureCode]
			--,cod_proc.[ProcedureName]
			--,ct2.[CodeTypeCode] AS 'ProcedureCodeType'
			--,cld.[ClaimLineDiagnosisID]
			--,cld.[DiagnosisCodeID] AS 'ICDDiagnosisCodeID'
			--,cod_idiag.[DiagnosisCode] AS 'ICDDiagnosisCode'
			--,ct3.[CodeTypeCode] AS 'ICDDiagnosisCodeType'
			--,cld.[PurposeCodeID] AS 'ICDDiagnosisPurposeCodeID'
			--,cod_purp.[PurposeCode] AS 'ICDDiagnosisPurposeCode'
			--,cld.[RankOrder] AS 'ICDDiagnosisCodeRankOrder'
			--,cl.[RevenueCodeID]
			--,cod_rev.[RevenueCode]
			--,cl.[PlaceOfServiceCodeID]
			--,cod_pos.[PlaceOfServiceCode]
			--,cod_pos.[PlaceOfServiceName]
			--,cl.[ServiceTypeCodeID]
			,cl.[BeginServiceDate]
			--,cl.[EndServiceDate]
			--,cl.[DataSourceID] AS 'ClaimLineDataSourceID'
			--,cl.[DataSourceFileID] AS 'ClaimLineDataSourceFileID'
			--,cl.[RecordTag_FileID] AS 'ClaimLineRecordTag_FileID'
			--,cl.[CreatedByUserID] AS 'ClaimLineCreatedByUserID'
			--,cl.[CreatedDate] AS 'ClaimLineCreatedDate'
			--,cl.[LastModifiedByUserId] AS 'ClaimLineLastModifiedByUserID'
			--,cl.[LastModifiedDate] AS 'ClaimLineLastModifiedDate'
		FROM [dbo].[ClaimInfo] ci WITH(NOLOCK)
		INNER JOIN [dbo].PopulationDefinitionPatients pdp WITH(NOLOCK)
			ON pdp.[PatientID] = ci.[PatientID]
		INNER JOIN PopulationDefinitionPatientAnchorDate pdpad
		   ON pdpad.PopulationDefinitionPatientID = pdp.PopulationDefinitionPatientID
			
		--INNER JOIN ClaimProvider cp1
		--    ON cp1.ClaimInfoID = ci.ClaimInfoID
		--INNER JOIN ProviderSpecialty ps
		--    ON ps.ProviderID = cp1.ProviderID
		--INNER JOIN CodeSetCMSProviderSpecialty cmssp
		--    ON cmssp.CMSProviderSpecialtyCodeID = ps.CMSProviderSpecialtyCodeID	
		LEFT OUTER JOIN [dbo].[ClaimLine] cl WITH(NOLOCK)
			ON cl.[ClaimInfoID] = ci.[ClaimInfoID]
		LEFT OUTER JOIN [dbo].[LkUpEDIClaimType] cod_edi WITH(NOLOCK)
			ON cod_edi.[EDIClaimTypeID] = ci.[EDIClaimTypeID]
		LEFT OUTER JOIN [dbo].[CodeSetTypeOfBill] cod_tob WITH(NOLOCK)
			ON cod_tob.[TypeOfBillCodeID] = ci.[TypeOfBillCodeID]
		LEFT OUTER JOIN [dbo].[CodeSetAdmissionType] cod_adm_typ WITH(NOLOCK)
			ON cod_adm_typ.[AdmissionTypeCodeID] = ci.[AdmissionTypeCodeID]
		LEFT OUTER JOIN [dbo].[ClaimProcedure] cp WITH(NOLOCK)
			ON cp.[ClaimInfoID] = ci.[ClaimInfoID]
		LEFT OUTER JOIN [dbo].[CodeSetICDProcedure] cod_iproc WITH(NOLOCK)
			ON (cod_iproc.[ProcedureCodeID] = cp.[ProcedureCodeID])
				AND (
					ci.[DateOfAdmit] BETWEEN cod_iproc.[BeginDate]
						AND cod_iproc.[EndDate]
					)
		LEFT OUTER JOIN [dbo].[LkUpCodeType] ct
			ON ct.[CodeTypeID] = cod_iproc.[CodeTypeID]
		LEFT OUTER JOIN [dbo].[CodeSetClaimStatus] cod_clm_stat
			ON cod_clm_stat.[ClaimStatusCodeID] = ci.[ClaimStatusCodeID]
		LEFT OUTER JOIN [dbo].[CodeSetPatientStatus] cod_pat_stat
			ON cod_pat_stat.[PatientStatusCodeID] = ci.[PatientStatusCodeID]
		LEFT OUTER JOIN [dbo].[CodeSetProcedure] cod_proc
			ON (cod_proc.[ProcedureCodeID] = cl.[ProcedureCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_proc.[BeginDate]
						AND cod_proc.[EndDate]
					)
		LEFT OUTER JOIN [dbo].[LkUpCodeType] ct2
			ON ct2.[CodeTypeID] = cod_proc.[CodeTypeID]
		LEFT OUTER JOIN [dbo].[ClaimLineDiagnosis] cld
			ON cld.[ClaimLineID] = cl.[ClaimLineID]
		LEFT OUTER JOIN [dbo].[LkUpPurposeCode] cod_purp
			ON cod_purp.[PurposeCodeID] = cld.[PurposeCodeID]
		LEFT OUTER JOIN [dbo].[CodeSetICDDiagnosis] cod_idiag
			ON (cod_idiag.[DiagnosisCodeID] = cld.[DiagnosisCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_idiag.[BeginDate]
						AND cod_idiag.[EndDate]
					)
		LEFT OUTER JOIN [dbo].[LkUpCodeType] ct3
			ON ct3.[CodeTypeID] = cod_idiag.[CodeTypeID]
		LEFT OUTER JOIN [dbo].[CodeSetRevenue] cod_rev
			ON (cod_rev.[RevenueCodeID] = cl.[RevenueCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_rev.[BeginDate]
						AND cod_rev.[EndDate]
					)
		LEFT OUTER JOIN [dbo].[CodeSetCMSPlaceOfService] cod_pos
			ON cod_pos.[PlaceOfServiceCodeID] = cl.[PlaceOfServiceCodeID]
		WHERE (
				ci.[DateOfAdmit] BETWEEN (DATEADD(MM, - @Num_Months_Prior, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pdpad.OutPutAnchorDate)))
					AND (DATEADD(MM, @Num_Months_After, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pdpad.OutPutAnchorDate)))
				)
			AND pdp.PopulationDefinitionID = @PopulationDefinitionID
			AND (
				cod_iproc.[ProcedureCode] IN (
					SELECT [ECTCode]
					FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName(@ECTTableName, @ECTCodeVersion_Year, @ECTCodeStatus)
					WHERE [ECTHedisCodeTypeCode] IN (
							'ICD9-Proc'
							,'ICD10-Proc'
							)
					)
				)
				AND pdpad.DateKey = @DateKey
				--AND cmssp.ProviderSpecialtyCode IN ('18','41')

  		
		RETURN

END
