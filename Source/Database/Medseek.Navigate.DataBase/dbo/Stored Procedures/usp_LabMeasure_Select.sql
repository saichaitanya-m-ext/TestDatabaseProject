
--[usp_LabMeasure_Select] 64,0,223,0,0
CREATE PROCEDURE [dbo].[usp_LabMeasure_Select] (
	@i_AppUserId KEYID
	,@i_LabMeasureId KEYID = NULL
	,@i_MeasureID KEYID = NULL
	,@i_ProgramId KEYID = NULL
	,@i_PatientUserID KEYID = NULL
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

	SELECT LabMeasure.LabMeasureId
		,LabMeasure.MeasureId
		,LabMeasure.IsGoodControl
		,LabMeasure.Operator1forGoodControl
		,LabMeasure.Operator1Value1forGoodControl
		,LabMeasure.Operator1Value2forGoodControl
		,LabMeasure.Operator2forGoodControl
		,LabMeasure.Operator2Value1forGoodControl
		,LabMeasure.Operator2Value2forGoodControl
		,LabMeasure.TextValueForGoodControl
		,CASE 
			WHEN Measure.IsTextValueForControls = 0
				THEN COALESCE((ISNULL(LabMeasure.Operator1forGoodControl, '') + ' ' + ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)), '') + ' ' + ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)), '') + ISNULL(LabMeasure.Operator2forGoodControl, '') + ' ' + ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)), '') + ' ' + ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)), '')), '')
			ELSE LabMeasure.TextValueForGoodControl
			END AS GoodRange
		,LabMeasure.IsFairControl
		,LabMeasure.Operator1forFairControl
		,LabMeasure.Operator1Value1forFairControl
		,LabMeasure.Operator1Value2forFairControl
		,LabMeasure.Operator2forFairControl
		,LabMeasure.Operator2Value1forFairControl
		,LabMeasure.Operator2Value2forFairControl
		,LabMeasure.TextValueForFairControl
		,CASE 
			WHEN Measure.IsTextValueForControls = 0
				THEN COALESCE((ISNULL(LabMeasure.Operator1forFairControl, '') + ' ' + ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)), '') + ' ' + ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)), '') + ISNULL(LabMeasure.Operator2forFairControl, '') + ' ' + ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)), '') + ' ' + ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)), '')), '')
			ELSE LabMeasure.TextValueForFairControl
			END AS FairRange
		,LabMeasure.IsPoorControl
		,LabMeasure.Operator1forPoorControl
		,LabMeasure.Operator1Value1forPoorControl
		,LabMeasure.Operator1Value2forPoorControl
		,LabMeasure.Operator2forPoorControl
		,LabMeasure.Operator2Value1forPoorControl
		,LabMeasure.Operator2Value2forPoorControl
		,LabMeasure.TextValueForPoorControl
		,CASE 
			WHEN Measure.IsTextValueForControls = 0
				THEN COALESCE((ISNULL(LabMeasure.Operator1forPoorControl, '') + ' ' + ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)), '') + ' ' + ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)), '') + ISNULL(LabMeasure.Operator2forPoorControl, '') + ' ' + ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)), '') + ' ' + ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)), '')), '')
			ELSE LabMeasure.TextValueForPoorControl
			END AS PoorRange
		,LabMeasure.MeasureUOMId
		,LabMeasure.ProgramId
		,LabMeasure.PatientUserID
		,LabMeasure.CreatedByUserId
		,LabMeasure.CreatedDate
		,LabMeasure.LastModifiedByUserId
		,LabMeasure.LastModifiedDate
		,Measure.NAME AS MeasureName
		,Program.ProgramName
		,CASE Measure.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			END AS StatusDescription
		,MeasureUOM.UOMText
		,MeasureUOM.UOMDescription
		,Measure.IsTextValueForControls
		,CASE 
			WHEN LabMeasure.ProgramId IS NULL
				AND LabMeasure.PatientUserID IS NULL
				AND LabMeasure.StartDate IS NULL
				THEN CONVERT(VARCHAR, Measure.CreatedDate, 101)
			WHEN LabMeasure.ProgramId IS NOT NULL
				AND LabMeasure.PatientUserID IS NULL
				AND LabMeasure.StartDate IS NULL
				THEN CONVERT(VARCHAR, Program.CreatedDate, 101)
			ELSE CONVERT(VARCHAR, StartDate, 101)
			END AS StartDate
		,CONVERT(VARCHAR, EndDate, 101) AS EndDate
		,ReminderDaysBeforeEnddate
		--,'' CPTList
		,STUFF((
				SELECT ', ' + csp.ProcedureCode + '-' + csp.ProcedureName
				FROM ProcedureMeasure pm
				INNER JOIN CodeSetProcedure csp ON csp.ProcedureCodeID = pm.ProcedureId
				INNER JOIN LabMeasure lm ON lm.MeasureId = pm.MeasureId
				WHERE lm.LabMeasureId = LabMeasure.LabMeasureId
					AND pm.StatusCode = 'A'
				FOR XML PATH('')
				), 1, 2, '') AS CPTList
	FROM LabMeasure WITH (NOLOCK)
	INNER JOIN Measure WITH (NOLOCK) ON Measure.MeasureId = LabMeasure.MeasureId
	LEFT OUTER JOIN Program WITH (NOLOCK) ON Program.ProgramId = LabMeasure.ProgramId
	LEFT OUTER JOIN MeasureUOM WITH (NOLOCK) ON MeasureUOM.MeasureUOMId = Measure.StandardMeasureUOMId
	WHERE (
			LabMeasure.LabMeasureId = @i_LabMeasureId
			OR @i_LabMeasureId IS NULL
			)
		AND (
			(
				LabMeasure.MeasureId = @i_MeasureID
				AND @i_MeasureID IS NOT NULL
				AND LabMeasure.ProgramId IS NULL
				AND LabMeasure.PatientUserID IS NULL
				)
			OR @i_MeasureID IS NULL
			)
		AND (
			@i_ProgramId IS NULL
			OR (
				@i_ProgramId IS NOT NULL
				AND LabMeasure.ProgramId = @i_ProgramId
				AND LabMeasure.ProgramId IS NOT NULL
				AND LabMeasure.PatientUserID IS NULL
				)
			)
		AND Measure.StatusCode = 'A'
		AND (
			@i_PatientUserID IS NULL
			OR (
				@i_PatientUserID IS NOT NULL
				AND LabMeasure.PatientUserID = @i_PatientUserID
				AND LabMeasure.PatientUserID IS NOT NULL
				AND LabMeasure.ProgramId IS NULL
				)
			)

	IF @i_LabMeasureId IS NOT NULL
		AND @i_LabMeasureId <> 0
	BEGIN
		SELECT csp.ProcedureCodeID AS ProcedureId
			,csp.ProcedureCode + '-' + csp.ProcedureName ProcedureCode
		FROM ProcedureMeasure pm
		INNER JOIN CodeSetProcedure csp ON csp.ProcedureCodeID = pm.ProcedureId
		INNER JOIN LabMeasure lm ON lm.MeasureId = pm.MeasureId
		WHERE lm.LabMeasureId = @i_LabMeasureId
			AND pm.StatusCode = 'A'

		SELECT CONVERT(VARCHAR, cl.LoincCodeId) LoincCodeId
			,cl.LoincCode + '-' + cl.ShortDescription LoincCode
		FROM LoinCodeMeasure lcm WITH (NOLOCK)
		INNER JOIN CodeSetLOINC cl WITH (NOLOCK) ON cl.LoincCodeId = lcm.LoinCodeId
		INNER JOIN LabMeasure lm WITH (NOLOCK) ON lm.MeasureId = lcm.MeasureId
		WHERE lm.LabMeasureId = @i_LabMeasureId
			AND lcm.StatusCode = 'A'
	END

	IF @i_MeasureId IS NOT NULL
		AND @i_MeasureId <> 0
	BEGIN
		SELECT csp.ProcedureCodeID AS ProcedureId
			,csp.ProcedureCode + '-' + csp.ProcedureName ProcedureCode
		FROM ProcedureMeasure pm WITH (NOLOCK)
		INNER JOIN CodeSetProcedure csp WITH (NOLOCK) ON csp.ProcedureCodeID = pm.ProcedureId
		WHERE pm.MeasureId = @i_MeasureId
			AND pm.StatusCode = 'A'

		SELECT CONVERT(VARCHAR, cl.LoincCodeId) LoincCodeId
			,cl.LoincCode + '-' + cl.ShortDescription LoincCode
		FROM LoinCodeMeasure lcm WITH (NOLOCK)
		INNER JOIN CodeSetLOINC cl WITH (NOLOCK) ON cl.LoincCodeId = lcm.LoinCodeId
		WHERE lcm.MeasureId = @i_MeasureId
			AND lcm.StatusCode = 'A'
	END
END TRY

--------------------------------------------------------           
BEGIN CATCH
	-- Handle exception          
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LabMeasure_Select] TO [FE_rohit.r-ext]
    AS [dbo];

