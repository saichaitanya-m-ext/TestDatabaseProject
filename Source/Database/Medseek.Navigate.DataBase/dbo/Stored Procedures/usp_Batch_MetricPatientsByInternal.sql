/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_MetricPatientsByInternal]  
Description   : This proc is used to fetch the Nr OR Utilization patients
Created By    : Rathnam  
Created Date  : 08-AUG-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_MetricPatientsByInternal] --1,@v_DateKey
	(
	@i_AppUserId KEYID
	,@v_DateKey VARCHAR(8)
	,@i_MetricID INT
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
	END;

	WITH nrCTE
	AS (
		/*	
	SELECT DISTINCT pdc.MetricID
		,pcg.PatientID
		,1 [Count]
		,ISNULL(nr.IsIndicator,0) IsIndicator
		,@i_AppUserId CreatedByUserId
		,@v_DateKey  
	FROM vw_PatientCodeGroup pcg WITH(NOLOCK)
	INNER JOIN PopulationDefinitionPatients pdp WITH(NOLOCK)
		ON pdp.PatientID = pcg.PatientID
	INNER JOIN PopulationDefinitionPatientAnchorDate pdpad WITH(NOLOCK)
		ON pdpad.PopulationDefinitionPatientID = pdp.PopulationDefinitionPatientID
	INNER JOIN PopulationDefinitionConfiguration pdc WITH(NOLOCK)
		ON pdc.CodeGroupingID = pcg.CodeGroupingID
	INNER JOIN Metric m WITH(NOLOCK)
		ON m.MetricId = pdc.MetricID
			AND m.DenominatorID = pdp.PopulationDefinitionID
	INNER JOIN MetricReportConfiguration mrc WITH(NOLOCK)
		ON mrc.MetricId = m.MetricId
	INNER JOIN PopulationDefinition nr WITH(NOLOCK)
		ON nr.PopulationDefinitionID = m.NumeratorID
	INNER JOIN PopulationMetricsReports pmr WITH(NOLOCK)
		ON pmr.PopulationMetricsReportsId = mrc.ReportID
	WHERE pdc.MetricID IS NOT NULL
		AND pdc.CodeGroupingID IS NOT NULL
		AND pcg.DateOfService > = DATEADD(DAY, - pdc.TimeInDays, pdpad.OutPutAnchorDate)
		AND pcg.DateOfService < = pdpad.OutPutAnchorDate
		AND pdpad.DateKey = mrc.Datekey
		AND pdpad.DateKey = @v_DateKey
		AND m.DenominatorType <> 'M'
		AND nr.NumeratorType = 'C'
		AND pmr.ReportName <> 'Condition Prevalence'
		AND (m.MetricId = @i_MetricID)
	
	UNION ALL
	*/
		SELECT pdc.MetricID
			,pcg.PatientID
			,CASE 
				WHEN ISNULL(nr.IsIndicator, 0) = 1
					THEN 1
				ELSE COUNT(DISTINCT pcg.DateOfService)
				END [Count]
			,ISNULL(nr.IsIndicator, 0) IsIndicator
			,@i_AppUserId CreatedByUserId
			,@v_DateKey DateKey
		FROM vw_PatientCodeGroup pcg WITH (NOLOCK)
		INNER JOIN PopulationDefinitionPatients pdp WITH (NOLOCK)
			ON pdp.PatientID = pcg.PatientID
		INNER JOIN PopulationDefinitionPatientAnchorDate pdpad WITH (NOLOCK)
			ON pdpad.PopulationDefinitionPatientID = pdp.PopulationDefinitionPatientID
		INNER JOIN PopulationDefinitionConfiguration pdc WITH (NOLOCK)
			ON pdc.CodeGroupingID = pcg.CodeGroupingID
		INNER JOIN Metric m WITH (NOLOCK)
			ON m.MetricId = pdc.MetricID
				AND m.DenominatorID = pdp.PopulationDefinitionID
		--INNER JOIN ReportFrequencyConfiguration rfc 
		--	ON rfc.MetricId = m.MetricId
		INNER JOIN PopulationDefinition nr WITH (NOLOCK)
			ON nr.PopulationDefinitionID = m.NumeratorID
		WHERE pdc.MetricID IS NOT NULL
			AND pdc.CodeGroupingID IS NOT NULL
			AND pcg.DateOfService > = DATEADD(DAY, - pdc.TimeInDays, pdpad.OutPutAnchorDate)
			AND pcg.DateOfService < = pdpad.OutPutAnchorDate
			--AND pdpad.DateKey = rfc.Datekey
			AND pdpad.DateKey = @v_DateKey
			AND m.DenominatorType <> 'M'
			AND nr.NumeratorType = 'C'
			AND (m.MetricId = @i_MetricID)
		GROUP BY pdc.MetricID
			,pcg.PatientID
			,ISNULL(nr.IsIndicator, 0)
		
		UNION ALL
		
		SELECT m.MetricID
			,pcg.PatientID
			,COUNT(DISTINCT pcg.DrugCodeId)
			,0
			,@i_AppUserId
			,@v_DateKey
		FROM RxClaim pcg WITH (NOLOCK)
		INNER JOIN PopulationDefinitionPatients pdp WITH (NOLOCK)
			ON pdp.PatientID = pcg.PatientID
		INNER JOIN PopulationDefinitionPatientAnchorDate pdpad WITH (NOLOCK)
			ON pdpad.PopulationDefinitionPatientID = pdp.PopulationDefinitionPatientID
		INNER JOIN Metric m WITH (NOLOCK)
			ON m.DenominatorID = pdp.PopulationDefinitionID
		INNER JOIN PopulationDefinitionConfiguration pdc WITH (NOLOCK)
			ON pdc.MetricID = m.MetricID
		--INNER JOIN MetricReportConfiguration mrc WITH(NOLOCK)
		--	ON mrc.MetricId = m.MetricId
		INNER JOIN PopulationDefinition nr WITH (NOLOCK)
			ON nr.PopulationDefinitionID = m.NumeratorID
		WHERE pdc.MetricID IS NOT NULL
			AND pdc.CodeGroupingID IS NULL
			AND pcg.DateFilled > = DATEADD(DAY, - pdc.TimeInDays, pdpad.OutPutAnchorDate)
			AND pcg.DateFilled < = pdpad.OutPutAnchorDate
			--AND pdpad.DateKey = mrc.Datekey
			AND pdpad.DateKey = @v_DateKey
			AND m.DenominatorType <> 'M'
			AND nr.NumeratorType = 'C'
			AND nr.PopulationDefinitionName = 'Unique NDC Count'
			AND (m.MetricId = @i_MetricID)
		GROUP BY m.MetricID
			,pcg.PatientID
		)
	SELECT *
	INTO #y
	FROM nrCTE nc

	MERGE NRPatientCount AS T
	USING (
		SELECT nc.MetricID AS MetricID
			,nc.PatientID
			,nc.[Count] Cnt
			,IsIndicator
			,DateKey
		FROM #y nc
		) AS S
		ON (
				t.MetricID = s.MetricID
				AND t.PatientID = s.PatientID
				AND t.DateKey = s.DateKey
				)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				MetricID
				,PatientID
				,[COUNT]
				,IsIndicator
				,CreatedByUserId
				,DateKey
				)
			VALUES (
				S.MetricID
				,s.PatientID
				,s.Cnt
				,s.IsIndicator
				,1
				,s.DateKey
				)
	WHEN MATCHED
		THEN
			UPDATE
			SET T.Count = S.Cnt
				,t.IsIndicator = s.IsIndicator
	WHEN NOT MATCHED BY SOURCE
		AND EXISTS (
			SELECT 1
			FROM #y c
			WHERE t.MetricID = c.MetricID
				AND t.DateKey = c.DateKey
			)
		THEN
			DELETE;

	DECLARE @i_Cnt INT

	SELECT @i_Cnt = COUNT(*)
	FROM #Y

	IF @i_Cnt = 0
	BEGIN
		DELETE
		FROM NRPatientCount
		WHERE MetricID = @i_MetricID
			AND DateKey = @v_DateKey
	END;

	WITH valueCTE
	AS (
		SELECT DISTINCT pdc.MetricID
			,pcg.PatientID
			,ISNULL(nr.IsIndicator, 0) IsIndicator
			,@i_AppUserId CreatedByUserId
			,@v_DateKey DateKey
			,CASE 
				WHEN nr.IsIndicator = 1
					THEN 1
				ELSE pm.MeasureValueNumeric
				END Value
			,CASE 
				WHEN nr.IsIndicator = 1
					THEN pdpad.OutPutAnchorDate
				ELSE pm.DateTaken
				END ValueDate
		FROM vw_PatientCodeGroup pcg WITH (NOLOCK)
		INNER JOIN PopulationDefinitionPatients pdp WITH (NOLOCK)
			ON pdp.PatientID = pcg.PatientID
		INNER JOIN PopulationDefinitionPatientAnchorDate pdpad WITH (NOLOCK)
			ON pdpad.PopulationDefinitionPatientID = pdp.PopulationDefinitionPatientID
		INNER JOIN PatientMeasure pm
			ON pm.PatientID = pdp.PatientID
		INNER JOIN PopulationDefinitionConfiguration pdc WITH (NOLOCK)
			ON pdc.CodeGroupingID = pcg.CodeGroupingID
		INNER JOIN Metric m WITH (NOLOCK)
			ON m.MetricId = pdc.MetricID
				AND m.DenominatorID = pdp.PopulationDefinitionID
		--INNER JOIN MetricReportConfiguration mrc WITH(NOLOCK)
		--	ON mrc.MetricId = m.MetricId
		INNER JOIN PopulationDefinition nr WITH (NOLOCK)
			ON nr.PopulationDefinitionID = m.NumeratorID
		--INNER JOIN PopulationMetricsReports pmr WITH(NOLOCK)
		--	ON pmr.PopulationMetricsReportsId = mrc.ReportID
		WHERE pdc.MetricID IS NOT NULL
			AND pdc.CodeGroupingID IS NOT NULL
			AND pcg.DateOfService > = DATEADD(DAY, - pdc.TimeInDays, pdpad.OutPutAnchorDate)
			AND pcg.DateOfService < = pdpad.OutPutAnchorDate
			AND pm.DateTaken > = DATEADD(DAY, - pdc.TimeInDays, pdpad.OutPutAnchorDate)
			AND pm.DateTaken < = pdpad.OutPutAnchorDate
			--AND pdpad.DateKey = mrc.Datekey
			AND pdpad.DateKey = @v_DateKey
			AND m.DenominatorType <> 'M'
			AND nr.NumeratorType = 'V'
			--AND pmr.ReportName <> 'Condition Prevalence'
			AND (m.MetricId = @i_MetricID)
			/*
	UNION ALL
	
	SELECT DISTINCT 
		 pdc.MetricID
		,pcg.PatientID
		,0
		,@i_AppUserId
		,@v_DateKey
		,pm.MeasureValueNumeric
		,pm.DateTaken
	FROM vw_PatientCodeGroup pcg WITH(NOLOCK)
	INNER JOIN PopulationDefinitionPatients pdp WITH(NOLOCK) 
		ON pdp.PatientID = pcg.PatientID
	INNER JOIN PopulationDefinitionPatientAnchorDate pdpad WITH(NOLOCK)
		ON pdpad.PopulationDefinitionPatientID = pdp.PopulationDefinitionPatientID
	INNER JOIN PatientMeasure pm
	    ON pm.PatientID = pdp.PatientID		
	INNER JOIN PopulationDefinitionConfiguration pdc WITH(NOLOCK)
		ON pdc.CodeGroupingID = pcg.CodeGroupingID
	INNER JOIN Metric m WITH(NOLOCK)
		ON m.MetricId = pdc.MetricID
			AND m.DenominatorID = pdp.PopulationDefinitionID
	INNER JOIN MetricReportConfiguration mrc WITH(NOLOCK)
		ON mrc.MetricId = m.MetricId
	INNER JOIN PopulationDefinition nr WITH(NOLOCK)
		ON nr.PopulationDefinitionID = m.NumeratorID
	INNER JOIN PopulationMetricsReports pmr WITH(NOLOCK)
		ON pmr.PopulationMetricsReportsId = mrc.ReportID
	WHERE pdc.MetricID IS NOT NULL
		AND pdc.CodeGroupingID IS NOT NULL
		AND pcg.DateOfService > = DATEADD(DAY, - pdc.TimeInDays, pdpad.OutPutAnchorDate)
		AND pcg.DateOfService < = pdpad.OutPutAnchorDate
		AND pm.DateTaken > = DATEADD(DAY, - pdc.TimeInDays, pdpad.OutPutAnchorDate)
		AND pm.DateTaken < = pdpad.OutPutAnchorDate
		AND pdpad.DateKey = mrc.Datekey
		AND pdpad.DateKey = @v_DateKey
		AND m.DenominatorType <> 'M'
		AND nr.NumeratorType = 'V'
		AND pmr.ReportName = 'Condition Prevalence'
		AND (m.MetricId = @i_MetricID )
		*/
		)
	SELECT *
	INTO #z
	FROM valueCTE vc

	MERGE NRPatientValue AS T
	USING (
		SELECT MetricID
			,PatientID
			,Value
			,ValueDate
			,IsIndicator
			,DateKey
		FROM #z v
		) AS S
		ON (
				t.MetricID = s.MetricID
				AND t.PatientID = s.PatientID
				AND t.DateKey = s.DateKey
				AND t.ValueDate = s.ValueDate
				AND t.[Value] = s.VALUE
				)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				MetricID
				,PatientID
				,Value
				,ValueDate
				,IsIndicator
				,DateKey
				,CreatedByUserId
				,CreatedDate
				)
			VALUES (
				S.MetricID
				,s.PatientID
				,s.Value
				,s.ValueDate
				,s.IsIndicator
				,s.DateKey
				,1
				,GETDATE()
				)
	WHEN MATCHED
		THEN
			UPDATE
			--SET t.Value = s.Value,
			SET t.IsIndicator = s.IsIndicator
	WHEN NOT MATCHED BY SOURCE
		AND EXISTS (
			SELECT 1
			FROM #z c
			WHERE t.MetricID = c.MetricID
				AND t.DateKey = c.DateKey
			)
		THEN
			DELETE;

	SELECT @i_Cnt = COUNT(*)
	FROM #z

	IF @i_Cnt = 0
	BEGIN
		DELETE
		FROM NRPatientValue
		WHERE MetricID = @i_MetricID
			AND DateKey = @v_DateKey
	END
	
		EXEC [usp_Batch_MetricFrequencyUpdateforPOPReport] 
			@i_AppUserId = @i_AppUserId
			,@v_DateKey = @v_DateKey
			,@i_MetricID = @i_MetricID
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_MetricPatientsByInternal] TO [FE_rohit.r-ext]
    AS [dbo];

