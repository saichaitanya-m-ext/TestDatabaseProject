/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_PopulateCode]  
Description   : This proc is used to extract the data from calim and map the codegrouping information to the patient
Created By    : Rathnam  
Created Date  : 20-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_PopulateCode] (@i_AppUserId KEYID)
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
			/* Fetch the patients from claims to the respective code tables
	
	Populating the data into the PatientProcedureCode table from ClaimLine & ClaimProcedure 
	with reference to the CodeSetProcedure,CodeSetRevenue & CodeSetICDProcedure*/
			;

	WITH cteProc
	AS (
		/* Fetch the records from Claimline table with CodeSetProcedure tables */
		SELECT DISTINCT ci.ClaimInfoID
			,ci.PatientID
			,ci.DateOfAdmit BeginServiceDate
			,csp.ProcedureCodeID
			,csp.CodeTypeID
		FROM ClaimLine cl WITH (NOLOCK)
		INNER JOIN CodeSetProcedure csp WITH (NOLOCK)
			ON cl.ProcedureCodeID = csp.ProcedureCodeID
		INNER JOIN ClaimInfo ci WITH (NOLOCK)
			ON ci.ClaimInfoID = cl.ClaimInfoID
		WHERE cl.StatusCode = 'A'
			AND ci.StatusCode = 'A'
			AND ISNULL(ci.Isnew, 1) = 1
		
		UNION ALL
		
		/* Fetch the records from Claimline table with CodeSetRevenue tables */
		SELECT DISTINCT ci.ClaimInfoID
			,ci.PatientID
			,ci.DateOfAdmit BeginServiceDate
			,csp.RevenueCodeID
			,lkc.CodeTypeID
		FROM ClaimLine cl WITH (NOLOCK)
		INNER JOIN CodeSetRevenue csp WITH (NOLOCK)
			ON cl.RevenueCodeID = csp.RevenueCodeID
		INNER JOIN ClaimInfo ci WITH (NOLOCK)
			ON ci.ClaimInfoID = cl.ClaimInfoID
		INNER JOIN LkUpCodeType lkc WITH (NOLOCK)
			ON lkc.CodeTypeCode = 'UB-Revenue'
		WHERE cl.StatusCode = 'A'
			AND ci.StatusCode = 'A'
			AND ISNULL(ci.Isnew, 1) = 1
		
		UNION ALL
		
		/* Fetch the records from ClaimProcedure table with CodeSetICDProcedure tables */
		SELECT DISTINCT ci.ClaimInfoID
			,ci.PatientID
			,ci.DateOfAdmit
			,csp.ProcedureCodeID
			,lkc.CodeTypeID
		FROM ClaimProcedure cl WITH (NOLOCK)
		INNER JOIN CodeSetICDProcedure csp WITH (NOLOCK)
			ON cl.ProcedureCodeID = csp.ProcedureCodeID
		INNER JOIN ClaimInfo ci WITH (NOLOCK)
			ON ci.ClaimInfoID = cl.ClaimInfoID
		INNER JOIN LkUpCodeType lkc WITH (NOLOCK)
			ON lkc.CodeTypeID = csp.CodeTypeID
		WHERE cl.StatusCode = 'A'
			AND ci.StatusCode = 'A'
			AND lkc.CodeTypeCode = 'ICD-9-CM-Proc'
			AND ISNULL(ci.Isnew, 1) = 1
		
		UNION ALL
		
		SELECT DISTINCT ci.ClaimInfoID
			,ci.PatientID
			,ci.DateOfAdmit BeginServiceDate
			,csi.ProcedureCodeModifierId
			,lkc.CodeTypeID
		FROM ClaimLineModifier cld WITH (NOLOCK)
		INNER JOIN ClaimLine cl WITH (NOLOCK)
			ON cld.ClaimLineID = cl.ClaimLineID
		INNER JOIN ClaimInfo ci WITH (NOLOCK)
			ON ci.ClaimInfoID = cl.ClaimInfoID
		INNER JOIN CodeSetProcedureModifier csi WITH (NOLOCK)
			ON csi.ProcedureCodeModifierId = cld.ProcedureCodeModifierId
		INNER JOIN LkUpCodeType lkc WITH (NOLOCK)
			ON lkc.CodeTypeCode = 'CPT_HCPCS_Modifier'
		WHERE cl.StatusCode = 'A'
			AND cl.StatusCode = 'A'
			AND ISNULL(ci.Isnew, 1) = 1
		)
	SELECT *
	INTO #cteProc
	FROM cteProc

	MERGE INTO dbo.PatientProcedureCode AS t1
	USING (
		SELECT ClaimInfoID
			,PatientID
			,BeginServiceDate
			,ProcedureCodeID
			,CodeTypeID
		FROM #cteProc
		) s
		ON t1.ClaimInfoID = s.ClaimInfoID
			AND t1.PatientId = s.PatientID
			AND t1.LkUpCodeTypeID = s.CodeTypeID
			AND t1.ProcedureCodeID = s.ProcedureCodeID
			AND CONVERT(DATE, t1.DateOfService) = CONVERT(DATE, s.BeginServiceDate)
	WHEN MATCHED
		AND t1.StatusCode = 'I' --Row exists and data is different
		THEN
			UPDATE
			SET t1.StatusCode = 'A'
	WHEN NOT MATCHED BY TARGET --Row exists in source but not in target
		THEN
			INSERT (
				PatientID
				,DateOfService
				,LkUpCodeTypeID
				,ProcedureCodeID
				,ClaimInfoId
				,StatusCode
				,CreatedByUserId
				,CreatedDate
				)
			VALUES (
				s.PatientID
				,s.BeginServiceDate
				,s.CodeTypeID
				,s.ProcedureCodeID
				,s.ClaimInfoID
				,'A'
				,1
				,GETDATE()
				)
	WHEN NOT MATCHED BY SOURCE
		AND EXISTS (
			SELECT 1
			FROM #cteProc c
			WHERE c.ClaimInfoID = t1.ClaimInfoID
				AND c.PatientId = t1.PatientID
				--AND c.CodeTypeID = t1.LkUpCodeTypeID
				--AND c.ProcedureCodeID <> t1.ProcedureCodeID
				--AND CONVERT(DATE, c.BeginServiceDate) <> CONVERT(DATE, t1.DateOfService)
			)
		THEN
			UPDATE
			SET t1.StatusCode = 'I';
				/* Populating the data into the PatientDiagnosisCode table from ClaimLineDiagnosis  
	with reference to the CCodeSetICDDiagnosis*/
				;

	SELECT DISTINCT ci.ClaimInfoID
		,ci.PatientID
		,ci.DateOfAdmit BeginServiceDate
		,csi.DiagnosisCodeID
		,csi.CodeTypeID
	INTO #icd
	FROM ClaimLineDiagnosis cld WITH (NOLOCK)
	INNER JOIN ClaimLine cl WITH (NOLOCK)
		ON cld.ClaimLineID = cl.ClaimLineID
	INNER JOIN ClaimInfo ci WITH (NOLOCK)
		ON ci.ClaimInfoID = cl.ClaimInfoID
	INNER JOIN CodeSetICDDiagnosis csi WITH (NOLOCK)
		ON csi.DiagnosisCodeID = cld.DiagnosisCodeID
	WHERE cl.StatusCode = 'A'
		AND cl.StatusCode = 'A'
		AND ISNULL(ci.Isnew, 1) = 1

	MERGE PatientDiagnosisCode AS t1
	USING (
		SELECT ClaimInfoID
			,PatientID
			,BeginServiceDate
			,DiagnosisCodeID
			,CodeTypeID
		FROM #icd
		) AS S
		ON t1.ClaimInfoID = s.ClaimInfoID
			AND t1.PatientId = s.PatientID
			AND t1.DiagnosisCodeID = s.DiagnosisCodeID
			AND CONVERT(DATE, t1.DateOfService) = CONVERT(DATE, s.BeginServiceDate)
	WHEN MATCHED --Row exists and data is different
		THEN
			UPDATE
			SET t1.StatusCode = 'A'
	WHEN NOT MATCHED BY TARGET --Row exists in source but not in target
		THEN
			INSERT (
				PatientID
				,DateOfService
				,DiagnosisCodeID
				,ClaimInfoId
				,StatusCode
				,CreatedByUserId
				,CreatedDate
				)
			VALUES (
				s.PatientID
				,s.BeginServiceDate
				,s.DiagnosisCodeID
				,s.ClaimInfoID
				,'A'
				,1
				,getdate()
				)
	WHEN NOT MATCHED BY SOURCE --Row exists in target but not in source
		AND EXISTS (
			SELECT 1
			FROM #icd c
			WHERE c.ClaimInfoID = t1.ClaimInfoID
				AND c.PatientId = t1.PatientID
				--AND c.DiagnosisCodeID <> t1.DiagnosisCodeID
				--AND CONVERT(DATE, c.BeginServiceDate) <> CONVERT(DATE, t1.DateOfService)
			)
		THEN
			UPDATE
			SET t1.StatusCode = 'I';
				/* Populating the data into the PatientOtherCode table from ClaimLine  
	with reference to the CodeSetCMSPlaceOfService*/
				;

	WITH cteOther
	AS (
		SELECT DISTINCT ci.ClaimInfoID
			,ci.PatientID
			,ci.DateOfAdmit BeginServiceDate
			,csi.PlaceOfServiceCodeID
			,lct.CodeTypeID
		FROM ClaimLine cl WITH (NOLOCK)
		INNER JOIN ClaimInfo ci WITH (NOLOCK)
			ON ci.ClaimInfoID = cl.ClaimInfoID
		INNER JOIN CodeSetCMSPlaceOfService csi WITH (NOLOCK)
			ON csi.PlaceOfServiceCodeID = cl.PlaceOfServiceCodeID
		INNER JOIN LkupCodeType lct WITH (NOLOCK)
			ON lct.CodeTypeCode = 'CMS_POS'
		WHERE cl.StatusCode = 'A'
			AND cl.StatusCode = 'A'
			AND ISNULL(ci.Isnew, 1) = 1
		
		UNION ALL
		
		SELECT DISTINCT ci.ClaimInfoID
			,ci.PatientID
			,ci.DateOfAdmit
			,ci.TypeOfBillCodeID
			,lct.CodeTypeID
		FROM ClaimInfo ci WITH (NOLOCK)
		INNER JOIN CodeSetTypeOfBill csi WITH (NOLOCK)
			ON csi.TypeOfBillCodeID = ci.TypeOfBillCodeID
		INNER JOIN LkupCodeType lct WITH (NOLOCK)
			ON lct.CodeTypeCode = 'TOB'
		WHERE ci.StatusCode = 'A'
			AND ISNULL(ci.Isnew, 1) = 1
		)
	SELECT *
	INTO #Other
	FROM cteOther

	MERGE PatientOtherCode AS t1
	USING (
		SELECT ClaimInfoID
			,PatientID
			,BeginServiceDate
			,PlaceOfServiceCodeID
			,CodeTypeID
		FROM #Other
		) AS S
		ON t1.ClaimInfoID = s.ClaimInfoID
			AND t1.PatientId = s.PatientID
			AND t1.OtherCodeID = s.PlaceOfServiceCodeID
			AND CONVERT(DATE, t1.DateOfService) = CONVERT(DATE, s.BeginServiceDate)
			AND t1.LkUpCodeTypeID = s.CodeTypeID
	WHEN MATCHED --Row exists and data is different
		THEN
			UPDATE
			SET t1.StatusCode = 'A'
	WHEN NOT MATCHED BY TARGET --Row exists in source but not in target
		THEN
			INSERT (
				PatientID
				,DateOfService
				,OtherCodeID
				,ClaimInfoId
				,StatusCode
				,CreatedByUserId
				,CreatedDate
				,LkUpCodeTypeID
				)
			VALUES (
				s.PatientID
				,s.BeginServiceDate
				,s.PlaceOfServiceCodeID
				,s.ClaimInfoID
				,'A'
				,1
				,getdate()
				,CodeTypeID
				)
	WHEN NOT MATCHED BY SOURCE --Row exists in target but not in source
		AND EXISTS (
			SELECT 1
			FROM #Other c
			WHERE c.ClaimInfoID = t1.ClaimInfoID
				AND c.PatientId = t1.PatientID
				--AND c.CodeTypeID = t1.LkUpCodeTypeID
				--AND c.PlaceOfServiceCodeID <> t1.OtherCodeID
				--AND CONVERT(DATE, c.BeginServiceDate) <> CONVERT(DATE, t1.DateOfService)
			)
		THEN
			UPDATE
			SET t1.StatusCode = 'I';

	UPDATE ClaimInfo
	SET Isnew = 0
	WHERE ISNULL(Isnew, 1) = 1
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_PopulateCode] TO [FE_rohit.r-ext]
    AS [dbo];

