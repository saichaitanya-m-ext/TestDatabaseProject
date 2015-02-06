CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_CDC_GetNumerator_BP_LessThan_140_80mm_Testing_Indicator_2012] (
	@PopulationDefinitionID INT
	,@MetricID INT
	,@Num_Months_Prior INT = 12
	,@Num_Months_After INT = 0
	,@ECTCodeVersion_Year INT = 2012
	,@ECTCodeStatus VARCHAR(1) = 'A'
	,@AnchorDate_Year INT = 2012
	,@AnchorDate_Month VARCHAR(2) = 12
	,@AnchorDate_Day VARCHAR(2) = 31
	,@ReportType CHAR(1) = 'P' --P for Population ,S for stategic
	)
AS
/************************************************************ INPUT PARAMETERS ************************************************************

	 @PopulationDefinitionID = Handle to the selected Population of Patients from which the Eligible Population of Patients of the Numerator
							   are to be constructed.

	 @Num_Months_Prior = Number of Months Before the Anchor Date from which Eligible Population of Patients with desired Encounter Claims
						 is to be constructed.

	 @Num_Months_After = Number of Months After the Anchor Date from which Eligible Population of Patients with desired Encounter Claims
						 is to be constructed.

	 @ECTCodeVersion_Year = Code Version Year from which valid HEDIS-associated ECT and Drug Codes during the Measurement Period that are
						    retrieved to identify Patients for inclusion in the Eligible Population of Patients.

	 @ECTCodeStatus = Status of valid HEDIS-associated ECT and Drug Codes during the Measurement Period that are retrieved to identify Patients
					  for inclusion in the Eligible Population of Patients during the Measurement Period.
					  Examples = 1 (for 'Enabled') or 0 (for 'No').

	 *********************************************************************************************************************************************/
/* Temporary Table to store Patients with Performed Procedures. */
CREATE TABLE #CDC_BP_140_80_Patients_ByProcedures (
	[PatientID] INT NOT NULL
	,[ProcedureCode] VARCHAR(10) NULL
	,[BeginServiceDate] DATETIME NULL
	,
	)

CREATE CLUSTERED INDEX [IDX_CDC_BP_140_80_Patients_ByProcedures] ON #CDC_BP_140_80_Patients_ByProcedures (
	[PatientID] ASC
	,[BeginServiceDate] ASC
	)
	WITH (FILLFACTOR = 90);

/* Temporary Table to store Measured Blood Pressures of Patients. */
CREATE TABLE #CDC_BP_140_80_Patients_ByBloodPressures (
	[PatientID] INT NOT NULL
	,[Systolic] DECIMAL(5, 2) NULL
	,[Diastolic] DECIMAL(5, 2) NULL
	,[DateTaken] DATETIME NULL
	,
	)

CREATE CLUSTERED INDEX [IDX_CDC_BP_140_80_Patients_ByBloodPressures] ON #CDC_BP_140_80_Patients_ByBloodPressures (
	[PatientID] ASC
	,[DateTaken] ASC
	)
	WITH (FILLFACTOR = 90);

DECLARE @CDC_BP_140_80_Patients_MostRecentTestDate TABLE (
	[PatientID] INT NOT NULL
	,[TestDate] DATETIME NOT NULL
	,PRIMARY KEY (
		[PatientID]
		,[TestDate]
		)
	)
DECLARE @v_DenominatorType VARCHAR(1)
	,@i_ManagedPopulationID INT

SELECT @v_DenominatorType = m.DenominatorType
	,@i_ManagedPopulationID = m.ManagedPopulationID
FROM Metric m
WHERE m.MetricId = @MetricID

CREATE TABLE #PDNR (
	PatientID INT
	,[Value] DECIMAL(10, 2)
	,ValueDate DATE
	,IsIndicator BIT
	)


	IF @v_DenominatorType = 'M'
		AND @i_ManagedPopulationID IS NOT NULL
	BEGIN
		/* Stores Patients with Performed Procedures with Procedure Codes during the Measurement Period. */
		INSERT INTO #CDC_BP_140_80_Patients_ByProcedures
		SELECT DISTINCT [PatientID]
			,[ProcedureCode]
			,[BeginServiceDate]
		FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure_SelectedPopulation_MP('CDC-M', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @i_ManagedPopulationID, @ReportType)

		INSERT INTO #CDC_BP_140_80_Patients_ByBloodPressures
		SELECT [PatientID]
			,[Systolic]
			,[Diastolic]
			,[ReadingTime]
		FROM dbo.ufn_GetPatients_BodyVitalSigns_BloodPressure_SelectedPopulation_MP(@PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @i_ManagedPopulationID,@ReportType)

		/* Obtains the List of Patients with Performed Tests, via either Performed Procedures (Procedure Codes)
   or Performed Blood Pressure readings.  And, FOR EACH selected Patient obtain the 'Most Recent Date'
   on which EITHER Method of Testing -- via Procedures (Procedure Codes) or Lab Tests (LOINC Codes) --
   was Performed for it. */
		INSERT INTO @CDC_BP_140_80_Patients_MostRecentTestDate
		SELECT p.[PatientID]
			,MAX(p.[TestDate]) AS 'TestDate'
		FROM (
			SELECT DISTINCT [PatientID]
				,[BeginServiceDate] AS 'TestDate'
			FROM #CDC_BP_140_80_Patients_ByProcedures
			
			UNION
			
			SELECT DISTINCT [PatientID]
				,[DateTaken] AS 'TestDate'
			FROM #CDC_BP_140_80_Patients_ByBloodPressures
			) AS p
		GROUP BY p.[PatientID]

		INSERT INTO #PDNR
		SELECT DISTINCT p.[PatientID]
			,1 AS 'Value'
			,pdpa.[OutputAnchorDate] AS 'ValueDate'
			,1 AS 'IsIndicator'
		FROM (
			/* Select Patients with 'Conforming Test Results' of Performed Procedures (Procedure Codes) on the
	 'Most Recent Date' on which EITHER a Procedure (Procedure Codes) OR a Blood Pressure reading was
	 Perfomed for the Patient. */
			SELECT p1.[PatientID]
			FROM @CDC_BP_140_80_Patients_MostRecentTestDate p1
			INNER JOIN #CDC_BP_140_80_Patients_ByProcedures p2 ON (p2.[PatientID] = p1.[PatientID])
				AND (p2.[BeginServiceDate] = p1.[TestDate])
			WHERE p2.[ProcedureCode] IN (
					'3074F'
					,'3075F'
					,'3078F'
					)
			
			UNION
			
			/* Select Patients with 'Conforming Test Results' of Performed Blood Pressure readings on the
	 'Most Recent Date' on which EITHER a Procedure (Procedure Codes) OR a Blood Pressure reading was
	 Perfomed for the Patient. */
			SELECT p1.[PatientID]
			FROM @CDC_BP_140_80_Patients_MostRecentTestDate p1
			INNER JOIN #CDC_BP_140_80_Patients_ByBloodPressures p2 ON (p2.[PatientID] = p1.[PatientID])
				AND (p2.[DateTaken] = p1.[TestDate])
			WHERE (
					(p2.[Systolic] < 140)
					AND (p2.[Diastolic] < 80)
					)
				OR (p2.[Systolic] IS NULL)
				OR (p2.[Diastolic] IS NULL)
			) AS p
		INNER JOIN [dbo].[PopulationDefinitionPatients] pat ON (pat.[PatientID] = p.[PatientID])
		INNER JOIN PatientProgram pp WITH (NOLOCK) ON pp.PatientID = p.PatientID
		INNER JOIN (
			SELECT pdpa1.PopulationDefinitionPatientID
				,MAX(pdpa1.OutPutAnchorDate) OutPutAnchorDate
			FROM PopulationDefinitionPatientAnchorDate pdpa1 WITH (NOLOCK)
			INNER JOIN PopulationDefinitionPatients pdp WITH (NOLOCK) ON pdp.PopulationDefinitionPatientID = pdpa1.PopulationDefinitionPatientID
			WHERE pdp.PopulationDefinitionID = @PopulationDefinitionID
			GROUP BY pdpa1.PopulationDefinitionPatientID
			) pdpa ON pdpa.PopulationDefinitionPatientID = pat.PopulationDefinitionPatientID
		WHERE pp.ProgramID = @i_ManagedPopulationID
			AND pat.PopulationDefinitionID = @PopulationDefinitionID
	END
	ELSE
	BEGIN
		INSERT INTO #CDC_BP_140_80_Patients_ByProcedures
		SELECT DISTINCT [PatientID]
			,[ProcedureCode]
			,[BeginServiceDate]
		FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure_SelectedPopulation('CDC-M', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)

		INSERT INTO #CDC_BP_140_80_Patients_ByBloodPressures
		SELECT [PatientID]
			,[Systolic]
			,[Diastolic]
			,[ReadingTime]
		FROM dbo.ufn_GetPatients_BodyVitalSigns_BloodPressure_SelectedPopulation(@PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day,@ReportType)

		/* Obtains the List of Patients with Performed Tests, via either Performed Procedures (Procedure Codes)
   or Performed Blood Pressure readings.  And, FOR EACH selected Patient obtain the 'Most Recent Date'
   on which EITHER Method of Testing -- via Procedures (Procedure Codes) or Lab Tests (LOINC Codes) --
   was Performed for it. */
		INSERT INTO @CDC_BP_140_80_Patients_MostRecentTestDate
		SELECT p.[PatientID]
			,MAX(p.[TestDate]) AS 'TestDate'
		FROM (
			SELECT DISTINCT [PatientID]
				,[BeginServiceDate] AS 'TestDate'
			FROM #CDC_BP_140_80_Patients_ByProcedures
			
			UNION
			
			SELECT DISTINCT [PatientID]
				,[DateTaken] AS 'TestDate'
			FROM #CDC_BP_140_80_Patients_ByBloodPressures
			) AS p
		GROUP BY p.[PatientID]

		INSERT INTO #PDNR
		SELECT DISTINCT p.[PatientID]
			,1 AS 'Value'
			,pdpa.[OutputAnchorDate] AS 'ValueDate'
			,1 AS 'IsIndicator'
		FROM (
			/* Select Patients with 'Conforming Test Results' of Performed Procedures (Procedure Codes) on the
	 'Most Recent Date' on which EITHER a Procedure (Procedure Codes) OR a Blood Pressure reading was
	 Perfomed for the Patient. */
			SELECT p1.[PatientID]
			FROM @CDC_BP_140_80_Patients_MostRecentTestDate p1
			INNER JOIN #CDC_BP_140_80_Patients_ByProcedures p2 ON (p2.[PatientID] = p1.[PatientID])
				AND (p2.[BeginServiceDate] = p1.[TestDate])
			WHERE p2.[ProcedureCode] IN (
					'3074F'
					,'3075F'
					,'3078F'
					)
			
			UNION
			
			/* Select Patients with 'Conforming Test Results' of Performed Blood Pressure readings on the
	 'Most Recent Date' on which EITHER a Procedure (Procedure Codes) OR a Blood Pressure reading was
	 Perfomed for the Patient. */
			SELECT p1.[PatientID]
			FROM @CDC_BP_140_80_Patients_MostRecentTestDate p1
			INNER JOIN #CDC_BP_140_80_Patients_ByBloodPressures p2 ON (p2.[PatientID] = p1.[PatientID])
				AND (p2.[DateTaken] = p1.[TestDate])
			WHERE (
					(p2.[Systolic] < 140)
					AND (p2.[Diastolic] < 80)
					)
				OR (p2.[Systolic] IS NULL)
				OR (p2.[Diastolic] IS NULL)
			) AS p
		--INNER JOIN [dbo].[PopulationDefinitionPatients] pat ON (pat.[PopulationDefinitionID] = p.[PatientID]) AND (pat.[StatusCode] = 'A')
		INNER JOIN [dbo].[PopulationDefinitionPatients] pat ON (pat.[PatientID] = p.[PatientID])
		INNER JOIN PopulationDefinitionPatientAnchorDate pdpa ON pdpa.PopulationDefinitionPatientID = pat.PopulationDefinitionPatientID
		WHERE pdpa.DateKey = (
				CONVERT(VARCHAR, @AnchorDate_Year) + CASE 
					WHEN LEN(@AnchorDate_Month) = 1
						THEN '0' + CONVERT(VARCHAR, @AnchorDate_Month)
					ELSE CONVERT(VARCHAR, @AnchorDate_Month)
					END + CASE 
					WHEN LEN(@AnchorDate_Day) = 1
						THEN '0' + CONVERT(VARCHAR, @AnchorDate_Day)
					ELSE CONVERT(VARCHAR, @AnchorDate_Day)
					END
				)
			AND pat.PopulationDefinitionID = @PopulationDefinitionID
	END



DECLARE @DateKey INT

SET @DateKey = (CONVERT(VARCHAR, @AnchorDate_Year) + RIGHT('0' + CAST(@AnchorDate_Month AS VARCHAR), 2) + RIGHT('0' + CAST(@AnchorDate_Day AS VARCHAR), 2))

--SET @DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day) 

	MERGE NRPatientValue AS T
	USING (
		SELECT @MetricID AS MetricID
			--,@i_NrID AS NrID
			,PatientID
			,Value
			,ValueDate
			,IsIndicator
			,@DateKey DateKey
		FROM #PDNR
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
				--,NRDefID
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
				--,S.NrID
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
			SET T.IsIndicator = S.IsIndicator
	WHEN NOT MATCHED BY SOURCE
		AND EXISTS (
			SELECT 1
			FROM #PDNR c
			WHERE t.MetricID = @MetricID
				--AND c.PatientId <> t.PatientID
				--AND c.ValueDate <> t.ValueDate
				AND t.DateKey = @DateKey
				--AND t.[Value] <> c.VALUE
			)
		THEN
			DELETE;

	DECLARE @i_Cnt INT

	SELECT @i_Cnt = COUNT(*)
	FROM #PDNR

	IF @i_Cnt = 0
	BEGIN
		DELETE
		FROM NRPatientValue
		WHERE MetricID = @MetricID
			AND DateKey = @DateKey
	END


DROP TABLE #CDC_BP_140_80_Patients_ByProcedures;

DROP TABLE #CDC_BP_140_80_Patients_ByBloodPressures;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_CDC_GetNumerator_BP_LessThan_140_80mm_Testing_Indicator_2012] TO [FE_rohit.r-ext]
    AS [dbo];

