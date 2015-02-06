/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_PopulateCodeGroupForHedis]  
Description   : This proc is used to extract the data from calim and map the codegrouping information to the patient
Created By    : Rathnam  
Created Date  : 20-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_PopulateCodeGroupForHedis] 
	(
	@i_AppUserId KEYID
	,@i_CodeGroupingID KEYID
	)
AS
BEGIN TRY
	SET NOCOUNT ON

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

	/* Populating the data into the PatientLabGroup ,PatientMedicationCodeGroup,PatientProcedureCodeGroup,PatientDiagnosisCodeGroup 
   & PatientOtherCodeGroup  tables with reference to the Hedis tables CodeGroupingECTTable,CodeSetHEDIS_ECTCode & CodeSetECTHedisCodeType */
	DECLARE @i_ECTHedisCodeTypeID INT

	SELECT @i_ECTHedisCodeTypeID = ECTHedisCodeTypeID
	FROM CodeSetECTHedisCodeType csect
	WHERE ECTHedisCodeTypeCode = 'NDC'

	CREATE TABLE #CodeGroup (
		CodeGroupingID INT
		,ECTCode VARCHAR(100)
		,ECTHedisCodeTypeID INT
		,ECTHedisCodeTypeCode VARCHAR(30)
		)
	INSERT INTO #CodeGroup
	SELECT DISTINCT gpet.CodeGroupingID
		,ec.ECTCode
		,ec.ECTHedisCodeTypeID
		,ect.LkupCode ECTHedisCodeTypeCode
	FROM CodeGroupingECTTable gpet
	INNER JOIN CodeSetHEDIS_ECTCode ec
		ON gpet.ECThedisTableID = ec.ECTHedisTableID
	INNER JOIN CodeSetECTHedisCodeType ect
		ON ect.ECTHedisCodeTypeID = ec.ECTHedisCodeTypeID
	INNER JOIN CodeGrouping cg
		ON cg.CodeGroupingID = gpet.CodeGroupingID
	WHERE (
			(
				gpet.ECTTableDescription = ec.ECTCodeDescription
				AND ISNULL(gpet.ECTTableDescription, '') <> ''
				)
			OR ISNULL(gpet.ECTTableDescription, '') = ''
			)
		AND (
			(
				gpet.ECTHedisCodeTypeID = ec.ECTHedisCodeTypeID
				AND ISNULL(gpet.ECTHedisCodeTypeID, 0) <> 0
				)
			OR ISNULL(gpet.ECTHedisCodeTypeID, 0) = 0
			)
		AND cg.StatusCode = 'A'
		AND GPET.StatusCode = 'A'
		AND (
			cg.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)
	
	UNION ALL
	
	SELECT DISTINCT gpet.CodeGroupingID
		,ec.NDCCode
		,@i_ECTHedisCodeTypeID
		,'NDC'
	FROM CodeGroupingECTTable gpet
	INNER JOIN CodeSetHEDIS_DrugCode ec
		ON gpet.ECThedisTableID = ec.ECTHedisTableID
	INNER JOIN CodeGrouping cg
		ON cg.CodeGroupingID = gpet.CodeGroupingID
	WHERE (
			(
				gpet.ECTTableDescription = ec.CategoryName
				AND ISNULL(gpet.ECTTableDescription, '') <> ''
				)
			OR ISNULL(gpet.ECTTableDescription, '') = ''
			)
		AND cg.StatusCode = 'A'
		AND GPET.StatusCode = 'A'
		AND (
			cg.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)

	SELECT DISTINCT pm.PatientMeasureID
		,cg1.CodeGroupingID
	INTO #Lab1
	FROM PatientMeasure pm
	INNER JOIN CodeSetLoinc cg
		ON cg.LoincCodeId = pm.LOINCCodeID
	INNER JOIN #CodeGroup cg1
		ON cg1.ECTCode = cg.LoincCode
	WHERE cg1.ECTHedisCodeTypeCode = 'LOINC'

	MERGE PatientLabGroup AS t
	USING (
		SELECT PatientMeasureID
			,CodeGroupingID
		FROM #Lab1
		) AS s
		ON (t.PatientMeasureID = s.PatientMeasureID)
			AND t.CodeGroupingID = s.CodeGroupingID
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				PatientMeasureID
				,CodeGroupingID
				,StatusCode
				,CreatedByUserId
				,CreatedDate
				)
			VALUES (
				s.PatientMeasureID
				,s.CodeGroupingID
				,'A'
				,1
				,GETDATE()
				)

	WHEN MATCHED
		THEN
			UPDATE
			SET t.StatusCode = 'A'
	--WHEN NOT MATCHED BY SOURCE --Row exists in target but not in source
	--	AND EXISTS (
	--		SELECT 1
	--		FROM #Lab1 c
	--		WHERE c.CodeGroupingID = t.CodeGroupingID
	--		)
	--	THEN
	--		UPDATE
	--		SET t.StatusCode = 'I'
			;
	CREATE NONCLUSTERED INDEX Lab1
ON [dbo].#Lab1 (PatientMeasureID)
	DELETE
	FROM PatientLabGroup
	WHERE PatientMeasureID NOT IN (
			SELECT PatientMeasureID
			FROM #Lab1 t
			)
		AND PatientLabGroup.CodeGroupingID = @i_CodeGroupingID

	SELECT DISTINCT pm.RxClaimID
		,cg1.CodeGroupingID
	INTO #medicationCTE1
	FROM RxClaim pm
	INNER JOIN CodeSetDrug cg
		ON cg.DrugCodeId = pm.DrugCodeId
	INNER JOIN #CodeGroup cg1
		ON cg1.ECTCode = cg.DrugCode
	WHERE cg1.ECTHedisCodeTypeCode = 'NDC'

	MERGE PatientMedicationCodeGroup AS t
	USING (
		SELECT RxClaimID
			,CodeGroupingID
		FROM #medicationCTE1
		) AS s
		ON (t.RxClaimID = s.RxClaimID)
			AND t.CodeGroupingID = s.CodeGroupingID
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				RxClaimID
				,CodeGroupingID
				,StatusCode
				,CreatedByUserId
				,CreatedDate
				)
			VALUES (
				s.RxClaimID
				,s.CodeGroupingID
				,'A'
				,1
				,GETDATE()
				)
	WHEN MATCHED
		THEN
			UPDATE
			SET t.StatusCode = 'A'

	--WHEN NOT MATCHED BY SOURCE --Row exists in target but not in source
	--	AND EXISTS (
	--		SELECT 1
	--		FROM #medicationCTE1 c
	--		WHERE c.CodeGroupingID = t.CodeGroupingID
	--		)
	--	THEN
	--		UPDATE
	--		SET t.StatusCode = 'I'
	;
		CREATE NONCLUSTERED INDEX medicationCTE1
ON [dbo].#medicationCTE1 (RxClaimId)
	DELETE
	FROM PatientMedicationCodeGroup
	WHERE RxClaimId NOT IN (
			SELECT RxClaimId
			FROM #medicationCTE1 t
			)
		AND PatientMedicationCodeGroup.CodeGroupingID = @i_CodeGroupingID;

	WITH proCTE
	AS (
		SELECT DISTINCT pm.PatientProcedureCodeID
			,cg.CodeGroupingID
		FROM PatientProcedureCode pm
		INNER JOIN CodeSetProcedure csp
			ON csp.ProcedureCodeID = pm.ProcedureCodeID
		INNER JOIN #CodeGroup cg
			ON cg.ECTCode = csp.ProcedureCode
		INNER JOIN LkupCodetype lku
			ON lku.CodeTypeID = pm.LkUpCodeTypeID
		WHERE cg.ECTHedisCodeTypeCode IN (
				'CPT'
				,'HCPCS'
				,'ICD-9-CM-Proc'
				)
			AND lku.CodeTypeCode = cg.ECTHedisCodeTypeCode 
				--CASE 
				--WHEN cg.ECTHedisCodeTypeCode = 'ICD9-Proc'
				--	THEN 'ICD-9-CM-Proc'
				--WHEN cg.ECTHedisCodeTypeCode = 'CPT'
				--	THEN 'CPT'
				--WHEN cg.ECTHedisCodeTypeCode = 'HCPCS'
				--	THEN 'HCPCS'

				--END --
		
		
		UNION
		
		SELECT DISTINCT pm.PatientProcedureCodeID
			,cg.CodeGroupingID
		FROM PatientProcedureCode pm
		INNER JOIN CodeSetProceduremodifier csp
			ON csp.ProcedureCodeModifierId = pm.ProcedureCodeID
		INNER JOIN #CodeGroup cg
			ON cg.ECTCode = csp.ProcedureCodeModifierCode
		INNER JOIN LkupCodetype lku
			ON lku.CodeTypeID = pm.LkUpCodeTypeID
		WHERE cg.ECTHedisCodeTypeCode IN (
				'CPT_HCPCS_Modifier'
				)
			AND lku.CodeTypeCode = cg.ECTHedisCodeTypeCode 
			--CASE 
			--	WHEN cg.ECTHedisCodeTypeCode = 'CPT-Mod'
			--		THEN 'CPT_HCPCS_Modifier'
			--	END --CPT-Mod
		UNION 
		
		SELECT DISTINCT pm.PatientProcedureCodeID
			,cg.CodeGroupingID
		FROM PatientProcedureCode pm
		INNER JOIN CodeSetICDProcedure csp
			ON csp.ProcedureCodeID = pm.ProcedureCodeID
		INNER JOIN #CodeGroup cg
			ON cg.ECTCode = csp.ProcedureCode
		INNER JOIN LkupCodetype lku
			ON lku.CodeTypeID = pm.LkUpCodeTypeID
		WHERE cg.ECTHedisCodeTypeCode IN ('CPT-CAT-II')
			AND lku.CodeTypeCode = cg.ECTHedisCodeTypeCode
			--CASE 
			--	WHEN cg.ECTHedisCodeTypeCode = 'CPT-CAT-II'
			--		THEN 'CPT-CAT-II'
			--	END
		
		UNION ALL
		
		SELECT DISTINCT pm.PatientProcedureCodeID
			,cg.CodeGroupingID
		FROM PatientProcedureCode pm
		INNER JOIN CodeSetRevenue csp
			ON csp.RevenueCodeID = pm.ProcedureCodeID
		INNER JOIN #CodeGroup cg
			ON cg.ECTCode = csp.RevenueCode
		INNER JOIN LkupCodetype lku
			ON lku.CodeTypeID = pm.LkUpCodeTypeID
		WHERE cg.ECTHedisCodeTypeCode IN ('UB-Revenue')
			AND lku.CodeTypeCode = cg.ECTHedisCodeTypeCode
			 --CASE 
				--WHEN cg.ECTHedisCodeTypeCode = 'RevCode'
				--	THEN 'UB-Revenue'
				--END
		)
	SELECT *
	INTO #proCTE1
	FROM proCTE

	MERGE PatientProcedureCodeGroup AS t
	USING (
		SELECT PatientProcedureCodeID
			,CodeGroupingID
		FROM #proCTE1
		) AS s
		ON (t.PatientProcedureCodeID = s.PatientProcedureCodeID)
			AND t.CodeGroupingID = s.CodeGroupingID
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				PatientProcedureCodeID
				,CodeGroupingID
				,StatusCode
				,CreatedByUserId
				,CreatedDate
				)
			VALUES (
				s.PatientProcedureCodeID
				,s.CodeGroupingID
				,'A'
				,1
				,GETDATE()
				)
	WHEN MATCHED
		THEN
			UPDATE
			SET t.StatusCode = 'A'

	--WHEN NOT MATCHED BY SOURCE --Row exists in target but not in source
	--	AND EXISTS (
	--		SELECT 1
	--		FROM #proCTE1 c
	--		WHERE c.CodeGroupingID = t.CodeGroupingID
	--		)
	--	THEN
	--		UPDATE
	--		SET t.StatusCode = 'I'
	;
			CREATE NONCLUSTERED INDEX proCTE1
ON [dbo].#proCTE1 (PatientProcedureCodeID)
	DELETE
	FROM PatientProcedureCodeGroup
	WHERE PatientProcedureCodeID NOT IN (
			SELECT PatientProcedureCodeID
			FROM #proCTE1 t
			)
		AND PatientProcedureCodeGroup.CodeGroupingID = @i_CodeGroupingID

	SELECT DISTINCT pm.PatientDiagnosisCodeID
		,cg1.CodeGroupingID
	INTO #icdCTE1
	FROM PatientDiagnosisCode pm
	INNER JOIN CodeSetICDDiagnosis cg
		ON cg.DiagnosisCodeID = pm.DiagnosisCodeID
	INNER JOIN #CodeGroup cg1
		ON cg1.ECTCode = cg.DiagnosisCode
	INNER JOIN LkUpCodeType lkp
		ON lkp.CodeTypeID = cg.CodeTypeID
	WHERE cg1.ECTHedisCodeTypeCode IN ('ICD-9-CM-Diag')
		AND lkp.CodeTypeCode =  cg1.ECTHedisCodeTypeCode
		--CASE 
		--	WHEN cg1.ECTHedisCodeTypeCode = 'ICD9-Diag'
		--		THEN 'ICD-9-CM-Diag'
		--	END

	MERGE PatientDiagnosisCodeGroup AS t
	USING (
		SELECT PatientDiagnosisCodeID
			,CodeGroupingID
		FROM #icdCTE1
		) AS s
		ON (t.PatientDiagnosisCodeID = s.PatientDiagnosisCodeID)
			AND t.CodeGroupingID = s.CodeGroupingID
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				PatientDiagnosisCodeID
				,CodeGroupingID
				,StatusCode
				,CreatedByUserId
				,CreatedDate
				)
			VALUES (
				s.PatientDiagnosisCodeID
				,s.CodeGroupingID
				,'A'
				,1
				,GETDATE()
				)
	WHEN MATCHED
		THEN
			UPDATE
			SET t.StatusCode = 'A'

	--WHEN NOT MATCHED BY SOURCE --Row exists in target but not in source
	--	AND EXISTS (
	--		SELECT 1
	--		FROM #icdCTE1 c
	--		WHERE c.CodeGroupingID = t.CodeGroupingID
	--		)
	--	THEN
	--		UPDATE
	--		SET t.StatusCode = 'I'
	;
	
				CREATE NONCLUSTERED INDEX icdCTE1
ON [dbo].#icdCTE1 (PatientDiagnosisCodeID)
	DELETE
	FROM PatientDiagnosisCodeGroup
	WHERE PatientDiagnosisCodeID NOT IN (
			SELECT PatientDiagnosisCodeID
			FROM #icdCTE1 t
			)
		AND PatientDiagnosisCodeGroup.CodeGroupingID = @i_CodeGroupingID

	SELECT DISTINCT pm.PatientOtherCodeID
		,cg1.CodeGroupingID
	INTO #otherCTE2
	FROM PatientOtherCode pm
	INNER JOIN CodeSetCMSPlaceOfService cg
		ON cg.PlaceOfServiceCodeID = pm.OtherCodeID
	INNER JOIN #CodeGroup cg1
		ON cg1.ECTCode = cg.PlaceOfServiceCode
	INNER JOIN LkUpCodeType lkp
		ON lkp.CodeTypeID = pm.LkUpCodeTypeID
	WHERE cg1.ECTHedisCodeTypeCode = 'CMS_POS'
		AND lkp.CodeTypeCode = cg1.ECTHedisCodeTypeCode
		--CASE 
		--	WHEN cg1.ECTHedisCodeTypeCode = 'POS'
		--		THEN 'CMS_POS'
		--	END

	MERGE PatientOtherCodeGroup AS t
	USING (
		SELECT PatientOtherCodeID
			,CodeGroupingID
		FROM #otherCTE2
		) AS s
		ON (t.PatientOtherCodeID = s.PatientOtherCodeID)
			AND t.CodeGroupingID = s.CodeGroupingID
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				PatientOtherCodeID
				,CodeGroupingID
				,StatusCode
				,CreatedByUserId
				,CreatedDate
				)
			VALUES (
				s.PatientOtherCodeID
				,s.CodeGroupingID
				,'A'
				,1
				,GETDATE()
				)
	WHEN MATCHED
		THEN
			UPDATE
			SET t.StatusCode = 'A'

	--WHEN NOT MATCHED BY SOURCE --Row exists in target but not in source
	--	AND EXISTS (
	--		SELECT 1
	--		FROM #otherCTE2 c
	--		WHERE c.CodeGroupingID = t.CodeGroupingID
	--		)
	--	THEN
	--		UPDATE
	--		SET t.StatusCode = 'I'
			;
					CREATE NONCLUSTERED INDEX otherCTE2
ON [dbo].#otherCTE2 (PatientOtherCodeID)
	DELETE
	FROM PatientOtherCodeGroup
	WHERE PatientOtherCodeID NOT IN (
			SELECT PatientOtherCodeID
			FROM #otherCTE2 t
			)
		AND PatientOtherCodeGroup.CodeGroupingID = @i_CodeGroupingID
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_PopulateCodeGroupForHedis] TO [FE_rohit.r-ext]
    AS [dbo];

