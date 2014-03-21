CREATE PROCEDURE [dbo].[usp_HEDIS-L_HealthPlans_CDC_GetNumerator_HbA1c_Result_Values_2012] (
	@PopulationDefinitionID INT
	,@MetricID INT
	,@Num_Months_Prior INT = 12
	,@Num_Months_After INT = 0
	,@ECTCodeVersion_Year INT = 2012
	,@ECTCodeStatus VARCHAR(1) = 'A'
	,@AnchorDate_Year INT = 2012
	,@AnchorDate_Month VARCHAR(2) = 12
	,@AnchorDate_Day VARCHAR(2) = 31
	,@ReportType CHAR(1) = 'P' --S For Strategic Companion,P Population
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
/* Retrieves Lab Test Values of Patients with Performed Lab Tests with LOINC Codes during the Measurement Period. */
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
	INSERT INTO #PDNR
	SELECT DISTINCT [PatientID]
		,[MeasureValueNumeric] AS 'Value'
		,[DateTaken] AS 'ValueDate'
		,0 AS 'IsIndicator'
	FROM dbo.ufn_HEDIS_GetPatients_LabData_SelectedPopulation_MP('CDC-D', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @i_ManagedPopulationID, @ReportType)
	ORDER BY [PatientID]
		,[DateTaken]
END
ELSE
BEGIN
	INSERT INTO #PDNR
	SELECT DISTINCT [PatientID]
		,[MeasureValueNumeric] AS 'Value'
		,[DateTaken] AS 'ValueDate'
		,0 AS 'IsIndicator'
	FROM dbo.ufn_HEDIS_GetPatients_LabData_SelectedPopulation('CDC-D', @PopulationDefinitionID, 0, @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus, @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @ReportType)
	ORDER BY [PatientID]
		,[DateTaken]
END

DECLARE @DateKey INT

SET @DateKey = (CONVERT(VARCHAR, @AnchorDate_Year) + RIGHT('0' + CAST(@AnchorDate_Month AS VARCHAR), 2) + RIGHT('0' + CAST(@AnchorDate_Day AS VARCHAR), 2))

--SET @DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day) 
--IF @ReportType = 'P'
--BEGIN
	DELETE
	FROM dbo.NRPatientValue
	WHERE DateKey = @DateKey
		AND MetricID = @MetricID
		
 
 
  INSERT INTO dbo.NRPatientValue (
		MetricID
		,PatientID
		,Value
		,ValueDate
		,IsIndicator
		,DateKey
		,CreatedByUserId
		,CreatedDate
		)
 SELECT @MetricID
		,PatientID
		,Value
		,ValueDate
		,IsIndicator
		,@DateKey
		,1
		,GETDATE()
	FROM 
		#PDNR   ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS-L_HealthPlans_CDC_GetNumerator_HbA1c_Result_Values_2012] TO [FE_rohit.r-ext]
    AS [dbo];

