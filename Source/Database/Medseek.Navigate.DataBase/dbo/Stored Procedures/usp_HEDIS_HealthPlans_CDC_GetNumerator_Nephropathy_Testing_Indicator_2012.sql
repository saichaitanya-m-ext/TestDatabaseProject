CREATE  PROCEDURE [dbo].[usp_HEDIS_HealthPlans_CDC_GetNumerator_Nephropathy_Testing_Indicator_2012] (
	@PopulationDefinitionID INT
	,@MetricID INT
	,@Num_Months_Prior INT = 12
	,@Num_Months_After INT = 0
	,@ECTCodeVersion_Year INT = 2012
	,@ECTCodeStatus VARCHAR(1) = 'A'
	,@AnchorDate_Year INT = 2012
	,@AnchorDate_Month VARCHAR(2) = 12
	,@AnchorDate_Day VARCHAR(2) = 31
	,@ReportType CHAR(1) = 'P' --P for Population ,S for Stategic
	)
AS
/************************************************************ INPUT PARAMETERS ************************************************************

	 @PopulationDefinitionID = Handle to the selected Population of Patients from which the Eligible Population of Patients of the Numerator
							   are to be constructed.

	 @Num_Months_Prior = Number of Months Before the Anchor Date from which Eligible Population of Patients with desired Encounter Claims
						 is to be constructed.

	 @Num_Months_After = Number of Months After the Anchor Date from which Eligible Population of Patients with desired Encounter Claims
						 is to be constructed.

	 @ECTCodeVersion_Year = Code Version Year from which valid HEDIS-associated ECT and Drug Codes during the Measurement Period that are
						    retrieved to identify Patients for inclusion in the Eligible Population of Patients.

	 @ECTCodeStatus = Status of valid HEDIS-associated ECT and Drug Codes during the Measurement Period that are retrieved to identify Patients
					  for inclusion in the Eligible Population of Patients during the Measurement Period.
					  Examples = 1 (for 'Enabled') or 0 (for 'No').

	 *********************************************************************************************************************************************/
/* Retrieves Patients with Performed Procedures with Procedure Codes during the Measurement Period. */
DECLARE @v_DenominatorType VARCHAR(1)
	,@i_ManagedPopulationID INT

SELECT @v_DenominatorType = m.DenominatorType
	,@i_ManagedPopulationID = m.ManagedPopulationID
FROM Metric m
WHERE m.MetricId = @MetricID

CREATE TABLE #PDNR (
	PatientID INT
	,[COUNT] INT
	,IsIndicator BIT
	)


	IF @v_DenominatorType = 'M'
		AND @i_ManagedPopulationID IS NOT NULL
	BEGIN
		INSERT INTO #PDNR
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure_SelectedPopulation_MP('CDC-J', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @i_ManagedPopulationID, @ReportType)
		
		UNION
		
		/* Retrieves Patients with Performed Lab Tests with LOINC Codes during the Measurement Period. */
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_LabData_SelectedPopulation_MP('CDC-J', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @i_ManagedPopulationID, @ReportType)
		
		UNION
		
		SELECT DISTINCT p.[PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM (
			SELECT DISTINCT ci.[PatientID]
				,cl.[BeginServiceDate]
			FROM [dbo].[ClaimInfo] ci
			INNER JOIN [dbo].[ClaimLine] cl ON cl.[ClaimInfoID] = ci.[ClaimInfoId]
			INNER JOIN [dbo].[PopulationDefinitionPatients] p ON p.[PatientID] = ci.[PatientID]
			INNER JOIN PatientProgram pp WITH (NOLOCK) ON pp.PatientID = p.PatientID
			INNER JOIN (
				SELECT pdpa1.PopulationDefinitionPatientID
					,MAX(pdpa1.OutPutAnchorDate) OutPutAnchorDate
				FROM PopulationDefinitionPatientAnchorDate pdpa1 WITH (NOLOCK)
				INNER JOIN PopulationDefinitionPatients pdp WITH (NOLOCK) ON pdp.PopulationDefinitionPatientID = pdpa1.PopulationDefinitionPatientID
				WHERE pdp.PopulationDefinitionID = @PopulationDefinitionID
				GROUP BY pdpa1.PopulationDefinitionPatientID
				) pdpa ON pdpa.PopulationDefinitionPatientID = p.PopulationDefinitionPatientID
			LEFT OUTER JOIN [dbo].[CodeSetProcedure] cod_proc ON (cod_proc.[ProcedureCodeID] = cl.[ProcedureCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_proc.[BeginDate]
						AND cod_proc.[EndDate]
					)
			INNER JOIN [dbo].[LkUpCodeType] ct ON ct.[CodeTypeID] = cod_proc.[CodeTypeID]
			LEFT OUTER JOIN [dbo].[ClaimLineDiagnosis] cld ON cld.[ClaimLineID] = cl.[ClaimLineID]
			INNER JOIN [dbo].[LkUpPurposeCode] pc ON (pc.[PurposeCodeID] = cld.[PurposeCodeID])
				AND (
					pc.[PurposeDescription] IN (
						'Diagnosis'
						,'Discharge Diagnosis'
						)
					)
			INNER JOIN [dbo].[CodeSetICDDiagnosis] cod_diag ON (cod_diag.[DiagnosisCodeID] = cld.[DiagnosisCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_diag.[BeginDate]
						AND cod_diag.[EndDate]
					)
			INNER JOIN [dbo].[LkUpCodeType] ct2 ON ct2.[CodeTypeID] = cod_diag.[CodeTypeID]
			LEFT OUTER JOIN [dbo].CodeSetCMSPlaceOfService cod_pos ON (cod_pos.PlaceOfServiceCodeID = cl.PlaceOfServiceCodeID)
				AND (
					cl.[BeginServiceDate] BETWEEN cod_pos.[BeginDate]
						AND cod_pos.[EndDate]
					)
			LEFT OUTER JOIN [dbo].[CodeSetRevenue] cod_rev ON (cod_rev.[RevenueCodeID] = cl.[RevenueCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_rev.[BeginDate]
						AND cod_rev.[EndDate]
					)
			WHERE (
					cl.[BeginServiceDate] BETWEEN (DATEADD(YYYY, - @Num_Months_Prior, pdpa.[OutputAnchorDate]))
						AND (DATEADD(YYYY, @Num_Months_After, pdpa.[OutputAnchorDate]))
					)
				AND (
					/* Retrieves Patients with Assigned Diagnosis with ICD Diagnosis Codes during the Measurement Period. */
					(
						cod_diag.[DiagnosisCode] IN (
							SELECT [ECTCode]
							FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
							WHERE [ECTHedisCodeTypeCode] IN (
									'ICD9-Diag'
									,'ICD10-Diag'
									)
							)
						)
					OR
					/* Retrieves Patients with Performed Procedures with Procedure Codes during the Measurement Period. */
					(
						cod_proc.[ProcedureCode] IN (
							SELECT [ECTCode]
							FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
							WHERE [ECTHedisCodeTypeCode] IN (
									'CPT'
									,'CPT-CAT-II'
									,'HCPCS'
									)
							)
						)
					OR
					/* Retrieves Patients with Performed Procedures with Revenue Codes during the Measurement Period. */
					(
						cod_rev.[RevenueCode] IN (
							SELECT [ECTCode]
							FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
							WHERE [ECTHedisCodeTypeCode] = 'RevCode'
							)
						)
					OR
					/* Retrieves Patients with Performed Procedures at the 'Place of Service' during the Measurement Period. */
					(
						cod_pos.[PlaceOfServiceCode] IN (
							SELECT [ECTCode]
							FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
							WHERE [ECTHedisCodeTypeCode] = 'POS'
							)
						)
					)
				AND p.PopulationDefinitionID = @PopulationDefinitionID
				AND pp.ProgramID = @i_ManagedPopulationID
				--AND pdpa.DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day)
			) AS p
		
		UNION
		
		SELECT DISTINCT ci.[PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM [dbo].[ClaimInfo] ci
		LEFT OUTER JOIN [dbo].[ClaimProcedure] cp ON cp.[ClaimInfoID] = ci.[ClaimInfoId]
		INNER JOIN [dbo].[PopulationDefinitionPatients] p ON p.[PatientID] = ci.[PatientID]
		INNER JOIN PatientProgram pp WITH (NOLOCK) ON pp.PatientID = p.PatientID
		INNER JOIN (
			SELECT pdpa1.PopulationDefinitionPatientID
				,MAX(pdpa1.OutPutAnchorDate) OutPutAnchorDate
			FROM PopulationDefinitionPatientAnchorDate pdpa1 WITH (NOLOCK)
			INNER JOIN PopulationDefinitionPatients pdp WITH (NOLOCK) ON pdp.PopulationDefinitionPatientID = pdpa1.PopulationDefinitionPatientID
			WHERE pdp.PopulationDefinitionID = @PopulationDefinitionID
			GROUP BY pdpa1.PopulationDefinitionPatientID
			) pdpa ON pdpa.PopulationDefinitionPatientID = p.PopulationDefinitionPatientID
		INNER JOIN [dbo].[CodeSetICDProcedure] cod_proc ON (cod_proc.[ProcedureCodeID] = cp.[ProcedureCodeID])
			AND (
				ci.[DateOfAdmit] BETWEEN cod_proc.[BeginDate]
					AND cod_proc.[EndDate]
				)
		INNER JOIN [dbo].[LkUpCodeType] ct ON ct.[CodeTypeID] = cod_proc.[CodeTypeID]
		INNER JOIN CodeSetTypeOfBill cstb ON cstb.TypeOfBillCodeID = ci.TypeOfBillCodeID
		WHERE (
				[DateOfAdmit] BETWEEN (DATEADD(YYYY, - @Num_Months_Prior, pdpa.[OutputAnchorDate]))
					AND (DATEADD(YYYY, @Num_Months_After, pdpa.[OutputAnchorDate]))
				)
			AND (
				/* Retrieves Patients with Medical Claims of the 'Type of Bill' during the Measurement Period. */
				(
					cstb.TypeOfBillCode IN (
						SELECT [ECTCode]
						FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
						WHERE [ECTHedisCodeTypeCode] = 'TOB'
						)
					)
				OR
				/* Retrieves Patients with the Performed Procedure with ICD Procedure Codes during the Measurement Period. */
				(
					cod_proc.[ProcedureCode] IN (
						SELECT [ECTCode]
						FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
						WHERE [ECTHedisCodeTypeCode] IN (
								'ICD9-Proc'
								,'ICD10-Proc'
								)
						)
					)
				)
			AND p.PopulationDefinitionID = @PopulationDefinitionID
			AND pp.ProgramID = @i_ManagedPopulationID
		--AND pdpa.DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day)
		
		UNION
		
		/* Retrieves Patients with Performed Lab Tests with LOINC Codes during the Measurement Period. */
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_LabData_SelectedPopulation_MP('CDC-K', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @i_ManagedPopulationID, @ReportType)
		
		UNION
		
		/* Retrieves Patients with Prescriptions with Drug Codes during the Measurement Period. */
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_RxClaims_SelectedPopulation_MP('CDC-L', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @i_ManagedPopulationID, @ReportType)
			/* Rathnam commented due to missing functions
UNION

/* Retrieves Patients with Medical Claims on which Health Care Providers with associated Specialties is identified on the Claim. */
SELECT DISTINCT [PatientID], 1 AS 'Count', 1 AS 'IsIndicator'
FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProviderSpecialty_SelectedPopulation(@PopulationDefinitionID, 0, 'Nephrology', NULL,
																					 @Num_Months_Prior, @Num_Months_After)

UNION

/* Retrieves Patients with Medical Claims on which Health Care Providers with associated Taxonomies is identified on the Claim. */
SELECT DISTINCT [PatientID], 1 AS 'Count', 1 AS 'IsIndicator'
FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProviderTaxonomyCode_SelectedPopulation(@PopulationDefinitionID, 0, 'Nephrology', NULL,
																				@Num_Months_Prior, @Num_Months_After)
																				*/
	END
	ELSE
	BEGIN
		INSERT INTO #PDNR
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure_SelectedPopulation('CDC-J', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)
		
		UNION
		
		/* Retrieves Patients with Performed Lab Tests with LOINC Codes during the Measurement Period. */
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_LabData_SelectedPopulation('CDC-J', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)
		
		UNION
		
		SELECT DISTINCT p.[PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM (
			SELECT DISTINCT ci.[PatientID]
				,cl.[BeginServiceDate]
			FROM [dbo].[ClaimInfo] ci
			INNER JOIN [dbo].[ClaimLine] cl ON cl.[ClaimInfoID] = ci.[ClaimInfoId]
			INNER JOIN [dbo].[PopulationDefinitionPatients] p ON p.[PatientID] = ci.[PatientID]
			INNER JOIN PopulationDefinitionPatientAnchorDate pdpa ON pdpa.PopulationDefinitionPatientID = p.PopulationDefinitionPatientID
			LEFT OUTER JOIN [dbo].[CodeSetProcedure] cod_proc ON (cod_proc.[ProcedureCodeID] = cl.[ProcedureCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_proc.[BeginDate]
						AND cod_proc.[EndDate]
					)
			INNER JOIN [dbo].[LkUpCodeType] ct ON ct.[CodeTypeID] = cod_proc.[CodeTypeID]
			LEFT OUTER JOIN [dbo].[ClaimLineDiagnosis] cld ON cld.[ClaimLineID] = cl.[ClaimLineID]
			INNER JOIN [dbo].[LkUpPurposeCode] pc ON (pc.[PurposeCodeID] = cld.[PurposeCodeID])
				AND (
					pc.[PurposeDescription] IN (
						'Diagnosis'
						,'Discharge Diagnosis'
						)
					)
			INNER JOIN [dbo].[CodeSetICDDiagnosis] cod_diag ON (cod_diag.[DiagnosisCodeID] = cld.[DiagnosisCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_diag.[BeginDate]
						AND cod_diag.[EndDate]
					)
			INNER JOIN [dbo].[LkUpCodeType] ct2 ON ct2.[CodeTypeID] = cod_diag.[CodeTypeID]
			LEFT OUTER JOIN [dbo].CodeSetCMSPlaceOfService cod_pos ON (cod_pos.PlaceOfServiceCodeID = cl.PlaceOfServiceCodeID)
				AND (
					cl.[BeginServiceDate] BETWEEN cod_pos.[BeginDate]
						AND cod_pos.[EndDate]
					)
			LEFT OUTER JOIN [dbo].[CodeSetRevenue] cod_rev ON (cod_rev.[RevenueCodeID] = cl.[RevenueCodeID])
				AND (
					cl.[BeginServiceDate] BETWEEN cod_rev.[BeginDate]
						AND cod_rev.[EndDate]
					)
			WHERE (
					cl.[BeginServiceDate] BETWEEN (DATEADD(YYYY, - @Num_Months_Prior, pdpa.[OutputAnchorDate]))
						AND (DATEADD(YYYY, @Num_Months_After, pdpa.[OutputAnchorDate]))
					)
				AND (
					/* Retrieves Patients with Assigned Diagnosis with ICD Diagnosis Codes during the Measurement Period. */
					(
						cod_diag.[DiagnosisCode] IN (
							SELECT [ECTCode]
							FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
							WHERE [ECTHedisCodeTypeCode] IN (
									'ICD9-Diag'
									,'ICD10-Diag'
									)
							)
						)
					OR
					/* Retrieves Patients with Performed Procedures with Procedure Codes during the Measurement Period. */
					(
						cod_proc.[ProcedureCode] IN (
							SELECT [ECTCode]
							FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
							WHERE [ECTHedisCodeTypeCode] IN (
									'CPT'
									,'CPT-CAT-II'
									,'HCPCS'
									)
							)
						)
					OR
					/* Retrieves Patients with Performed Procedures with Revenue Codes during the Measurement Period. */
					(
						cod_rev.[RevenueCode] IN (
							SELECT [ECTCode]
							FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
							WHERE [ECTHedisCodeTypeCode] = 'RevCode'
							)
						)
					OR
					/* Retrieves Patients with Performed Procedures at the 'Place of Service' during the Measurement Period. */
					(
						cod_pos.[PlaceOfServiceCode] IN (
							SELECT [ECTCode]
							FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
							WHERE [ECTHedisCodeTypeCode] = 'POS'
							)
						)
					)
				AND p.PopulationDefinitionID = @PopulationDefinitionID
				AND pdpa.DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day)
			) AS p
		
		UNION
		
		SELECT DISTINCT ci.[PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM [dbo].[ClaimInfo] ci
		LEFT OUTER JOIN [dbo].[ClaimProcedure] cp ON cp.[ClaimInfoID] = ci.[ClaimInfoId]
		INNER JOIN [dbo].[PopulationDefinitionPatients] p ON p.[PatientID] = ci.[PatientID]
		INNER JOIN PopulationDefinitionPatientAnchorDate pdpa ON pdpa.PopulationDefinitionPatientID = p.PopulationDefinitionPatientID
		INNER JOIN [dbo].[CodeSetICDProcedure] cod_proc ON (cod_proc.[ProcedureCodeID] = cp.[ProcedureCodeID])
			AND (
				ci.[DateOfAdmit] BETWEEN cod_proc.[BeginDate]
					AND cod_proc.[EndDate]
				)
		INNER JOIN [dbo].[LkUpCodeType] ct ON ct.[CodeTypeID] = cod_proc.[CodeTypeID]
		INNER JOIN CodeSetTypeOfBill cstb ON cstb.TypeOfBillCodeID = ci.TypeOfBillCodeID
		WHERE (
				[DateOfAdmit] BETWEEN (DATEADD(YYYY, - @Num_Months_Prior, pdpa.[OutputAnchorDate]))
					AND (DATEADD(YYYY, @Num_Months_After, pdpa.[OutputAnchorDate]))
				)
			AND (
				/* Retrieves Patients with Medical Claims of the 'Type of Bill' during the Measurement Period. */
				(
					cstb.TypeOfBillCode IN (
						SELECT [ECTCode]
						FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
						WHERE [ECTHedisCodeTypeCode] = 'TOB'
						)
					)
				OR
				/* Retrieves Patients with the Performed Procedure with ICD Procedure Codes during the Measurement Period. */
				(
					cod_proc.[ProcedureCode] IN (
						SELECT [ECTCode]
						FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-K', @ECTCodeVersion_Year, @ECTCodeStatus)
						WHERE [ECTHedisCodeTypeCode] IN (
								'ICD9-Proc'
								,'ICD10-Proc'
								)
						)
					)
				)
			AND p.PopulationDefinitionID = @PopulationDefinitionID
			AND pdpa.DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day)
		
		UNION
		
		/* Retrieves Patients with Performed Lab Tests with LOINC Codes during the Measurement Period. */
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_LabData_SelectedPopulation('CDC-K', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)
		
		UNION
		
		/* Retrieves Patients with Prescriptions with Drug Codes during the Measurement Period. */
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_RxClaims_SelectedPopulation('CDC-L', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)
			/* Rathnam commented due to missing functions
UNION

/* Retrieves Patients with Medical Claims on which Health Care Providers with associated Specialties is identified on the Claim. */
SELECT DISTINCT [PatientID], 1 AS 'Count', 1 AS 'IsIndicator'
FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProviderSpecialty_SelectedPopulation(@PopulationDefinitionID, 0, 'Nephrology', NULL,
																					 @Num_Months_Prior, @Num_Months_After)

UNION

/* Retrieves Patients with Medical Claims on which Health Care Providers with associated Taxonomies is identified on the Claim. */
SELECT DISTINCT [PatientID], 1 AS 'Count', 1 AS 'IsIndicator'
FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProviderTaxonomyCode_SelectedPopulation(@PopulationDefinitionID, 0, 'Nephrology', NULL,
																				@Num_Months_Prior, @Num_Months_After)
																				*/
	
END


DECLARE @DateKey INT

SET @DateKey = (CONVERT(VARCHAR, @AnchorDate_Year) + RIGHT('0' + CAST(@AnchorDate_Month AS VARCHAR), 2) + RIGHT('0' + CAST(@AnchorDate_Day AS VARCHAR), 2))

--SET @DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day) 

	MERGE NRPatientCount AS T
	USING (
		SELECT @MetricID AS MetricID
			--,@i_NrID AS NrID
			,PatientID
			,[Count] Cnt
			,IsIndicator
			,@DateKey DateKey
		FROM #PDNR
		) AS S
		ON (
				t.MetricID = s.MetricID
				AND t.PatientID = s.PatientID
				AND t.DateKey = s.DateKey
				)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				MetricID
				--,NRDefID
				,PatientID
				,Count
				,IsIndicator
				,CreatedByUserId
				,DateKey
				)
			VALUES (
				S.MetricID
				--,S.NrID
				,s.PatientID
				,s.Cnt
				,s.IsIndicator
				,1
				,s.DateKey
				)
	WHEN MATCHED
		THEN
			UPDATE
			SET T.Count = S.Cnt
				,T.IsIndicator = S.IsIndicator
	WHEN NOT MATCHED BY SOURCE
		AND EXISTS (
			SELECT 1
			FROM #PDNR c
			WHERE t.MetricID = @MetricID
				--AND c.PatientId <> t.PatientID
				AND t.DateKey = @DateKey
			)
		THEN
			DELETE;

	DECLARE @i_cnt INT

	SELECT @i_cnt = COUNT(*)
	FROM #PDNR

	IF @i_cnt = 0
	BEGIN
		DELETE
		FROM NRPatientCount
		WHERE MetricID = @MetricID
			AND DateKey = @DateKey

END

DROP TABLE #PDNR

DROP TABLE #CDC_LDL_C_100_Patients_ByProcedures;

DROP TABLE #CDC_LDL_C_100_Patients_ByLabTest;


/****** Object:  UserDefinedFunction [dbo].[ufn_HEDIS_GetPatients_RxClaims_SelectedPopulation_MP]    Script Date: 02/14/2014 06:41:49 ******/
SET ANSI_NULLS ON

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_CDC_GetNumerator_Nephropathy_Testing_Indicator_2012] TO [FE_rohit.r-ext]
    AS [dbo];

