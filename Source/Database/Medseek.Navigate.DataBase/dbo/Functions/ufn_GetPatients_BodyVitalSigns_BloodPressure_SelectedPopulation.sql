CREATE FUNCTION [dbo].[ufn_GetPatients_BodyVitalSigns_BloodPressure_SelectedPopulation] (
	@PopulationDefinitionID INT
	,@AnchorYear_NumYearsOffset INT
	,@Num_Months_Prior INT
	,@Num_Months_After INT
	,@AnchorDate_Year INT = 2012
	,@AnchorDate_Month VARCHAR(2) = 12
	,@AnchorDate_Day VARCHAR(2) = 31
	,@c_ReportType CHAR(1)='P'-- P For Population,S for stategic
	)
RETURNS @OutPut TABLE
(  PatientID INT
  ,Systolic  numeric(5,0)
  ,Diastolic  numeric(5,0)
  ,ReadingTime DATETIME
)
 
BEGIN	
		/************************************************************ INPUT PARAMETERS ************************************************************  
  
  @ECTTableName = Name of the ECT Table containing LOINC Codes to be used for selection of Patients for inclusion in the Eligible  
      Population of Patients with qualifying Lab Data are to be drawn or selected from.  
  
  @PopulationDefinitionID = Handle to the selected Population of Patients from which the Eligible Population of Patients of the Numerator  
          are to be constructed.  
  
  @AnchorYear_NumYearsOffset = Number of Years of OFFSET -- After (+) or Before (-) -- from the Anchor Year around which the Patients in the  
          selected Population was chosen, serving as the new Anchor Year around which the Eligible Population of  
          Patients is to be constructed.  
  
  @Num_Months_Prior = Number of Months Before the Anchor Date from which Eligible Population of Patients with Encounters/Event Diagnoses  
       is to be constructed.  
  
  @Num_Months_After = Number of Months After the Anchor Date from which Eligible Population of Patients with Encounters/Diagnoses  
       is to be constructed.  
  
  @ECTCodeVersion_Year = Code Version Year from which HEDIS-associated ECT Codes (e.g. ICD-9-CM, ICD-10-CM, etc.) that are to be used to  
       select Patients for inclusion in the Eligible Population of Patients, with health claims for Encounters/Event  
       Diagnoses that are for Diseases and Health Conditions associated with the Measure, to be constructed for the  
       Measurement Period.  
  
  @ECTCodeStatus = Status of HEDIS-associated ECT Codes (e.g. ICD-9-CM, ICD-10-CM, etc.) that are to be used to select Patients for inclusion  
       in the Eligible Population of Patients, with health claims for Encounters/Event Diagnoses that are for Diseases and Health  
       Conditions associated with the Measure, to be constructed for the Measurement Period.  
       Examples = 'A' (for 'Active') or 'I' (for 'Inactive').  
  
  *********************************************************************************************************************************************/
	
	
	   INSERT INTO @OutPut
		SELECT DISTINCT pm.PatientID
			,pm.SystolicValue Systolic
			,pm.DiastolicValue Diastolic
			,pm.MeasurementTime ReadingTime
		FROM [dbo].[PatientVitalSignBloodPressure] pm
		INNER JOIN [dbo].[PopulationDefinitionPatients] p
			ON p.[PatientID] = pm.[PatientID]
		INNER JOIN PopulationDefinitionPatientAnchorDate pdpa
			ON pdpa.PopulationDefinitionPatientID = p.PopulationDefinitionPatientID
		WHERE (
				pm.[MeasurementTime] BETWEEN (DATEADD(YYYY, - @Num_Months_Prior, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pdpa.OutPutAnchorDate)))
					AND (DATEADD(YYYY, @Num_Months_After, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pdpa.OutPutAnchorDate)))
				)
			AND P.PopulationDefinitionID = @PopulationDefinitionID
			AND pdpa.DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day)
	
	/*
	ELSE 
	BEGIN
	  INSERT INTO @OutPut
		SELECT DISTINCT pm.PatientID
			,pm.SystolicValue Systolic
			,pm.DiastolicValue Diastolic
			,pm.MeasurementTime ReadingTime
		FROM [dbo].[PatientVitalSignBloodPressure] pm
		INNER JOIN [dbo].[PatientDr] p
			ON p.[PatientID] = pm.[PatientID]
		WHERE (
				pm.[MeasurementTime] BETWEEN (DATEADD(YYYY, - @Num_Months_Prior, DATEADD(YYYY, @AnchorYear_NumYearsOffset, p.OutPutAnchorDate)))
					AND (DATEADD(YYYY, @Num_Months_After, DATEADD(YYYY, @AnchorYear_NumYearsOffset, p.OutPutAnchorDate)))
				)
			AND P.DrId = @PopulationDefinitionID
			AND p.DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day)
	END
	*/
RETURN
END
