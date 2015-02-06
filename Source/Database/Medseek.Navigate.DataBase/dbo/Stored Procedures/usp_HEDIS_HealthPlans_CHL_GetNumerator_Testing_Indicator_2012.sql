CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_CHL_GetNumerator_Testing_Indicator_2012] (
	@PopulationDefinitionID INT
	,@MetricID INT
	,@Num_Months_Prior INT = 12
	,@Num_Months_After INT = 0
	,@ECTCodeVersion_Year INT = 2012
	,@ECTCodeStatus VARCHAR(1) = 'A'
	,@AnchorDate_Year INT = 2012
	,@AnchorDate_Month VARCHAR(2) = 12
	,@AnchorDate_Day VARCHAR(2) = 31
	,@ReportType CHAR(1) = 'P' --S For Strategic Companion,P For Population
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
DECLARE @v_DenominatorType VARCHAR(1)
	,@i_ManagedPopulationID INT

SELECT @v_DenominatorType = m.DenominatorType
	,@i_ManagedPopulationID = m.ManagedPopulationID
FROM Metric m
WHERE m.MetricId = @MetricID

CREATE TABLE #PDNR (
	PatientID INT
	,[Count] INT
	,IsIndicator BIT
	)

IF @v_DenominatorType = 'M'
	AND @i_ManagedPopulationID IS NOT NULL
BEGIN
	INSERT INTO #PDNR
	SELECT DISTINCT [PatientID]
		,1 AS 'Count'
		,1 AS 'IsIndicator'
	FROM (
		/* Retrieves Patients with Performed Procedures with Procedure Codes during the Measurement Period. */
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure_SelectedPopulation_MP('CHL-C', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @i_ManagedPopulationID, @ReportType)
		
		UNION
		
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_LabData_SelectedPopulation_MP('CHL-C', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @i_ManagedPopulationID, @ReportType)
		) P
END
ELSE
BEGIN
	INSERT INTO #PDNR
	SELECT DISTINCT [PatientID]
		,1 AS 'Count'
		,1 AS 'IsIndicator'
	FROM (
		/* Retrieves Patients with Performed Procedures with Procedure Codes during the Measurement Period. */
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure_SelectedPopulation('CHL-C', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)
		
		UNION
		
		SELECT DISTINCT [PatientID]
			,1 AS 'Count'
			,1 AS 'IsIndicator'
		FROM dbo.ufn_HEDIS_GetPatients_LabData_SelectedPopulation('CHL-C', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)
		) P
END

DECLARE @DateKey INT

SET @DateKey = (CONVERT(VARCHAR, @AnchorDate_Year) + RIGHT('0' + CAST(@AnchorDate_Month AS VARCHAR), 2) + RIGHT('0' + CAST(@AnchorDate_Day AS VARCHAR), 2))

--SET @DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day) 

	MERGE NRPatientCount AS T
	USING (
		SELECT @MetricID AS MetricID
			--,@i_NrID AS NrID
			,PatientID
			,[Count] Cnt
			,IsIndicator
			,@DateKey DateKey
		FROM #PDNR
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
				--,NRDefID
				,PatientID
				,Count
				,IsIndicator
				,CreatedByUserId
				,DateKey
				)
			VALUES (
				S.MetricID
				--,S.NrID
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
				,T.IsIndicator = S.IsIndicator
	WHEN NOT MATCHED BY SOURCE
		AND EXISTS (
			SELECT 1
			FROM #PDNR c
			WHERE t.MetricID = @MetricID
				AND t.DateKey = @DateKey
			)
		THEN
			DELETE;

	DECLARE @i_cnt INT

	SELECT @i_cnt = COUNT(*)
	FROM #PDNR

	IF @i_cnt = 0
	BEGIN
		DELETE
		FROM NRPatientCount
		WHERE MetricID = @MetricID
			AND DateKey = @DateKey
	END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_CHL_GetNumerator_Testing_Indicator_2012] TO [FE_rohit.r-ext]
    AS [dbo];

