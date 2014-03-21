
CREATE VIEW [dbo].[vw_PatientCodeGroup_OLD]
AS
SELECT DISTINCT cg.CodeGroupingID
	,ppc.PatientID
	,cg.CodeGroupingName
	,ppc.DateOfService DateOfService
FROM PatientProcedureCode ppc
INNER JOIN PatientProcedureCodeGroup ppcg
	ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
INNER JOIN CodeGrouping cg
	ON cg.CodeGroupingID = ppcg.CodeGroupingID
WHERE ppc.StatusCode = 'A'
	AND ppcg.StatusCode = 'A'
	AND cg.StatusCode = 'A'

UNION

SELECT DISTINCT cg.CodeGroupingID
	,pdc.PatientID
	,cg.CodeGroupingName
	,pdc.DateOfService DateOfService
FROM PatientDiagnosisCode pdc
INNER JOIN PatientDiagnosisCodeGroup pdcg
	ON pdcg.PatientDiagnosisCodeID = pdc.PatientDiagnosisCodeID
INNER JOIN CodeGrouping cg
	ON cg.CodeGroupingID = pdcg.CodeGroupingID
WHERE pdc.StatusCode = 'A'
	AND pdcg.StatusCode = 'A'
	AND cg.StatusCode = 'A'

UNION

SELECT DISTINCT cg.CodeGroupingID
	,rc.PatientID
	,cg.CodeGroupingName
	,rc.DateFilled DateOfService
FROM RxClaim rc
INNER JOIN PatientMedicationCodeGroup pmcg
	ON pmcg.RxClaimId = rc.RxClaimId
INNER JOIN CodeGrouping cg
	ON cg.CodeGroupingID = pmcg.CodeGroupingID
WHERE pmcg.StatusCode = 'A'
	AND rc.StatusCode = 'A'
	AND cg.StatusCode = 'A'

UNION

SELECT DISTINCT cg.CodeGroupingID
	,ppc.PatientID
	,cg.CodeGroupingName
	,ppc.DateOfService DateOfService
FROM PatientOtherCode ppc
INNER JOIN PatientOtherCodeGroup ppcg
	ON ppc.PatientOtherCodeID = ppcg.PatientOtherCodeID
INNER JOIN CodeGrouping cg
	ON cg.CodeGroupingID = ppcg.CodeGroupingID
WHERE ppc.StatusCode = 'A'
	AND ppcg.StatusCode = 'A'
	AND ppc.StatusCode = 'A'

UNION

SELECT DISTINCT cg.CodeGroupingID
	,pm.PatientID
	,cg.CodeGroupingName
	,pm.DateTaken DateOfService
FROM PatientMeasure pm
INNER JOIN PatientLabGroup plg
	ON plg.PatientMeasureID = pm.PatientMeasureID
INNER JOIN CodeGrouping cg
	ON cg.CodeGroupingID = plg.CodeGroupingID
WHERE plg.StatusCode = 'A'
	AND pm.StatusCode = 'A'
	AND cg.StatusCode = 'A'

