



CREATE VIEW [dbo].[vw_PatientEncounterFullData]
AS
	SELECT DISTINCT cg.CodeGroupingID
		,CI.PatientID
		,cg.CodeGroupingName
		--,ppc.ClaimInfoId
		,CI.DateOfAdmit AS DateOfService
	FROM ClaimCodeGroup CCG
	INNER JOIN ClaimInfo CI
		ON CI.ClaimInfoId = CCG.ClaimInfoID 
	INNER JOIN CodeGrouping cg
		ON cg.CodeGroupingID = CCG.CodeGroupingID
	INNER JOIN CodeTypeGroupers ctg
		ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	INNER JOIN CodeGroupingType cgt
		ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID
	WHERE cgt.CodeGroupType = 'Utilization Groupers'
		AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'
		
