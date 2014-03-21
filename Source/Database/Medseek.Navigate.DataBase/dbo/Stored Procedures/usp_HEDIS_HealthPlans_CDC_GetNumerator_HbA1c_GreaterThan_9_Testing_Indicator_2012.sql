CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_CDC_GetNumerator_HbA1c_GreaterThan_9_Testing_Indicator_2012] (
	@PopulationDefinitionID INT
	,@MetricID INT
	,@Num_Months_Prior INT = 12
	,@Num_Months_After INT = 0
	,@ECTCodeVersion_Year INT = 2012
	,@ECTCodeStatus VARCHAR(1) = 'A'
	,@AnchorDate_Year INT = 2012
	,@AnchorDate_Month VARCHAR(2) = 12
	,@AnchorDate_Day VARCHAR(2) = 31
	,@ReportType CHAR(1) = 'P' --S For Strategic Companion,P for Population
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
CREATE TABLE #CDC_HbA1c_9_Patients_ByProcedures (
	[PatientID] INT NOT NULL
	,[ProcedureCode] VARCHAR(10) NULL
	,[BeginServiceDate] DATETIME NULL
	,
	)

CREATE CLUSTERED INDEX [IDX_CDC_HbA1c_9_Patients_ByProcedures] ON #CDC_HbA1c_9_Patients_ByProcedures (
	[PatientID] ASC
	,[BeginServiceDate] ASC
	)
	WITH (FILLFACTOR = 90);

/* Temporary Table to store Patients with Performed Lab Tests. */
CREATE TABLE #CDC_HbA1c_9_Patients_ByLabTest (
	[PatientID] INT NOT NULL
	,[MeasureValueNumeric] DECIMAL(10, 2) NULL
	,[DateTaken] DATETIME NULL
	,
	)

CREATE CLUSTERED INDEX [IDX_CDC_HbA1c_9_Patients_ByLabTest] ON #CDC_HbA1c_9_Patients_ByLabTest (
	[PatientID] ASC
	,[DateTaken] ASC
	)
	WITH (FILLFACTOR = 90);

DECLARE @CDC_HbA1c_9_Patients_MostRecentTestDate TABLE (
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
		INSERT INTO #CDC_HbA1c_9_Patients_ByProcedures
		SELECT DISTINCT [PatientID]
			,[ProcedureCode]
			,[BeginServiceDate]
		FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure_SelectedPopulation_MP('CDC-E', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @i_ManagedPopulationID, @ReportType)

		/* Stores Patients with Performed Lab Tests with LOINC Codes during the Measurement Period. */
		INSERT INTO #CDC_HbA1c_9_Patients_ByLabTest
		SELECT [PatientID]
			,[MeasureValueNumeric]
			,[DateTaken]
		FROM dbo.ufn_HEDIS_GetPatients_LabData_SelectedPopulation_MP('CDC-D', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @i_ManagedPopulationID, @ReportType)

		/* Obtains the List of Patients with Performed Tests, via either Performed Procedures (Procedure Codes)
   or Performed Lab Tests (LOINC Codes).  And, FOR EACH selected Patient obtain the 'Most Recent Date' on
   which EITHER Method of Testing -- via Procedures (Procedure Codes) or Lab Tests (LOINC Codes) -- was
   Performed for it. */
		INSERT INTO @CDC_HbA1c_9_Patients_MostRecentTestDate
		SELECT p.[PatientID]
			,MAX(p.[TestDate]) AS 'TestDate'
		FROM (
			SELECT DISTINCT [PatientID]
				,[BeginServiceDate] AS 'TestDate'
			FROM #CDC_HbA1c_9_Patients_ByProcedures
			
			UNION
			
			SELECT DISTINCT [PatientID]
				,[DateTaken] AS 'TestDate'
			FROM #CDC_HbA1c_9_Patients_ByLabTest
			) AS p
		GROUP BY p.[PatientID]

		INSERT INTO #PDNR
		SELECT DISTINCT p.[PatientID]
			,1 AS 'Value'
			,pdpa.[OutputAnchorDate] AS 'ValueDate'
			,1 AS 'IsIndicator'
		FROM (
			/* Select Patients with 'Conforming Test Results' of Performed Procedures (Procedure Codes) on the
	 'Most Recent Date' on which EITHER a Procedure (Procedure Codes) OR a Lab Test (LOINC Codes) was
	 Perfomed for the Patient. */
			SELECT p1.[PatientID]
			FROM @CDC_HbA1c_9_Patients_MostRecentTestDate p1
			INNER JOIN #CDC_HbA1c_9_Patients_ByProcedures p2 ON (p2.[PatientID] = p1.[PatientID])
				AND (p2.[BeginServiceDate] = p1.[TestDate])
			WHERE p2.[ProcedureCode] = '3046F'
			
			UNION
			
			/* Select Patients with 'Conforming Test Results' of Performed Lab Tests (LOINC Codes) on the
	 'Most Recent Date' on which EITHER a Procedure (Procedure Codes) OR a Lab Test (LOINC Codes) was
	 Perfomed for the Patient. */
			SELECT p1.[PatientID]
			FROM @CDC_HbA1c_9_Patients_MostRecentTestDate p1
			INNER JOIN #CDC_HbA1c_9_Patients_ByLabTest p2 ON (p2.[PatientID] = p1.[PatientID])
				AND (p2.[DateTaken] = p1.[TestDate])
			WHERE (p2.[MeasureValueNumeric] > 9)
				OR (p2.[MeasureValueNumeric] IS NULL)
			) AS p
		INNER JOIN [dbo].[PopulationDefinitionPatients] pat ON (pat.[PatientID] = p.[PatientID])
		INNER JOIN [dbo].[PopulationDefinitionPatientAnchorDate] pata ON (pat.[PopulationDefinitionPatientID] = pata.[PopulationDefinitionPatientID])
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
		/* Stores Patients with Performed Procedures with Procedure Codes during the Measurement Period. */
		INSERT INTO #CDC_HbA1c_9_Patients_ByProcedures
		SELECT DISTINCT [PatientID]
			,[ProcedureCode]
			,[BeginServiceDate]
		FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure_SelectedPopulation('CDC-E', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)

		/* Stores Patients with Performed Lab Tests with LOINC Codes during the Measurement Period. */
		INSERT INTO #CDC_HbA1c_9_Patients_ByLabTest
		SELECT [PatientID]
			,[MeasureValueNumeric]
			,[DateTaken]
		FROM dbo.ufn_HEDIS_GetPatients_LabData_SelectedPopulation('CDC-D', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)

		/* Obtains the List of Patients with Performed Tests, via either Performed Procedures (Procedure Codes)
   or Performed Lab Tests (LOINC Codes).  And, FOR EACH selected Patient obtain the 'Most Recent Date' on
   which EITHER Method of Testing -- via Procedures (Procedure Codes) or Lab Tests (LOINC Codes) -- was
   Performed for it. */
		INSERT INTO @CDC_HbA1c_9_Patients_MostRecentTestDate
		SELECT p.[PatientID]
			,MAX(p.[TestDate]) AS 'TestDate'
		FROM (
			SELECT DISTINCT [PatientID]
				,[BeginServiceDate] AS 'TestDate'
			FROM #CDC_HbA1c_9_Patients_ByProcedures
			
			UNION
			
			SELECT DISTINCT [PatientID]
				,[DateTaken] AS 'TestDate'
			FROM #CDC_HbA1c_9_Patients_ByLabTest
			) AS p
		GROUP BY p.[PatientID]

		INSERT INTO #PDNR
		SELECT DISTINCT p.[PatientID]
			,1 AS 'Value'
			,pdpa.[OutputAnchorDate] AS 'ValueDate'
			,1 AS 'IsIndicator'
		FROM (
			/* Select Patients with 'Conforming Test Results' of Performed Procedures (Procedure Codes) on the
	 'Most Recent Date' on which EITHER a Procedure (Procedure Codes) OR a Lab Test (LOINC Codes) was
	 Perfomed for the Patient. */
			SELECT p1.[PatientID]
			FROM @CDC_HbA1c_9_Patients_MostRecentTestDate p1
			INNER JOIN #CDC_HbA1c_9_Patients_ByProcedures p2 ON (p2.[PatientID] = p1.[PatientID])
				AND (p2.[BeginServiceDate] = p1.[TestDate])
			WHERE p2.[ProcedureCode] = '3046F'
			
			UNION
			
			/* Select Patients with 'Conforming Test Results' of Performed Lab Tests (LOINC Codes) on the
	 'Most Recent Date' on which EITHER a Procedure (Procedure Codes) OR a Lab Test (LOINC Codes) was
	 Perfomed for the Patient. */
			SELECT p1.[PatientID]
			FROM @CDC_HbA1c_9_Patients_MostRecentTestDate p1
			INNER JOIN #CDC_HbA1c_9_Patients_ByLabTest p2 ON (p2.[PatientID] = p1.[PatientID])
				AND (p2.[DateTaken] = p1.[TestDate])
			WHERE (p2.[MeasureValueNumeric] > 9)
				OR (p2.[MeasureValueNumeric] IS NULL)
			) AS p
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

	DELETE
	FROM dbo.NRPatientValue
	WHERE DateKey = @DateKey
		AND MetricID = @MetricID
	

	INSERT INTO dbo.NRPatientValue (
		MetricID
		,PatientId
		,Value
		,ValueDate
		,IsIndicator
		,DateKey
		,CreatedByUserId
		,CreatedDate
		)
	SELECT DISTINCT @MetricID
		,PatientID
		,Value
		,ValueDate
		,IsIndicator
		,@DateKey
		,1
		,GETDATE()
	FROM #PDNR


	
	

DROP TABLE #CDC_HbA1c_9_Patients_ByProcedures;

DROP TABLE #CDC_HbA1c_9_Patients_ByLabTest;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_CDC_GetNumerator_HbA1c_GreaterThan_9_Testing_Indicator_2012] TO [FE_rohit.r-ext]
    AS [dbo];

