




CREATE VIEW [dbo].[vw_PatientCodeGroupAmt_OLD]
AS
SELECT DISTINCT cg.CodeGroupingID
	,ppc.PatientID
	,cg.CodeGroupingName
	,ppc.DateOfService DateOfService
	,(
		SELECT SUM(NetPaidAmount)
		FROM ClaimInfo ci WITH (NOLOCK)
		WHERE ci.DateOfAdmit = ppc.DateOfService
			AND ci.PatientID = ppc.PatientID
		) Amt
FROM PatientProcedureCode ppc WITH (NOLOCK)
INNER JOIN PatientProcedureCodeGroup ppcg WITH (NOLOCK)
	ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
INNER JOIN CodeGrouping cg WITH (NOLOCK)
	ON cg.CodeGroupingID = ppcg.CodeGroupingID
WHERE ppc.StatusCode = 'A'
	AND ppcg.StatusCode = 'A'
	AND cg.StatusCode = 'A'

UNION

SELECT DISTINCT cg.CodeGroupingID
	,pdc.PatientID
	,cg.CodeGroupingName
	,pdc.DateOfService DateOfService
	,(
		SELECT SUM(NetPaidAmount)
		FROM ClaimInfo ci WITH (NOLOCK)
		WHERE ci.DateOfAdmit = pdc.DateOfService
			AND ci.PatientID = pdc.PatientID
		) Amt
FROM PatientDiagnosisCode pdc WITH (NOLOCK)
INNER JOIN PatientDiagnosisCodeGroup pdcg WITH (NOLOCK)
	ON pdcg.PatientDiagnosisCodeID = pdc.PatientDiagnosisCodeID
INNER JOIN CodeGrouping cg WITH (NOLOCK)
	ON cg.CodeGroupingID = pdcg.CodeGroupingID
WHERE pdc.StatusCode = 'A'
	AND pdcg.StatusCode = 'A'
	AND cg.StatusCode = 'A'

UNION

SELECT DISTINCT cg.CodeGroupingID
	,rc.PatientID
	,cg.CodeGroupingName
	,rc.DateFilled DateOfService
	,(
		SELECT SUM(rcc.PaidAmount)
		FROM RxClaimCost rcc WITH (NOLOCK)
		INNER JOIN RxClaim rc22 WITH (NOLOCK)
			ON rc22.RxClaimId = rcc.RxClaimId
		WHERE rc.PatientID = rc22.PatientID
			AND rc.DateFilled = rc22.DateFilled
		) Amt
FROM RxClaim rc WITH (NOLOCK)
INNER JOIN PatientMedicationCodeGroup pmcg WITH (NOLOCK)
	ON pmcg.RxClaimId = rc.RxClaimId
INNER JOIN CodeGrouping cg WITH (NOLOCK)
	ON cg.CodeGroupingID = pmcg.CodeGroupingID
WHERE pmcg.StatusCode = 'A'
	AND rc.StatusCode = 'A'
	AND cg.StatusCode = 'A'

UNION

SELECT DISTINCT cg.CodeGroupingID
	,ppc.PatientID
	,cg.CodeGroupingName
	,ppc.DateOfService DateOfService
	,(
		SELECT SUM(NetPaidAmount)
		FROM ClaimInfo ci WITH (NOLOCK)
		WHERE ci.DateOfAdmit = ppc.DateOfService
			AND ci.PatientID = ppc.PatientID
		) Amt
FROM PatientOtherCode ppc WITH (NOLOCK)
INNER JOIN PatientOtherCodeGroup ppcg WITH (NOLOCK)
	ON ppc.PatientOtherCodeID = ppcg.PatientOtherCodeID
INNER JOIN CodeGrouping cg WITH (NOLOCK)
	ON cg.CodeGroupingID = ppcg.CodeGroupingID
WHERE ppc.StatusCode = 'A'
	AND ppcg.StatusCode = 'A'
	AND ppc.StatusCode = 'A'

UNION

SELECT DISTINCT cg.CodeGroupingID
	,pm.PatientID
	,cg.CodeGroupingName
	,pm.DateTaken DateOfService
	,0 Amt
FROM PatientMeasure pm
INNER JOIN PatientLabGroup plg
	ON plg.PatientMeasureID = pm.PatientMeasureID
INNER JOIN CodeGrouping cg
	ON cg.CodeGroupingID = plg.CodeGroupingID
WHERE plg.StatusCode = 'A'
	AND pm.StatusCode = 'A'
	AND cg.StatusCode = 'A'


