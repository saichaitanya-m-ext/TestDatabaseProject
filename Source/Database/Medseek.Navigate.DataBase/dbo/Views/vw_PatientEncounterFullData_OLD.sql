



CREATE VIEW [dbo].[vw_PatientEncounterFullData_OLD]
AS
	SELECT DISTINCT cg.CodeGroupingID
		,ppc.PatientID
		,cg.CodeGroupingName
		--,ppc.ClaimInfoId
		,ppc.DateOfService DateOfService
	FROM PatientProcedureCode ppc
	INNER JOIN PatientProcedureCodeGroup ppcg
		ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
	INNER JOIN CodeGrouping cg
		ON cg.CodeGroupingID = ppcg.CodeGroupingID
	INNER JOIN CodeTypeGroupers ctg
		ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	INNER JOIN CodeGroupingType cgt
		ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID
	WHERE ppc.StatusCode = 'A'
		AND ppcg.StatusCode = 'A'
		--AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))
		AND cgt.CodeGroupType = 'Utilization Groupers'
		AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'
		

	
	UNION
	
	SELECT DISTINCT cg.CodeGroupingID
		,ppc.PatientID
		,cg.CodeGroupingName
		--,ppc.ClaimInfoId
		,ppc.DateOfService DateOfService
	FROM PatientOtherCode ppc
	INNER JOIN PatientOtherCodeGroup ppcg
		ON ppc.PatientOtherCodeID = ppcg.PatientOtherCodeID
	INNER JOIN CodeGrouping cg
		ON cg.CodeGroupingID = ppcg.CodeGroupingID
	INNER JOIN CodeTypeGroupers ctg
		ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	INNER JOIN CodeGroupingType cgt
		ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID
	WHERE ppc.StatusCode = 'A'
		AND ppcg.StatusCode = 'A'
		--AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))
		AND cgt.CodeGroupType = 'Utilization Groupers'
		AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'


