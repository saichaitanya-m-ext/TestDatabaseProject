
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_PopulatePopulationDefinitionPatients]  
Description   : This proc is used to extract the data from CodeGroupers based on CodeGroup table
Created By    : Rathnam  
Created Date  : 28-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_PopulatePopulationDefinitionPatients] --1,20121130
	(
	@i_AppUserId KEYID
	,@v_DateKey VARCHAR(8)
	,@i_DrID KEYID = NULL
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

	DECLARE @d_NullFromDate DATE

	SELECT @d_NullFromDate = CONVERT(DATE, DATEADD(YYYY, - 200, GETDATE()))

	SELECT DISTINCT CodeGroupingID
		,DrID PopulationDefinitionID
	INTO #CodeGroup
	FROM PopulationDefinitionConfiguration
	WHERE MetricID IS NULL
	    AND (DrID = @i_DrID OR @i_DrID IS NULL)
		AND CodeGroupingID IS NOT NULL;

	WITH popCTE
	AS (
		SELECT ppcg.CodeGroupingID
			,ppc.PatientID
			,pdc.DrID
		FROM PatientProcedureCode ppc
		INNER JOIN PatientProcedureCodeGroup ppcg
			ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
		INNER JOIN #CodeGroup g
			ON g.CodeGroupingID = ppcg.CodeGroupingID
		INNER JOIN PopulationDefinitionConfiguration pdc
			ON pdc.DrID = g.PopulationDefinitionID
				AND pdc.CodeGroupingID = g.CodeGroupingID
		WHERE ppc.DateOfService > = CASE 
				WHEN pdc.TimeInDays IS NULL
					THEN @d_NullFromDate
				ELSE DATEADD(DAY, - pdc.TimeInDays, CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2)))
				END
			AND ppc.DateOfService < = CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2))
			AND pdc.MetricID IS NULL -- Means only Dr's not for Nr's
		GROUP BY ppcg.CodeGroupingID
			,ppc.PatientID
			,pdc.DrID
			,pdc.NoOfCodes
		HAVING COUNT(*) >= pdc.NoOfCodes
		
		UNION
		
		SELECT ppcg.CodeGroupingID
			,ppc.PatientID
			,pdc.DrID
		FROM PatientDiagnosisCode ppc
		INNER JOIN PatientDiagnosisCodeGroup ppcg
			ON ppc.PatientDiagnosisCodeID = ppcg.PatientDiagnosisCodeID
		INNER JOIN #CodeGroup g
			ON g.CodeGroupingID = ppcg.CodeGroupingID
		INNER JOIN PopulationDefinitionConfiguration pdc
			ON pdc.DrID = g.PopulationDefinitionID
				AND pdc.CodeGroupingID = g.CodeGroupingID
		WHERE ppc.DateOfService > = CASE 
				WHEN pdc.TimeInDays IS NULL
					THEN @d_NullFromDate
				ELSE DATEADD(DAY, - pdc.TimeInDays, CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2)))
				END
			AND ppc.DateOfService < = CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2))
			AND pdc.MetricID IS NULL -- Means only Dr's not for Nr's
		GROUP BY ppcg.CodeGroupingID
			,ppc.PatientID
			,pdc.DrID
			,pdc.NoOfCodes
		HAVING COUNT(*) >= pdc.NoOfCodes
		
		UNION
		
		SELECT ppcg.CodeGroupingID
			,ppc.PatientID
			,pdc.DrID
		FROM PatientOtherCode ppc
		INNER JOIN PatientOtherCodeGroup ppcg
			ON ppc.PatientOtherCodeID = ppcg.PatientOtherCodeID
		INNER JOIN #CodeGroup g
			ON g.CodeGroupingID = ppcg.CodeGroupingID
		INNER JOIN PopulationDefinitionConfiguration pdc
			ON pdc.DrID = g.PopulationDefinitionID
				AND pdc.CodeGroupingID = g.CodeGroupingID
		WHERE ppc.DateOfService > = CASE 
				WHEN pdc.TimeInDays IS NULL
					THEN @d_NullFromDate
				ELSE DATEADD(DAY, - pdc.TimeInDays, CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2)))
				END
			AND ppc.DateOfService < = CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2))
			AND pdc.MetricID IS NULL -- Means only Dr's not for Nr's
		GROUP BY ppcg.CodeGroupingID
			,ppc.PatientID
			,pdc.DrID
			,pdc.NoOfCodes
		HAVING COUNT(*) >= pdc.NoOfCodes
		
		UNION
		
		SELECT ppcg.CodeGroupingID
			,ppc.PatientID
			,pdc.DrID
		FROM RxClaim ppc
		INNER JOIN PatientMedicationCodeGroup ppcg
			ON ppc.RxClaimId = ppcg.RxClaimId
		INNER JOIN #CodeGroup g
			ON g.CodeGroupingID = ppcg.CodeGroupingID
		INNER JOIN PopulationDefinitionConfiguration pdc
			ON pdc.DrID = g.PopulationDefinitionID
				AND pdc.CodeGroupingID = g.CodeGroupingID
		WHERE ppc.DateFilled > = CASE 
				WHEN pdc.TimeInDays IS NULL
					THEN @d_NullFromDate
				ELSE DATEADD(DAY, - pdc.TimeInDays, CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2)))
				END
			AND ppc.DateFilled < = CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2))
			AND pdc.MetricID IS NULL -- Means only Dr's not for Nr's
		GROUP BY ppcg.CodeGroupingID
			,ppc.PatientID
			,pdc.DrID
			,pdc.NoOfCodes
		HAVING COUNT(*) >= pdc.NoOfCodes
		
		UNION
		
		SELECT ppcg.CodeGroupingID
			,ppc.PatientID
			,pdc.DrID
		FROM PatientMeasure ppc
		INNER JOIN PatientLabGroup ppcg
			ON ppc.PatientMeasureID = ppcg.PatientMeasureID
		INNER JOIN #CodeGroup g
			ON g.CodeGroupingID = ppcg.CodeGroupingID
		INNER JOIN PopulationDefinitionConfiguration pdc
			ON pdc.DrID = g.PopulationDefinitionID
				AND pdc.CodeGroupingID = g.CodeGroupingID
		WHERE ppc.DateTaken > = CASE 
				WHEN pdc.TimeInDays IS NULL
					THEN @d_NullFromDate
				ELSE DATEADD(DAY, - pdc.TimeInDays, CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2)))
				END
			AND ppc.DateTaken < = CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2))
			AND pdc.MetricID IS NULL -- Means only Dr's not for Nr's
		GROUP BY ppcg.CodeGroupingID
			,ppc.PatientID
			,pdc.DrID
			,pdc.NoOfCodes
		HAVING COUNT(*) >= pdc.NoOfCodes
		)
	SELECT DISTINCT PatientID
		,DrID
	INTO #PDPatients
	FROM popCTE

	MERGE PopulationDefinitionPatients AS t
	USING (
		SELECT PatientID
			,PopulationDefinitionID
		FROM #PDPatients
		) AS s
		ON (s.PatientID = t.PatientID)
			AND s.PopulationDefinitionID = t.PopulationDefinitionID
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				PopulationDefinitionID
				,PatientID
				,CreatedByUserId
				)
			VALUES (
				s.PopulationDefinitionID
				,s.PatientID
				,1
				)
	WHEN MATCHED
		THEN
			UPDATE
			SET t.StatusCode = 'A';

	ALTER TABLE #PDPatients ADD PopulationDefinitionPatientID INT

	UPDATE #PDPatients
	SET PopulationDefinitionPatientID = PopulationDefinitionPatients.PopulationDefinitionPatientID
	FROM PopulationDefinitionPatients
	WHERE PopulationDefinitionPatients.PopulationDefinitionID = #PDPatients.PopulationDefinitionID
		AND PopulationDefinitionPatients.PatientID = #PDPatients.PatientID

	MERGE PopulationDefinitionPatientAnchorDate AS t
	USING (
		SELECT PopulationDefinitionPatientID
		FROM #PDPatients
		) AS s
		ON (s.PopulationDefinitionPatientID = t.PopulationDefinitionPatientID)
			AND t.DateKey = CONVERT(INT, @v_DateKey)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				PopulationDefinitionPatientID
				,CreatedByUserId
				,DateKey
				,OutPutAnchorDate
				)
			VALUES (
				s.PopulationDefinitionPatientID
				,1
				,@v_DateKey
				,CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2))
				)
	WHEN MATCHED
		AND t.StatusCode = 'I'
		THEN
			UPDATE
			SET t.StatusCode = 'A'
	WHEN NOT MATCHED BY SOURCE
		AND EXISTS (
			SELECT 1
			FROM #PDPatients p
			WHERE p.PopulationDefinitionPatientID <> t.PopulationDefinitionPatientID
				AND t.DateKey = CONVERT(INT, @v_DateKey)
			)
		THEN
			UPDATE
			SET t.StatusCode = 'I';

	---------------- Parameter ConditionList 	
	SELECT DrID
		,pdc.ConditionIdList
	INTO #t
	FROM PopulationDefinitionConfiguration pdc
	WHERE pdc.ConditionIdList IS NOT NULL
	AND (DrID = @i_DrID OR @i_DrID IS NULL)

	DECLARE @tblDr TABLE (
		DrID INT
		,DerivedPDID INT
		)
	DECLARE @i INT

	SELECT @i = MIN(Drid)
	FROM #t

	WHILE @i >= 0
	BEGIN
		INSERT INTO @tblDr (
			DrID
			,DerivedPDID
			)
		SELECT @i
			,usstt.KeyValue
		FROM dbo.udf_SplitStringToTable((
					SELECT ConditionIdList
					FROM #t
					WHERE Drid = @i
					), ',') usstt

		DELETE
		FROM #t
		WHERE Drid = @i

		SELECT @i = MIN(Drid)
		FROM #t
	END

	SELECT Dr.DrID PopulationDefinitionID
		,pdp.PatientID PatientID
	INTO #PDPatients1
	FROM @tblDr Dr
	INNER JOIN PopulationDefinition newpd
		ON newpd.PopulationDefinitionID = dr.DrID
	INNER JOIN PopulationDefinition derivedpd
		ON derivedpd.PopulationDefinitionID = dr.DerivedPDID
	INNER JOIN PopulationDefinitionPatients pdp
		ON pdp.PopulationDefinitionID = derivedpd.PopulationDefinitionID
	INNER JOIN PopulationDefinitionPatientAnchorDate pdpad
		ON pdpad.PopulationDefinitionPatientID = pdp.PopulationDefinitionPatientID
	WHERE pdpad.DateKey = @v_DateKey
	GROUP BY Dr.DrID
		,pdp.PatientID
	HAVING COUNT(*) > 1 --- its mandatory as its intersect the list of patients from the different derived PD's

	MERGE PopulationDefinitionPatients AS t
	USING (
		SELECT PatientID
			,PopulationDefinitionID
		FROM #PDPatients1
		) AS s
		ON (s.PatientID = t.PatientID)
			AND s.PopulationDefinitionID = t.PopulationDefinitionID
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				PopulationDefinitionID
				,PatientID
				,CreatedByUserId
				)
			VALUES (
				s.PopulationDefinitionID
				,s.PatientID
				,1
				)
	WHEN MATCHED
		THEN
			UPDATE
			SET t.StatusCode = 'A';

	ALTER TABLE #PDPatients1 ADD PopulationDefinitionPatientID INT

	UPDATE #PDPatients1
	SET PopulationDefinitionPatientID = PopulationDefinitionPatients.PopulationDefinitionPatientID
	FROM PopulationDefinitionPatients
	WHERE PopulationDefinitionPatients.PopulationDefinitionID = #PDPatients1.PopulationDefinitionID
		AND PopulationDefinitionPatients.PatientID = #PDPatients1.PatientID

	MERGE PopulationDefinitionPatientAnchorDate AS t
	USING (
		SELECT PopulationDefinitionPatientID
		FROM #PDPatients1
		) AS s
		ON (s.PopulationDefinitionPatientID = t.PopulationDefinitionPatientID)
			AND t.DateKey = CONVERT(INT, @v_DateKey)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				PopulationDefinitionPatientID
				,CreatedByUserId
				,DateKey
				,OutPutAnchorDate
				)
			VALUES (
				s.PopulationDefinitionPatientID
				,1
				,@v_DateKey
				,CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2))
				)
	WHEN MATCHED
		AND t.StatusCode = 'I'
		THEN
			UPDATE
			SET t.StatusCode = 'A'
	WHEN NOT MATCHED BY SOURCE
		AND EXISTS (
			SELECT 1
			FROM #PDPatients1 p
			WHERE p.PopulationDefinitionPatientID <> t.PopulationDefinitionPatientID
				AND t.DateKey = CONVERT(INT, @v_DateKey)
			)
		THEN
			UPDATE
			SET t.StatusCode = 'I';
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_PopulatePopulationDefinitionPatients] TO [FE_rohit.r-ext]
    AS [dbo];

