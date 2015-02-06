




CREATE VIEW [dbo].[vw_PatientCodeGroupAmt]
AS
SELECT DISTINCT CCG.CodeGroupingID
	,CI.PatientID
	,CG.CodeGroupingName
	,CI.DateOfAdmit AS DateOfService
	,(
		SELECT SUM(CI1.NetPaidAmount)
		FROM ClaimInfo CI1 WITH (NOLOCK)
		WHERE CI1.DateOfAdmit = CI.DateOfAdmit
			AND CI1.PatientID = CI.PatientID
		) Amt
FROM ClaimCodeGroup CCG
INNER JOIN ClaimInfo CI
ON CI.ClaimInfoId = CCG.ClaimInfoID
INNER JOIN CodeGrouping CG
ON CG.CodeGroupingID = CCG.CodeGroupingID
WHERE CG.StatusCode = 'A'
AND CI.StatusCode = 'A'

UNION

SELECT DISTINCT CG.CodeGroupingID
	,RC.PatientID
	,CG.CodeGroupingName
	,RC.DateFilled DateOfService
	,(
		SELECT SUM(rcc.PaidAmount)
		FROM RxClaimCost rcc WITH (NOLOCK)
		INNER JOIN RxClaim rc22 WITH (NOLOCK)
			ON rc22.RxClaimId = rcc.RxClaimId
		WHERE RC.PatientID = rc22.PatientID
			AND RC.DateFilled = rc22.DateFilled
		) Amt
FROM RxClaimCodeGroup RCCG
INNER JOIN RxClaim RC
ON RC.RxClaimId = RCCG.RxClaimId 
INNER JOIN CodeGrouping CG
ON CG.CodeGroupingID = RCCG.CodeGroupingID
WHERE CG.StatusCode = 'A'
AND RC.StatusCode = 'A'

UNION

SELECT DISTINCT cg.CodeGroupingID
	,pm.PatientID
	,cg.CodeGroupingName
	,pm.DateTaken DateOfService
	,0 Amt
FROM LabCodeGroup LCG
INNER JOIN PatientMeasure PM
ON PM.PatientMeasureID = LCG.PatientMeasureId
INNER JOIN CodeGrouping CG
ON CG.CodeGroupingID = LCG.CodeGroupingID
WHERE CG.StatusCode = 'A'
AND PM.StatusCode = 'A'


