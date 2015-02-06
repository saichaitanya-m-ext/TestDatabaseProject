CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_GSO_GetNumerator_EyeExam_Testing_Indicator_2012] (
	@PopulationDefinitionID INT
	,@MetricID INT
	,@Num_Months_Prior INT = 24
	,@Num_Months_After INT = 0
	,@ECTCodeVersion_Year INT = 2012
	,@ECTCodeStatus VARCHAR(1) = 'A'
	,@AnchorDate_Year INT = 2012
	,@AnchorDate_Month VARCHAR(2) = 12
	,@AnchorDate_Day VARCHAR(2) = 31
	,@ReportType CHAR(1) = 'P' --P for Population S for Stategic
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
/* Retrieves Patients with Performed Procedures with Procedure Codes during the  
   Measurement Period. */
CREATE TABLE #PDNR (
	PatientId INT
	,Count INT
	,IsIndicator BIT
	)

CREATE TABLE #NR (
	MetricId INT
	,NumeratorID INT
	,NumeratorType VARCHAR(1)
	)

INSERT INTO #PDNR
SELECT P.[PatientID]
	,1 AS 'Count'
	,1 AS 'IsIndicator'
FROM (
	SELECT DISTINCT [PatientID]
		,1 AS 'Count'
		,1 AS 'IsIndicator'
	FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure_SelectedPopulation('GSO-A', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)
	
	UNION
	
	/* Retrieves Patients with Performed Procedures with Procedure Codes during the  
   Year Prior to the Measurement Period. */
	SELECT DISTINCT [PatientID]
		,1 AS 'Count'
		,1 AS 'IsIndicator'
	FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure_SelectedPopulation('GSO-A', @PopulationDefinitionID, - 1, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)
	) P

INSERT INTO #NR
SELECT DISTINCT m.MetricId
	,m.NumeratorID
	,nr.NumeratorType
--,nrc.PopulationDefinitionCriteriaSQL NrSQL    
FROM Metric m
INNER JOIN PopulationDefinition nr ON m.NumeratorID = nr.PopulationDefinitionID
--INNER JOIN PopulationDefinitionCriteria nrc    
-- ON nrc.PopulationDefinitionID = nr.PopulationDefinitionID    
WHERE m.DenominatorType <> 'M' --> Means either Condition or PD    
	AND nr.DefinitionType = 'N' --> only getting Numerators from PD table    
	AND m.DenominatorID = @PopulationDefinitionID
	--AND nrc.PopulationDefPanelConfigurationID = 75 --> Build definition    
	AND MetricId = @MetricID

IF EXISTS (
		SELECT 1
		FROM #NR
		GROUP BY MetricId
		HAVING COUNT(*) > 1
		)
BEGIN
	RETURN 0
END
ELSE
BEGIN
	DECLARE @v_NumeratorType VARCHAR(1)
		,@i_NrID INT

	SELECT @v_NumeratorType = NumeratorType
		,@i_NrID = NumeratorID
	FROM #NR

	IF @v_NumeratorType = 'C'
	BEGIN
		DECLARE @DateKey INT

		SET @DateKey = (CONVERT(VARCHAR, @AnchorDate_Year) + '-' + RIGHT('0' + CAST(@AnchorDate_Month AS VARCHAR), 2) + '-' + RIGHT('0' + CAST(@AnchorDate_Day AS VARCHAR), 2))
		SET @DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day)

		IF @ReportType = 'P'
		BEGIN
			MERGE NRPatientCount AS T
			USING (
				SELECT @MetricID AS MetricID
					,@i_NrID AS NrID
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
						,NRDefID
						,PatientID
						,Count
						,IsIndicator
						,CreatedByUserId
						,DateKey
						)
					VALUES (
						S.MetricID
						,S.NrID
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
			WHEN NOT MATCHED BY SOURCE
				AND EXISTS (
					SELECT 1
					FROM #PDNR c
					WHERE t.MetricID = @MetricID
						AND c.PatientId <> t.PatientID
						AND t.DateKey = @DateKey
					)
				THEN
					DELETE;
						----UPDATE NRPatientCount
						--	--SET Count = nrc.Cnt
						--	--	,IsIndicator = nrc.IsIndicator
						--	--	,EndDate = NULL
						--	--FROM #NRCnt nrc
						--	--WHERE nrc.PatientID = NRPatientCount.PatientID
						--	--	AND NRPatientCount.MetricID = @MetricID
						--	INSERT INTO NRPatientCount (
						--		MetricID
						--		,NRDefID
						--		,PatientID
						--		,Count
						--		,IsIndicator
						--		,CreatedByUserId
						--		,CreatedDate
						--		,DateKey
						--		)
						--	SELECT @MetricID
						--		,@i_NrID
						--		,PatientID
						--		,Cnt
						--		,IsIndicator
						--		,1
						--		,GETDATE()
						--		,CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10),@AnchorDate_Month) + CONVERT(VARCHAR(10),@AnchorDate_Day)
						--	FROM #NRCnt nrcnt
						--	WHERE NOT EXISTS (
						--			SELECT 1
						--			FROM NRPatientCount nr
						--			WHERE nr.PatientID = nrcnt.PatientID
						--				AND nr.MetricID = @MetricID
						--			)
						--	UPDATE NRPatientCount
						--	SET EndDate = GETDATE()
						--	WHERE MetricID = @MetricID
						--		AND NOT EXISTS (
						--			SELECT 1
						--			FROM #NRCnt nrc
						--			WHERE nrc.PatientID = NRPatientCount.PatientID
						--			)
		END
		ELSE
		BEGIN
			DELETE
			FROM PatientNr
			WHERE MetricId = @MetricID
				AND DateKey = @DateKey

			INSERT INTO PatientNr (
				MetricId
				,PatientID
				,DateKey
				,Cnt
				,CreatedDate
				,NrType
				,IsIndicator
				)
			SELECT @MetricID
				,PatientID
				,@DateKey
				,[Count]
				,GETDATE()
				,'C'
				,IsIndicator
			FROM #PDNR
		END
	END
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_GSO_GetNumerator_EyeExam_Testing_Indicator_2012] TO [FE_rohit.r-ext]
    AS [dbo];

