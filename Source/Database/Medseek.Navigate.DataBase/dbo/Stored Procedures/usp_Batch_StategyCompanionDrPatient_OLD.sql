

/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_StategyCompanionDrPatient]  
Description   : This proc is used to extract the data from CodeGroupers 
Created By    : Rathnam  
Created Date  : 28-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_StategyCompanionDrPatient_OLD] (
	@i_AppUserId KEYID
	,@v_DateKey VARCHAR(8)
	,@i_DrID KEYID
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

	DECLARE @d_DateKey DATE

	SET @d_DateKey = CONVERT(DATE, SUBSTRING(@v_DateKey, 1, 4) + '-' + SUBSTRING(@v_DateKey, 5, 2) + '-' + SUBSTRING(@v_DateKey, 7, 2))

	DECLARE @i_CodeGroupingID INT

	SELECT @i_CodeGroupingID = CodeGroupingID
	FROM PopulationDefinitionConfiguration
	WHERE MetricID IS NULL
		AND DrID = @i_DrID
		AND CodeGroupingID IS NOT NULL
		AND ConditionIdList IS NULL
		AND DrProcName IS NULL

	IF @i_CodeGroupingID IS NOT NULL
	BEGIN
		CREATE TABLE #PDPatients (
			CodeGroupingID INT
			,PatientID INT
			,DrID INT
			,Amt Money
			)

		INSERT INTO #PDPatients
		SELECT g.CodeGroupingId
			,g.PatientID
			,pdc.DrID
			,SUM(g.Amt)
		FROM vw_PatientCodeGroupAmt g WITH (NOLOCK)
		INNER JOIN PopulationDefinitionConfiguration pdc WITH (NOLOCK)
			ON g.CodeGroupingid = pdc.CodeGroupingID
		WHERE pdc.CodeGroupingid = @i_CodeGroupingID
			AND pdc.DrID = @i_DrID
			AND pdc.MetricID IS NULL
			AND g.DateOfService > = DATEADD(dd, - (DAY(@d_DateKey) - 1), @d_DateKey)
			AND g.DateOfService < = @d_DateKey
		GROUP BY g.CodeGroupingId
			,g.PatientID
			,pdc.DrID
			,pdc.NoOfCodes
		HAVING COUNT(*) >= pdc.NoOfCodes

		DELETE
		FROM PatientDr
		WHERE DrID = @i_DrID
			AND DateKey = @v_DateKey


		INSERT INTO PatientDr (
			DrID
			,PatientID
			,DateKey
			,OutPutAnchorDate
			,ClaimAmt
			,CreatedDate
			)
		SELECT p.DrID
			,p.PatientID
			,@v_DateKey
			,@d_DateKey
			,p.Amt
			,GETDATE()
		FROM #PDPatients p
	END
	/*
	ELSE
	
	BEGIN
		---------------- Parameter ConditionList 	
		SELECT DrID
			,pdc.ConditionIdList
		INTO #t
		FROM PopulationDefinitionConfiguration pdc
		WHERE pdc.ConditionIdList IS NOT NULL
			AND (
				DrID = @i_DrID
				OR @i_DrID IS NULL
				)

		IF EXISTS (
				SELECT 1
				FROM #t
				)
		BEGIN
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

			DELETE
			FROM PopulationDefinitionPatientAnchorDate
			WHERE EXISTS (
					SELECT 1
					FROM PopulationDefinitionPatients pdp
					WHERE pdp.PopulationDefinitionPatientID = PopulationDefinitionPatientAnchorDate.PopulationDefinitionPatientID
						AND pdp.PopulationDefinitionID = @i_DrID
					)
				AND DateKey = @v_DateKey

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
						,@d_DateKey
						);
						--WHEN MATCHED
						--	THEN
						--		UPDATE
						--		SET t.StatusCode = 'A'
						--			,T.OutPutAnchorDate = @d_DateKey;
						--WHEN NOT MATCHED BY SOURCE
						--	AND EXISTS (
						--		SELECT 1
						--		FROM #PDPatients1 p
						--		WHERE p.PopulationDefinitionPatientID <> t.PopulationDefinitionPatientID
						--			AND t.DateKey = CONVERT(INT, @v_DateKey)
						--		)
						--	THEN
						--		DELETE;
		END
	END
	*/
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_StategyCompanionDrPatient_OLD] TO [FE_rohit.r-ext]
    AS [dbo];

