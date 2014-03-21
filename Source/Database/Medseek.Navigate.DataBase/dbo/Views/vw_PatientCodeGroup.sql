
CREATE VIEW [dbo].[vw_PatientCodeGroup]
AS
SELECT DISTINCT CCG.CodeGroupingID
	,CI.PatientID
	,CG.CodeGroupingName
	,CI.DateOfAdmit AS DateOfService
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
FROM LabCodeGroup LCG
INNER JOIN PatientMeasure PM
ON PM.PatientMeasureID = LCG.PatientMeasureId
INNER JOIN CodeGrouping CG
ON CG.CodeGroupingID = LCG.CodeGroupingID
WHERE CG.StatusCode = 'A'
AND PM.StatusCode = 'A'

