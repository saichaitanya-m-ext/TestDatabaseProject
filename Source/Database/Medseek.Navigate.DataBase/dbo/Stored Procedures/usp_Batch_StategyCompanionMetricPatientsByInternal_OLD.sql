
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_StategyCompanionMetricPatientsByInternal]  
Description   : This proc is used to fetch the Nr OR Utilization patients
Created By    : Rathnam  
Created Date  : 08-AUG-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_StategyCompanionMetricPatientsByInternal_OLD] --1,@v_DateKey
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
	END

	DECLARE @v_NumeratorType VARCHAR(1)

	SELECT @v_NumeratorType = NumeratorType
	FROM Metric m WITH(NOLOCK)
	INNER JOIN PopulationDefinition pd  WITH(NOLOCK)
		ON pd.PopulationDefinitionID = m.NumeratorID
	WHERE m.MetricId = @i_MetricID

	IF @v_NumeratorType = 'C'
	BEGIN
			;

		WITH nrCTE
		AS (
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
			INNER JOIN PatientDr pd WITH (NOLOCK)
				ON pd.PatientID = pcg.PatientID
			INNER JOIN PopulationDefinitionConfiguration pdc WITH (NOLOCK)
				ON pdc.CodeGroupingID = pcg.CodeGroupingID
			INNER JOIN Metric m WITH (NOLOCK)
				ON m.MetricId = pdc.MetricID
					AND m.DenominatorID = pd.DrID
			INNER JOIN PopulationDefinition nr WITH (NOLOCK)
				ON nr.PopulationDefinitionID = m.NumeratorID
			WHERE pdc.MetricID IS NOT NULL
				AND pdc.CodeGroupingID IS NOT NULL
				AND pcg.DateOfService > = DATEADD(dd, - (DAY(OutPutAnchorDate) - 1), OutPutAnchorDate) 
				AND pcg.DateOfService < = pd.OutPutAnchorDate
				AND pd.DateKey = @v_DateKey
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
			INNER JOIN PatientDr pdp WITH (NOLOCK)
				ON pdp.PatientID = pcg.PatientID
			INNER JOIN Metric m WITH (NOLOCK)
				ON m.DenominatorID = pdp.DrID
			INNER JOIN PopulationDefinitionConfiguration pdc WITH (NOLOCK)
				ON pdc.MetricID = m.MetricID
			INNER JOIN PopulationDefinition nr WITH (NOLOCK)
				ON nr.PopulationDefinitionID = m.NumeratorID
			WHERE pdc.MetricID IS NOT NULL
				AND pdc.CodeGroupingID IS NULL
				AND pcg.DateFilled > = DATEADD(dd, - (DAY(OutPutAnchorDate) - 1), OutPutAnchorDate) 
				AND pcg.DateFilled < = pdp.OutPutAnchorDate
				AND pdp.DateKey = @v_DateKey
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

		MERGE PatientNr AS T
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
					,Cnt
					,IsIndicator
					,DateKey
					,NrType
					)
				VALUES (
					S.MetricID
					,s.PatientID
					,s.Cnt
					,s.IsIndicator
					,s.DateKey
					,'C'
					)
		WHEN MATCHED
			THEN
				UPDATE
				SET T.Cnt = S.Cnt
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
		END
	END
	ELSE
		IF @v_NumeratorType = 'V'
		BEGIN
				;

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
							THEN pdp.OutPutAnchorDate
						ELSE pm.DateTaken
						END ValueDate
				FROM vw_PatientCodeGroup pcg WITH (NOLOCK)
				INNER JOIN PatientDr pdp WITH (NOLOCK)
					ON pdp.PatientID = pcg.PatientID
				INNER JOIN PatientMeasure pm
					ON pm.PatientID = pdp.PatientID
				INNER JOIN PopulationDefinitionConfiguration pdc WITH (NOLOCK)
					ON pdc.CodeGroupingID = pcg.CodeGroupingID
				INNER JOIN Metric m WITH (NOLOCK)
					ON m.MetricId = pdc.MetricID
						AND m.DenominatorID = pdp.DrID
				INNER JOIN PopulationDefinition nr WITH (NOLOCK)
					ON nr.PopulationDefinitionID = m.NumeratorID
				WHERE pdc.MetricID IS NOT NULL
					AND pdc.CodeGroupingID IS NOT NULL
					AND pcg.DateOfService > = DATEADD(dd, - (DAY(OutPutAnchorDate) - 1), OutPutAnchorDate) 
					AND pcg.DateOfService < = pdp.OutPutAnchorDate
					AND pm.DateTaken > = DATEADD(dd, - (DAY(OutPutAnchorDate) - 1), OutPutAnchorDate) 
					AND pm.DateTaken < = pdp.OutPutAnchorDate
					AND pdp.DateKey = @v_DateKey
					AND m.DenominatorType <> 'M'
					AND nr.NumeratorType = 'V'
					AND (m.MetricId = @i_MetricID)
				)
			SELECT *
			INTO #z
			FROM valueCTE vc

			DELETE
			FROM dbo.PatientNr
			WHERE MetricID = @i_MetricID
				AND DateKey = @v_DateKey
				AND NrType = 'V';

			WITH CTE_NrPatientInsert
			AS (
				SELECT Sno = ROW_NUMBER() OVER (
						PARTITION BY PatientId ORDER BY ValueDate DESC
						)
					,@i_MetricID AS MetricId
					,PatientID
					,IsIndicator
					,CreatedByUserId
					,DateKey
					,Value
					,ValueDate
				FROM #z
				)
			INSERT INTO PatientNr (
				MetricID
				,PatientID
				,LastValue
				,LastValueDate
				,DateKey
				,CreatedDate
				,NrType
				,IsIndicator
				)
			SELECT MetricId
				,PatientID
				,Value
				,ValueDate
				,@v_DateKey
				,GETDATE()
				,'V'
				,IsIndicator
			FROM CTE_NrPatientInsert
			WHERE Sno = 1
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
    ON OBJECT::[dbo].[usp_Batch_StategyCompanionMetricPatientsByInternal_OLD] TO [FE_rohit.r-ext]
    AS [dbo];

