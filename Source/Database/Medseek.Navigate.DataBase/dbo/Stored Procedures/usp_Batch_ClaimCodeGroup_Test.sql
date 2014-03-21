
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_ClaimCodeGroup]  
Description   : This proc is used to extract the data from calim and map the codegrouping information to the patient
Created By    : Rathnam  
Created Date  : 22-Feb-2014
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION 
19-Mar-2014 NagaBabu Added code for RxClaimCodeGroup,LabCodeGroup. 
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_ClaimCodeGroup_Test] 
( 
	@i_AppUserId KeyId
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
			/* Fetch the patients from claims to the respective code tables
	
	Populating the data into the PatientProcedureCode table from ClaimLine & ClaimProcedure 
	with reference to the CodeSetProcedure,CodeSetRevenue & CodeSetICDProcedure*/
			;

	WITH cteProc
	AS (
		/* Fetch the records from Claimline table with CodeSetProcedure tables */
		SELECT DISTINCT ci.ClaimInfoID
			,csp.ProcedureCodeID AS CodeID
			,csp.CodeTypeID
		FROM ClaimLine cl WITH (NOLOCK)
		INNER JOIN CodeSetProcedure csp WITH (NOLOCK)
			ON cl.ProcedureCodeID = csp.ProcedureCodeID
		INNER JOIN ClaimInfo ci WITH (NOLOCK)
			ON ci.ClaimInfoID = cl.ClaimInfoID
		WHERE cl.StatusCode = 'A'
			AND ci.StatusCode = 'A'
		--AND ISNULL(ci.Isnew, 1) = 1
		
		UNION
		
		SELECT DISTINCT CI.ClaimInfoID
			,CP.ProcedureCodeID AS CodeID
			,ICDP.CodeTypeID
		FROM ClaimInfo CI WITH (NOLOCK)
		INNER JOIN ClaimProcedure CP WITH (NOLOCK)
			ON CI.ClaimInfoID = CP.ClaimInfoID
		INNER JOIN CodeSetICDProcedure ICDP
			ON ICDP.ProcedureCodeID = CP.ProcedureCodeID
		WHERE CI.StatusCode = 'A'
		
		UNION ALL
		
		/* Fetch the records from Claimline table with CodeSetRevenue tables */
		SELECT DISTINCT ci.ClaimInfoID
			,csp.RevenueCodeID AS CodeID
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
		--AND ISNULL(ci.Isnew, 1) = 1
		
		UNION ALL
		
		/* Fetch the records from ClaimProcedure table with CodeSetICDProcedure tables */
		SELECT DISTINCT ci.ClaimInfoID
			,csp.ProcedureCodeID AS CodeID
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
			AND lkc.CodeTypeCode IN (
				'ICD-9-CM-Proc'
				,'ICD-10-CM-Proc'
				)
		--AND ISNULL(ci.Isnew, 1) = 1
		
		UNION ALL
		
		SELECT DISTINCT ci.ClaimInfoID
			,csi.ProcedureCodeModifierId AS CodeID
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
		--AND ISNULL(ci.Isnew, 1) = 1
		
		UNION ALL
		
		SELECT DISTINCT ci.ClaimInfoID
			,csi.PlaceOfServiceCodeID AS CodeID
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
		--AND ISNULL(ci.Isnew, 1) = 1
		
		UNION ALL
		
		SELECT DISTINCT ci.ClaimInfoID
			,ci.TypeOfBillCodeID AS CodeID
			,lct.CodeTypeID
		FROM ClaimInfo ci WITH (NOLOCK)
		INNER JOIN CodeSetTypeOfBill csi WITH (NOLOCK)
			ON csi.TypeOfBillCodeID = ci.TypeOfBillCodeID
		INNER JOIN LkupCodeType lct WITH (NOLOCK)
			ON lct.CodeTypeCode = 'TOB'
		WHERE ci.StatusCode = 'A'
		--AND ISNULL(ci.Isnew, 1) = 1	
		
		UNION ALL
		
		SELECT DISTINCT ci.ClaimInfoID
			,csi.DiagnosisCodeID AS CodeID
			,csi.CodeTypeID
		FROM ClaimLineDiagnosis cld WITH (NOLOCK)
		INNER JOIN ClaimLine cl WITH (NOLOCK)
			ON cld.ClaimLineID = cl.ClaimLineID
		INNER JOIN ClaimInfo ci WITH (NOLOCK)
			ON ci.ClaimInfoID = cl.ClaimInfoID
		INNER JOIN CodeSetICDDiagnosis csi WITH (NOLOCK)
			ON csi.DiagnosisCodeID = cld.DiagnosisCodeID
		WHERE cl.StatusCode = 'A'
			AND cl.StatusCode = 'A'
			--AND ISNULL(ci.Isnew, 1) = 1
		)
	SELECT *
	INTO #cteProc
	FROM cteProc

	CREATE TABLE #CodeGroup (CodeGroupingID INT)

	INSERT INTO #CodeGroup (CodeGroupingID)
	SELECT DISTINCT pdc.CodeGroupingID
	FROM PopulationDefinitionConfiguration pdc
	WHERE pdc.CodeGroupingID IS NOT NULL
	
	UNION
	
	SELECT cg.CodeGroupingID
	FROM CodeGrouping cg
	INNER JOIN CodeTypeGroupers ctg
		ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	WHERE ctg.CodeTypeGroupersName IN (
			'Encounter Types(Internal)'
			,'Utilization Type (Internal)'
			,'Encounter Type (Internal) by Code Type'
			,'CCS ICD Procedure 4Classes'
			,'CCS Chronic Diagnosis Group'
			,'CCS Diagnosis Group'
			)
	
	UNION
	
	SELECT CodeGroupingID
	FROM CodeGrouping
	WHERE CodeGroupingName IN (
			'A1C'
			,'LDL'
			)

----------------------------------------HEDIS Related -----------------------------------
	DECLARE @i_ECTHedisCodeTypeID INT
	SELECT @i_ECTHedisCodeTypeID = ECTHedisCodeTypeID
	FROM CodeSetECTHedisCodeType csect
	WHERE ECTHedisCodeTypeCode = 'NDC'

	CREATE TABLE #CodeGroup1 (
		CodeGroupingID INT
		,ECTCode VARCHAR(100)
		,ECTHedisCodeTypeID INT
		,ECTHedisCodeTypeCode VARCHAR(30)
		)
	INSERT INTO #CodeGroup1
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
	INNER JOIN #CodeGroup TCG
		ON TCG.CodeGroupingID = CG.CodeGroupingID
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
	INNER JOIN #CodeGroup TCG
		ON TCG.CodeGroupingID = CG.CodeGroupingID	
	WHERE (
			(
				gpet.ECTTableDescription = ec.CategoryName
				AND ISNULL(gpet.ECTTableDescription, '') <> ''
				)
			OR ISNULL(gpet.ECTTableDescription, '') = ''
			)
		AND cg.StatusCode = 'A'
		AND GPET.StatusCode = 'A'


	SELECT DISTINCT pm.PatientMeasureID ,
		cg1.CodeGroupingID
	INTO #LabH
	FROM PatientMeasure pm
	INNER JOIN CodeSetLoinc cg
		ON cg.LoincCodeId = pm.LOINCCodeID
	INNER JOIN #CodeGroup1 cg1
		ON cg1.ECTCode = cg.LoincCode
	WHERE cg1.ECTHedisCodeTypeCode = 'LOINC'
	
	SELECT DISTINCT pm.RxClaimID ,
		cg1.CodeGroupingID
	INTO #medicationH
	FROM RxClaim pm
	INNER JOIN CodeSetDrug cg
		ON cg.DrugCodeId = pm.DrugCodeId
	INNER JOIN #CodeGroup1 cg1
		ON cg1.ECTCode = cg.DrugCode
	WHERE cg1.ECTHedisCodeTypeCode = 'NDC'
	
	;WITH CURClaimH
	AS (
		SELECT DISTINCT CI.ClaimInfoId
				,cg.CodeGroupingID
			FROM ClaimLine cl WITH (NOLOCK)
			INNER JOIN CodeSetProcedure csp WITH (NOLOCK)
				ON cl.ProcedureCodeID = csp.ProcedureCodeID
			INNER JOIN ClaimInfo ci WITH (NOLOCK)
				ON ci.ClaimInfoID = cl.ClaimInfoID
			INNER JOIN #CodeGroup1 cg
				ON cg.ECTCode = csp.ProcedureCode
			INNER JOIN LkupCodetype lku
			--	ON lku.CodeTypeID = CSP.CodeTypeID
				ON lku.CodeTypeCode = cg.ECTHedisCodeTypeCode
			WHERE cg.ECTHedisCodeTypeCode IN (
					'CPT'
					,'HCPCS'
					--,'ICD-9-CM-Proc'
					,'CPT-CAT-II'
					,'CPT-CAT-III'
					)
				--AND lku.CodeTypeCode = cg.ECTHedisCodeTypeCode 
			
			UNION
			
			SELECT DISTINCT CI.ClaimInfoId
				,cg.CodeGroupingID
			FROM ClaimLineModifier cld WITH (NOLOCK)
			INNER JOIN ClaimLine cl WITH (NOLOCK)
				ON cld.ClaimLineID = cl.ClaimLineID
			INNER JOIN ClaimInfo ci WITH (NOLOCK)
				ON ci.ClaimInfoID = cl.ClaimInfoID
			INNER JOIN CodeSetProceduremodifier csp
				ON csp.ProcedureCodeModifierId = cld.ProcedureCodeModifierId
			INNER JOIN #CodeGroup1 cg
				ON cg.ECTCode = csp.ProcedureCodeModifierCode
			INNER JOIN LkupCodetype lku
			--	ON lku.CodeTypeID = CG.ECTHedisCodeTypeID
				ON lku.CodeTypeCode = cg.ECTHedisCodeTypeCode
			WHERE cg.ECTHedisCodeTypeCode IN ('CPT_HCPCS_Modifier')
				--AND lku.CodeTypeCode = cg.ECTHedisCodeTypeCode 

			UNION 
			
			SELECT DISTINCT CI.ClaimInfoId
				,cg.CodeGroupingID
			FROM ClaimLine cl WITH (NOLOCK)
			INNER JOIN CodeSetRevenue csp WITH (NOLOCK)
				ON cl.RevenueCodeID = csp.RevenueCodeID
			INNER JOIN ClaimInfo ci WITH (NOLOCK)
				ON ci.ClaimInfoID = cl.ClaimInfoID
			INNER JOIN #CodeGroup1 cg
				ON cg.ECTCode = csp.RevenueCode
			INNER JOIN LkupCodetype lku
				--ON lku.CodeTypeID = CG.ECTHedisCodeTypeID
				ON lku.CodeTypeCode = cg.ECTHedisCodeTypeCode
			WHERE cg.ECTHedisCodeTypeCode IN ('UB-Revenue')
				--AND lku.CodeTypeCode = cg.ECTHedisCodeTypeCode
			
			UNION 
			
			SELECT DISTINCT CI.ClaimInfoId
				,cg.CodeGroupingID
			FROM ClaimProcedure cl WITH (NOLOCK)
			INNER JOIN CodeSetICDProcedure csp WITH (NOLOCK)
				ON cl.ProcedureCodeID = csp.ProcedureCodeID
			INNER JOIN ClaimInfo ci WITH (NOLOCK)
				ON ci.ClaimInfoID = cl.ClaimInfoID
			INNER JOIN #CodeGroup1 cg
				ON cg.ECTCode = csp.ProcedureCode
			INNER JOIN LkupCodetype lku
				--ON lku.CodeTypeID = CG.ECTHedisCodeTypeID
				ON lku.CodeTypeCode = cg.ECTHedisCodeTypeCode
			WHERE cg.ECTHedisCodeTypeCode IN ('ICD-9-CM-Proc'
					,'ICD-10-CM-Proc')
				--AND lku.CodeTypeCode = cg.ECTHedisCodeTypeCode
				
			UNION
			
			SELECT DISTINCT CI.ClaimInfoId
				,cg.CodeGroupingID
			FROM ClaimLineDiagnosis cld WITH (NOLOCK)
			INNER JOIN ClaimLine cl WITH (NOLOCK)
				ON cld.ClaimLineID = cl.ClaimLineID
			INNER JOIN ClaimInfo ci WITH (NOLOCK)
				ON ci.ClaimInfoID = cl.ClaimInfoID
			INNER JOIN CodeSetICDDiagnosis csi WITH (NOLOCK)
				ON csi.DiagnosisCodeID = cld.DiagnosisCodeID
			INNER JOIN #CodeGroup1 cg
				ON cg.ECTCode = csi.DiagnosisCode
			INNER JOIN LkupCodetype lku
				--ON lku.CodeTypeID = CG.ECTHedisCodeTypeID
				ON lku.CodeTypeCode = cg.ECTHedisCodeTypeCode
			WHERE cg.ECTHedisCodeTypeCode IN ('ICD-9-CM-Diag'
					,'ICD-10-CM-Diag')	
			
			UNION
			
			SELECT DISTINCT CI.ClaimInfoId
				,cg.CodeGroupingID
			FROM ClaimLine cl WITH (NOLOCK)
			INNER JOIN ClaimInfo ci WITH (NOLOCK)
				ON ci.ClaimInfoID = cl.ClaimInfoID
			INNER JOIN CodeSetCMSPlaceOfService csi WITH (NOLOCK)
				ON csi.PlaceOfServiceCodeID = cl.PlaceOfServiceCodeID
			INNER JOIN #CodeGroup1 cg
				ON cg.ECTCode = csi.PlaceOfServiceCode
			INNER JOIN LkupCodetype lku
				--ON lku.CodeTypeID = CG.ECTHedisCodeTypeID
				ON lku.CodeTypeCode = cg.ECTHedisCodeTypeCode
			WHERE cg.ECTHedisCodeTypeCode IN ('CMS_POS')			
			
			UNION
			
			SELECT DISTINCT CI.ClaimInfoId
				,cg.CodeGroupingID
			FROM ClaimInfo ci WITH (NOLOCK)
			INNER JOIN CodeSetTypeOfBill csi WITH (NOLOCK)
				ON csi.TypeOfBillCodeID = ci.TypeOfBillCodeID
			INNER JOIN #CodeGroup1 cg
				ON cg.ECTCode = csi.TypeOfBillCode
			INNER JOIN LkupCodetype lku
				--ON lku.CodeTypeID = CG.ECTHedisCodeTypeID
				ON lku.CodeTypeCode = cg.ECTHedisCodeTypeCode
			WHERE cg.ECTHedisCodeTypeCode IN ('TOB')			
		)	
			
	SELECT * 
	INTO #CURClaimH
	FROM CURClaimH		
--------------------------------------------------------------------------------------------------------------------
	
	TRUNCATE TABLE ClaimCodeGroup
	
	INSERT INTO ClaimCodeGroup
	SELECT DISTINCT pm.ClaimInfoId
		,cg.CodeGroupingID
	FROM #cteProc pm
	INNER JOIN CodeGroupingDetailInternal cg
		ON cg.CodeGroupingCodeID = pm.CodeID
		AND CG.CodeGroupingCodeTypeID = PM.CodeTypeID
	INNER JOIN #CodeGroup cgg
		ON cgg.CodeGroupingID = cg.CodeGroupingID
	INNER JOIN LkUpCodeType lkp
		ON lkp.CodeTypeID = cg.CodeGroupingCodeTypeID
	WHERE lkp.CodeTypeCode IN (
			'CPT'
			,'HCPCS'
			,'ICD-9-CM-Proc'
			,'ICD-10-CM-Proc'
			,'UB-Revenue'
			,'CPT-CAT-II'
			,'CPT-CAT-III'
			,'CPT_HCPCS_Modifier'
			,'CMS_POS'
			,'TOB'
			,'ICD-9-CM-Diag'
			,'ICD-10-CM-Diag'
			)
		AND cg.StatusCode = 'A'
		AND pm.CodeTypeID = lkp.CodeTypeID
	UNION
	SELECT DISTINCT TH.ClaimInfoId ,
		TH.CodeGroupingID	
	FROM #CURClaimH TH
		

	TRUNCATE TABLE RxClaimCodeGroup
	
	INSERT INTO RxClaimCodeGroup
	(
	    RxClaimId ,
	    CodeGroupingId
	)
	SELECT DISTINCT
		RC.RxClaimId ,
		CGDI.CodeGroupingID
	FROM RxClaim RC
	INNER JOIN CodeGroupingDetailInternal CGDI
	ON RC.DrugCodeId = CGDI.CodeGroupingCodeID
	INNER JOIN LkUpCodeType LCT
	ON LCT.CodeTypeID = CGDI.CodeGroupingCodeTypeID
	WHERE LCT.CodeTypeCode = 'NDC'
	AND CGDI.StatusCode = 'A' 
	UNION
	SELECT DISTINCT TH.RxClaimId ,
		TH.CodeGroupingID
	FROM #medicationH TH

	
	TRUNCATE TABLE LabCodeGroup
	
	INSERT INTO LabCodeGroup
	(
	    PatientMeasureId ,
	    CodeGroupingId
	)
	SELECT DISTINCT
		PM.PatientMeasureId ,
		CGDI.CodeGroupingID
	FROM PatientMeasure PM 
	INNER JOIN CodeGroupingDetailInternal CGDI
	ON PM.LOINCCodeID = CGDI.CodeGroupingCodeID
	INNER JOIN LkUpCodeType LCT
	ON LCT.CodeTypeID = CGDI.CodeGroupingCodeTypeID
	WHERE LCT.CodeTypeCode = 'LOINC'
	AND CGDI.StatusCode = 'A' 
	UNION
	SELECT DISTINCT TH.PatientMeasureID ,
		TH.CodeGroupingID
	FROM #LabH TH
	
			
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH
