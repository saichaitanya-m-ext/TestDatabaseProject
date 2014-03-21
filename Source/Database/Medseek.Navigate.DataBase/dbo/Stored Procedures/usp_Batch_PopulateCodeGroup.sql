/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_PopulateCodeGroup]  
Description   : This proc is used to extract the data from calim and map the codegrouping information to the patient
Created By    : Rathnam  
Created Date  : 20-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_PopulateCodeGroup] --1,749
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

	SELECT DISTINCT pm.PatientMeasureID
		,cg.CodeGroupingID
	INTO #Lab
	FROM PatientMeasure pm
	INNER JOIN CodeGroupingDetailInternal cg
		ON cg.CodeGroupingCodeID = pm.LOINCCodeID
	INNER JOIN LkUpCodeType lkp
		ON lkp.CodeTypeID = cg.CodeGroupingCodeTypeID
	INNER JOIN CodeGrouping cgg
		ON cgg.CodeGroupingID = cg.CodeGroupingID
	WHERE lkp.CodeTypeCode = 'LOINC'
		AND cg.StatusCode = 'A'
		AND cgg.StatusCode = 'A'
		AND (
			cgg.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)

	MERGE PatientLabGroup AS t
	USING (
		SELECT PatientMeasureID
			,CodeGroupingID
		FROM #Lab
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
	--		FROM #Lab c
	--		WHERE c.CodeGroupingID = t.CodeGroupingID
	--		)
	--	THEN
	--		UPDATE
	--		SET t.StatusCode = 'I'
			;
	CREATE NONCLUSTERED INDEX Lab1 ON [dbo].#Lab (PatientMeasureID)

	DELETE
	FROM PatientLabGroup
	WHERE PatientMeasureID NOT IN (
			SELECT PatientMeasureID
			FROM #Lab t
			)
		AND PatientLabGroup.CodeGroupingID = @i_CodeGroupingID

	CREATE TABLE #medicationCTE (
		RxClaimID INT
		,CodeGroupingID INT
		)

	INSERT INTO #medicationCTE
	SELECT DISTINCT pm.RxClaimID
		,cg.CodeGroupingID
	FROM RxClaim pm
	INNER JOIN CodeGroupingDetailInternal cg
		ON cg.CodeGroupingCodeID = pm.DrugCodeId
	INNER JOIN LkUpCodeType lkp
		ON lkp.CodeTypeID = cg.CodeGroupingCodeTypeID
	INNER JOIN CodeGrouping cgg
		ON cgg.CodeGroupingID = cg.CodeGroupingID
	WHERE lkp.CodeTypeCode = 'NDC'
		AND cg.StatusCode = 'A'
		AND cgg.StatusCode = 'A'
		AND (
			cgg.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)
	
	UNION
	
	SELECT DISTINCT ppc.RxClaimID
		,cg.CodeGroupingID
	FROM RxClaim ppc
	INNER JOIN CodesetDrug csp
		ON csp.DrugCodeId = ppc.DrugCodeId
	INNER JOIN CodeSetVaccineDrug cvd
		ON cvd.VaccineDrugID = csp.VaccineDrugID
	INNER JOIN CodeSetVaccine cv
		ON cv.VaccineID = cvd.VaccineID
	INNER JOIN CodeGroupingDetailInternal cgdi
		ON cgdi.CodeGroupingCodeID = cv.VaccineID
	INNER JOIN CodeGrouping cg
		ON cg.CodeGroupingID = cgdi.CodeGroupingID
	INNER JOIN CodeTypeGroupers ctg
		ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	INNER JOIN LkUpCodeType lkp
		ON lkp.CodeTypeID = cgdi.CodeGroupingCodeTypeID
	WHERE CodeTypeGroupersName = 'CDC Vaccine Groups'
		AND CodeTypeCode = 'Vaccine'
		AND (
			cg.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)

	MERGE PatientMedicationCodeGroup AS t
	USING (
		SELECT RxClaimID
			,CodeGroupingID
		FROM #medicationCTE
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
	--		FROM #medicationCTE c
	--		WHERE c.CodeGroupingID = t.CodeGroupingID
	--		)
	--	THEN
	--		UPDATE
	--		SET t.StatusCode = 'I'
			;
	CREATE NONCLUSTERED INDEX medicationCTE1 ON [dbo].#medicationCTE (RxClaimId)

	DELETE
	FROM PatientMedicationCodeGroup
	WHERE RxClaimId NOT IN (
			SELECT RxClaimId
			FROM #medicationCTE t
			)
		AND PatientMedicationCodeGroup.CodeGroupingID = @i_CodeGroupingID

	CREATE TABLE #proCTE (
		PatientProcedureCodeID INT
		,CodeGroupingID INT
		)

	INSERT INTO #proCTE
	SELECT DISTINCT pm.PatientProcedureCodeID
		,cg.CodeGroupingID
	FROM PatientProcedureCode pm
	INNER JOIN CodeGroupingDetailInternal cg
		ON cg.CodeGroupingCodeID = pm.ProcedureCodeID
	INNER JOIN LkUpCodeType lkp
		ON lkp.CodeTypeID = cg.CodeGroupingCodeTypeID
	INNER JOIN CodeGrouping cgg
		ON cgg.CodeGroupingID = cg.CodeGroupingID
	WHERE lkp.CodeTypeCode IN (
			'CPT'
			,'HCPCS'
			,'ICD-9-CM-Proc'
			,'ICD-10-CM-Proc'
			,'UB-Revenue'
			,'CPT-CAT-II'
			,'CPT_HCPCS_Modifier'
			)
		AND cg.StatusCode = 'A'
		AND cgg.StatusCode = 'A'
		AND pm.LkUpCodeTypeID = lkp.CodeTypeID
		AND (
			cgg.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)
	
	UNION
	
	SELECT DISTINCT ppc.PatientProcedureCodeID
		,cg.CodeGroupingID
	FROM PatientProcedureCode ppc
	INNER JOIN codesetProcedure csp
		ON csp.ProcedureCodeID = ppc.ProcedureCodeID
	INNER JOIN CodeSetVaccineProcedure cvd
		ON cvd.VaccineProcedureID = csp.VaccineProcedureID
	INNER JOIN CodeSetVaccine cv
		ON cv.VaccineID = cvd.VaccineID
	INNER JOIN CodeGroupingDetailInternal cgdi
		ON cgdi.CodeGroupingCodeID = cv.VaccineID
	INNER JOIN CodeGrouping cg
		ON cg.CodeGroupingID = cgdi.CodeGroupingID
	INNER JOIN CodeTypeGroupers ctg
		ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	INNER JOIN LkUpCodeType lkp
		ON lkp.CodeTypeID = cgdi.CodeGroupingCodeTypeID
	WHERE CodeTypeGroupersName = 'CDC Vaccine Groups'
		AND CodeTypeCode = 'Vaccine'
		AND ppc.LkUpCodeTypeID = lkp.CodeTypeID
		AND (
			cg.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)

	MERGE PatientProcedureCodeGroup AS t
	USING (
		SELECT PatientProcedureCodeID
			,CodeGroupingID
		FROM #proCTE pm
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
	--		FROM #proCTE c
	--		WHERE c.CodeGroupingID = t.CodeGroupingID
	--		)
	--	THEN
	--		UPDATE
	--		SET t.StatusCode = 'I'
			;
	CREATE NONCLUSTERED INDEX proCTE1 ON [dbo].#proCTE (PatientProcedureCodeID)

	DELETE
	FROM PatientProcedureCodeGroup
	WHERE PatientProcedureCodeID NOT IN (
			SELECT PatientProcedureCodeID
			FROM #proCTE t
			)
		AND PatientProcedureCodeGroup.CodeGroupingID = @i_CodeGroupingID

	SELECT DISTINCT pm.PatientDiagnosisCodeID
		,cg.CodeGroupingID
	INTO #icdCTE
	FROM PatientDiagnosisCode pm
	INNER JOIN CodeGroupingDetailInternal cg
		ON cg.CodeGroupingCodeID = pm.DiagnosisCodeID
	INNER JOIN CodeSetICDDiagnosis csid
		ON csid.DiagnosisCodeID = pm.DiagnosisCodeID
	INNER JOIN LkUpCodeType lkp
		ON lkp.CodeTypeID = cg.CodeGroupingCodeTypeID
	INNER JOIN CodeGrouping cgg
		ON cgg.CodeGroupingID = cg.CodeGroupingID
	WHERE lkp.CodeTypeCode IN (
			'ICD-9-CM-Diag'
			,'ICD-10-CM-Diag'
			)
		AND cg.StatusCode = 'A'
		AND cgg.StatusCode = 'A'
		AND csid.CodeTypeID = lkp.CodeTypeID
		AND (
			cgg.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)

	MERGE PatientDiagnosisCodeGroup AS t
	USING (
		SELECT PatientDiagnosisCodeID
			,CodeGroupingID
		FROM #icdCTE
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
	--		FROM #icdCTE c
	--		WHERE c.CodeGroupingID = t.CodeGroupingID
	--		)
	--	THEN
	--		UPDATE
	--		SET t.StatusCode = 'I'
			;
	----CREATE NONCLUSTERED INDEX icdCTE1 ON [dbo].#icdCTE (PatientDiagnosisCodeID)

	----DELETE
	----FROM PatientDiagnosisCodeGroup
	----WHERE PatientDiagnosisCodeID NOT IN (
	----		SELECT PatientDiagnosisCodeID
	----		FROM #icdCTE t
	----		)
	----	AND PatientDiagnosisCodeGroup.CodeGroupingID = @i_CodeGroupingID

	SELECT DISTINCT pm.PatientOtherCodeID
		,cg.CodeGroupingID
	INTO #otherCTE1
	FROM PatientOtherCode pm
	INNER JOIN CodeGroupingDetailInternal cg
		ON cg.CodeGroupingCodeID = pm.OtherCodeID
	INNER JOIN LkUpCodeType lkp
		ON lkp.CodeTypeID = cg.CodeGroupingCodeTypeID
	INNER JOIN CodeGrouping cgg
		ON cgg.CodeGroupingID = cg.CodeGroupingID
	WHERE lkp.CodeTypeCode IN ('CMS_POS')
		AND cg.StatusCode = 'A'
		AND cgg.StatusCode = 'A'
		AND pm.LkUpCodeTypeID = lkp.CodeTypeID
		AND (
			cgg.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)

	MERGE PatientOtherCodeGroup AS t
	USING (
		SELECT PatientOtherCodeID
			,CodeGroupingID
		FROM #otherCTE1
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
	--		FROM #otherCTE1 c
	--		WHERE c.CodeGroupingID = t.CodeGroupingID
	--		)
	--	THEN
	--		UPDATE
	--		SET t.StatusCode = 'I'
			;
	CREATE NONCLUSTERED INDEX otherCTE2 ON [dbo].#otherCTE1 (PatientOtherCodeID)

	DELETE
	FROM PatientOtherCodeGroup
	WHERE PatientOtherCodeID NOT IN (
			SELECT PatientOtherCodeID
			FROM #otherCTE1 t
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
    ON OBJECT::[dbo].[usp_Batch_PopulateCodeGroup] TO [FE_rohit.r-ext]
    AS [dbo];

