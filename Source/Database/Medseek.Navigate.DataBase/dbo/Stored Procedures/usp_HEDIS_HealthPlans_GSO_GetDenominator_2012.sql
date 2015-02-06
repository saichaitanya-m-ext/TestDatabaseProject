CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_GSO_GetDenominator_2012] (
	@PopulationDefinitionID INT
	,@InsuranceProductTypes VARCHAR(30) = 'M'
	,@InsurancePlanTypes VARCHAR(1000) = NULL
	,@InsuranceBenefitTypes VARCHAR(1000) = 'Major Medical (MM)'
	,@AnchorDate_Year INT = 2012
	,@AnchorDate_Month INT = 12
	,@AnchorDate_Day INT = 31
	,@IsPrimary BIT = 1
	,@Num_Months_Prior_EligiblePop INT = 0
	,@Num_Months_After_EligiblePop INT = 0
	,@EligibleAge_MIN INT = 67
	,@EligibleAge_MAX INT = NULL
	,@NumMonths_Prior_Insured_Commercial INT = 12
	,@NumMonths_After_Insured_Commercial INT = 0
	,@NumMonths_Prior_Insured_Medicare INT = 12
	,@NumMonths_After_Insured_Medicare INT = 0
	,@NumMonths_Prior_Insured_Medicaid INT = 12
	,@NumMonths_After_Insured_Medicaid INT = 0
	,@Enrollment_AllowedNumGaps_Commercial INT = 1
	,@Enrollment_MAXDaysPerGap_Commercial INT = 45
	,@Enrollment_AllowedNumGaps_Medicare INT = 1
	,@Enrollment_MAXDaysPerGap_Medicare INT = 45
	,@Enrollment_AllowedNumGaps_Medicaid INT = 1
	,@Enrollment_MAXDaysPerGap_Medicaid INT = 30
	,@Num_Months_Prior_Encounters INT = 24
	,@Num_Months_After_Encounters INT = 0
	,@Num_Encounters_Outpatient_NonAcuteInPatient INT = 2
	,@Num_Encounters_AcuteInpatient_ED INT = 1
	,@Num_Months_Prior_Rx INT = 24
	,@Num_Months_After_Rx INT = 0
	,@Num_Rx_Dispense INT = 1
	,@IsDeceased BIT = 0
	,@InsuranceGroupStatus VARCHAR(1) = 'A'
	,@InsurancePlanStatus VARCHAR(1) = 'A'
	,@InsurancePolicyStatus VARCHAR(1) = 'A'
	,@PatientStatus VARCHAR(1) = 'A'
	,@ECTCodeVersion_Year INT = 2012
	,@ECTCodeStatus VARCHAR(1) = 'A'
	)
AS
/************************************************************ INPUT PARAMETERS ************************************************************  
  
  @InsuranceProductTypes = Types of Insurance Products that Insureds selected for inclusion in Eligible Population can have.  One (1) or  
         more Types of Insurance Products can be specified to determine Insureds to include in the Eligible Population.  
         Multiple Insurance Product Type specifications are separated by a ','.  
         Examples:  'C' (for 'Commercial'); 'M' (for 'Medicare'); 'I' (for 'Medicaid');  
           'C, M' (for 'Commercial' or 'Medicare'); 'C, M, I' (for 'Commercial', 'Medicare', or 'Medicaid'), etc.  
  
  @InsurancePlanTypes = Types of Insurance Plan that Insureds selected for inclusion in Eligible Population can have.  One (1) or more  
         Types of Insurance Plan can be specified to determine Insureds to include in the Eligible Population.  Multiple  
         Insurance Plan Type specifications are separated by a ','.  
         Examples:  'HMO'; 'PPO'; 'Medicare Part A'; 'Medicaid'; 'HMO, PPO'; 'HMO, PPO, Medicare Part A, Medicaid'; etc.  
  
  @InsuranceBenefitTypes = Types of Insurance Benefit that Insureds selected for inclusion in Eligible Population must have.  One (1) or  
         more Types of Insurance Benefit can be specified which an Insured MUST have to be include in the Eligible  
         Population.  Multiple Insurance Benefit Type specifications are separated by a ','.  
         Examples:  'Major Medical'; 'Prescription Drug (RX)'; 'Dental (DE)'; 'Vision (VI)';  
           'Major Medical (MM), Prescription Drug (RX)'; 'Major Medical (MM), Prescription Drug (RX), Dental (DE)';  
           'Major Medical (MM), Prescription Drug (RX), Dental (DE), Vision (VI)'; etc.  
  
  @AnchorDate_Year = Year of the Anchor Date for which Eligible Population is to be constructed.  
  
  @AnchorDate_Month = Month of the Anchor Date for which Eligible Population is to be constructed.  
  
  @AnchorDate_Day = Day in the Month of the Anchor Date for which Eligible Population is to be constructed.  
  
  @Num_Months_Prior_EligiblePop = Number of Months Before the Anchor Date from which Age-Eligible Population is to be constructed.  
  
  @Num_Months_After_EligiblePop = Number of Months After the Anchor Date from which Age-Eligible Population is to be constructed.  
  
  @EligibleAge_MIN = Minimum Age at which an Insured can be included in the Eligible Population.  
  
  @EligibleAge_MAX - Maximum Age at which an Insured can be included in the Eligible Population.  
  
   @NumMonths_Prior_Insured_Commercial = Number of Months Prior to the Anchor Date from which Eligible Population of Insureds for an Insurance  
             Product of Type "Commercial" is to be constructed.  
  
  @NumMonths_After_Insured_Commercial = Number of Months After the Anchor Date from which Eligible Population of Insureds for an Insurance  
             Product of Type "Commercial" is to be constructed.  
  
  @NumMonths_Prior_Insured_Medicare = Number of Months Prior to the Anchor Date from which Eligible Population of Insureds for an Insurance  
           Product of Type "Medicare" is to be constructed.  
  
  @NumMonths_After_Insured_Medicare = Number of Months After the Anchor Date from which Eligible Population of Insureds for an Insurance  
           Product of Type "Medicare" is to be constructed.  
  
  @NumMonths_Prior_Insured_Medicaid = Number of Months Prior to the Anchor Date from which Eligible Population of Insureds for an Insurance  
           Product of Type "Medicaid" is to be constructed.  
  
  @NumMonths_After_Insured_Medicaid = Number of Months After the Anchor Date from which Eligible Population of Insureds for an Insurance  
           Product of Type "Medicaid" is to be constructed.  
  
  
  @Enrollment_AllowedNumGaps_Commercial = Maximum number of 'Allowable Number of Gaps in Coverage Enrollment' for a specified Insurance  
            Benefit on an Insurance Policy of Type "Commercial" Insurance Product by an Insured.  
  
  @Enrollment_MAXDaysPerGap_Commercial = Maximum number of 'Allowable Number of Days During a Gap in Coverage Enrollment' for a specified  
           Insurance Benefit on an Insurance Policy of Type "Commercial" Insurance Product by an Insured.  
  
  @Enrollment_AllowedNumGaps_Medicare = Maximum number of 'Allowable Number of Gaps in Coverage Enrollment' for a specified Insurance  
             Benefit on an Insurance Policy of Type "Medicare" Insurance Product by an Insured.  
  
  @Enrollment_MAXDaysPerGap_Medicare = Maximum number of 'Allowable Number of Days During a Gap in Coverage Enrollment' for a specified  
            Insurance Benefit on an Insurance Policy of Type "Medicare" Insurance Product by an Insured.  
  
  @Enrollment_AllowedNumGaps_Medicaid = Maximum number of 'Allowable Number of Gaps in Coverage Enrollment' for a specified Insurance  
             Benefit on an Insurance Policy of Type "Medicaid" Insurance Product by an Insured.  
  
  @Enrollment_MAXDaysPerGap_Medicaid = Maximum number of 'Allowable Number of Days During a Gap in Coverage Enrollment' for a specified  
            Insurance Benefit on an Insurance Policy of Type "Medicaid" Insurance Product by an Insured.  
  
  
  
  @Num_Months_Prior_Insureds = Number of Months Before the Anchor Date from which Eligible Population of Insureds is to be constructed.  
  
  @Num_Months_After_Insureds = Number of Months After the Anchor Date from which Eligible Population of Insured is to be constructed.  
  
  @IsPrimary = Specification of whether an Insurance Benefit is Primary for an Insured.  Examples:  1 (for 'Yes'), or 0 (for 'No').  
  
  @Enrollment_AllowedNumGaps = Maximum number of allowable number of Gaps in Coverage Enrollment for a specified Insurance Benefit on a  
          Commercial Insurance Policy by an Insured.  
  
  @Enrollment_MAXDaysPerGap = Maximum number of allowable number of days during any given Gap in Coverage Enrollment for a specified  
         Insurance Benefit on a Commercial Insurance Policy by an Insured.  
  
  @Enrollment_Medicaid_AllowedNumGaps = Maximum number of allowable number of Gaps in Coverage Enrollment for a specified Insurance Benefit  
             on a Medicaid Insurance Policy by an Insured.  
  
  @Enrollment_Medicaid_MAXDaysPerGap = Maximum number of allowable number of days during any given Gap in Coverage Enrollment for a specified  
            Insurance Benefit on a Medicaid Insurance Policy by an Insured.  
  
  @IsDeceased = Specification of the Death Status of an Insured.  Examples = 1 (for 'Yes') or 0 (for 'No').  
  
  @InsuranceGroupStatus = Status of the Insurance Group with which Insureds included in the Eligible Population have Insurance Policy during  
        the Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').  
  
  @InsurancePlanStatus = Status of the Insurance Plan that Insureds subcribe to be included in the Eligible Population during the  
       Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').  
  
  @InsurancePolicyStatus = Status of the Insurance Policy under which an Insured receives Insurance Benefit that qualifies an Insured for  
         inclusion in the Eligible Population during the Measurment.  
         Examples:  1 (for 'Enabled') or 0 (for 'Disabled').  
  
  @PatientStatus = Status of the Patient in the System for the Insured to be included in the Eligible Population of Insureds during the  
       Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').  
  
  @ECTCodeVersion_Year = Code Version Year from which valid HEDIS-associated ECT and Drug Codes during the Measurement Period that are  
          retrieved to identify Patients for inclusion in the Eligible Population of Patients.  
  
  @ECTCodeStatus = Status of valid HEDIS-associated ECT and Drug Codes during the Measurement Period that are retrieved to identify Patients  
       for inclusion in the Eligible Population of Patients during the Measurement Period.  
       Examples = 1 (for 'Enabled') or 0 (for 'No').  
  
  *********************************************************************************************************************************************/
/* Checks for existence of user-defined Table Type "tblLookupTable_String".  The Table Type is created  
   if it does not exist.  The Table Type is used to create Table variables that store String element values.   */
IF NOT EXISTS (
		SELECT *
		FROM [sys].[types]
		WHERE ([is_table_type] = 1)
			AND ([Name] = 'tblListTable_String')
		)
BEGIN
	CREATE TYPE [tblListTable_String] AS TABLE ([ElementVal] VARCHAR(900) NOT NULL PRIMARY KEY CLUSTERED)
END

/* Temporary Table to store 'Patient IDs' of Patients in the Eligible Population of Insureds. */
CREATE TABLE #GSO_Insureds_Eligible_CurrentYear ([PatientID] INT PRIMARY KEY CLUSTERED)

/* Temporary Table to store 'Patient IDs' of Patients in the Eligible Population of Insureds. */
CREATE TABLE #GSO_Insureds_Eligible_PriorYear ([PatientID] INT PRIMARY KEY CLUSTERED)

/* Retrieves the 'Patient IDs' of Patients in the Eligible Population of Insureds, and store the 'Patient IDs'  
   in the created Temporary table. */
INSERT INTO #GSO_Insureds_Eligible_CurrentYear
EXEC dbo.usp_HEDIS_HealthPlans_GetInsureds_2012 @InsuranceProductTypes
	,@InsurancePlanTypes
	,@InsuranceBenefitTypes
	,@AnchorDate_Year
	,@AnchorDate_Month
	,@AnchorDate_Day
	,@IsPrimary
	,@NumMonths_Prior_Insured_Commercial
	,@NumMonths_After_Insured_Commercial
	,@NumMonths_Prior_Insured_Medicare
	,@NumMonths_After_Insured_Medicare
	,@NumMonths_Prior_Insured_Medicaid
	,@NumMonths_After_Insured_Medicaid
	,@Enrollment_AllowedNumGaps_Commercial
	,@Enrollment_MAXDaysPerGap_Commercial
	,@Enrollment_AllowedNumGaps_Medicare
	,@Enrollment_MAXDaysPerGap_Medicare
	,@Enrollment_AllowedNumGaps_Medicaid
	,@Enrollment_MAXDaysPerGap_Medicaid
	,@InsuranceGroupStatus
	,@InsurancePlanStatus
	,@InsurancePolicyStatus

INSERT INTO #GSO_Insureds_Eligible_PriorYear
EXEC dbo.usp_HEDIS_HealthPlans_GetInsureds_2012 @InsuranceProductTypes
	,@InsurancePlanTypes
	,@InsuranceBenefitTypes
	,@AnchorDate_Year
	,@AnchorDate_Month
	,@AnchorDate_Day
	,@IsPrimary
	,@NumMonths_Prior_Insured_Commercial
	,@NumMonths_After_Insured_Commercial
	,@NumMonths_Prior_Insured_Medicare
	,@NumMonths_After_Insured_Medicare
	,@NumMonths_Prior_Insured_Medicaid
	,@NumMonths_After_Insured_Medicaid
	,@Enrollment_AllowedNumGaps_Commercial
	,@Enrollment_MAXDaysPerGap_Commercial
	,@Enrollment_AllowedNumGaps_Medicare
	,@Enrollment_MAXDaysPerGap_Medicare
	,@Enrollment_AllowedNumGaps_Medicaid
	,@Enrollment_MAXDaysPerGap_Medicaid
	,@InsuranceGroupStatus
	,@InsurancePlanStatus
	,@InsurancePolicyStatus

SELECT DISTINCT p.[PatientID],
--(CONVERT(VARCHAR, @AnchorDate_Year) + '-' + CONVERT(VARCHAR, @AnchorDate_Month) + '-' + CONVERT(VARCHAR, @AnchorDate_Day)) 
(CONVERT(varchar, @AnchorDate_Year) + '-' + RIGHT('0'+CAST(@AnchorDate_Month AS VARCHAR),2) + '-' + RIGHT('0'+CAST(@AnchorDate_Day AS VARCHAR),2)) AS 'AnchorDateOUT'
INTO #PDDR
FROM (
	-- Retrieves the 'Patient IDs' of Patients in the Age-Eligible Population during the Measurement Period. --  
	SELECT [PatientID]
	FROM dbo.ufn_GetAgeEligiblePopulation(@AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @Num_Months_Prior_EligiblePop, @Num_Months_After_EligiblePop, @EligibleAge_MIN, @EligibleAge_MAX, @IsDeceased, @PatientStatus)
	
	INTERSECT
	
	(
		-- Retrieves Eligible Insureds with required Insurance Coverage/Coverage Gaps during Measurement Period. --  
		SELECT [PatientID]
		FROM #GSO_Insureds_Eligible_CurrentYear
		
		INTERSECT
		
		-- Retrieves Eligible Insureds with required Insurance Coverage/Coverage Gaps during prior Measurement Period. --  
		SELECT [PatientID]
		FROM #GSO_Insureds_Eligible_PriorYear
		)
	) AS p

--UPDATE PopulationDefinitionPatients
--SET StatusCode = 'P'
--	,EndDate = GETDATE()
--WHERE PopulationDefinitionID = @PopulationDefinitionID
--	AND LeaveInList <> 1
--	AND NOT EXISTS (
--		SELECT 1
--		FROM #PDDR usr
--		WHERE usr.PatientID = PopulationDefinitionPatients.PatientID
--		)

UPDATE PopulationDefinitionPatients
SET StatusCode = 'A'
	--,EndDate = NULL
WHERE PopulationDefinitionID = @PopulationDefinitionID
	--AND LeaveInList <> 1
	AND EXISTS (
		SELECT 1
		FROM #PDDR usr
		WHERE usr.PatientID = PopulationDefinitionPatients.PatientID
		)
	--AND StatusCode = 'P'

INSERT INTO PopulationDefinitionPatients (
	PopulationDefinitionID
	,PatientID
	,StatusCode
	,LeaveInList
	,CreatedByUserId
	--,StartDate
	)
SELECT @PopulationDefinitionID
	,usr.PatientID
	,'A'
	,0
	,1
	--,GETDATE()
FROM #PDDR usr
WHERE NOT EXISTS (
		SELECT 1
		FROM PopulationDefinitionPatients
		WHERE PopulationDefinitionPatients.PopulationDefinitionID = @PopulationDefinitionID
			AND PopulationDefinitionPatients.PatientID = usr.PatientID
		)

alter table #PDDR add PopulationDefinitionPatientID INT
		UPDATE #PDDR
	SET PopulationDefinitionPatientID = PopulationDefinitionPatients.PopulationDefinitionPatientID
	FROM PopulationDefinitionPatients
	WHERE PopulationDefinitionPatients.PopulationDefinitionID = @PopulationDefinitionID
		AND PopulationDefinitionPatients.PatientID = #PDDR.PatientID
declare @v_DateKey int = (CONVERT(varchar, @AnchorDate_Year) +  RIGHT('0'+CAST(@AnchorDate_Month AS VARCHAR),2) + RIGHT('0'+CAST(@AnchorDate_Day AS VARCHAR),2))
--declare @v_DateKey int = (CONVERT(VARCHAR, @AnchorDate_Year)  + CASE WHEN LEN(@AnchorDate_Month) =1 THEN  '0'+ CONVERT(VARCHAR, @AnchorDate_Month) ELSE CONVERT(VARCHAR, @AnchorDate_Month) END + CASE WHEN LEN(@AnchorDate_Day) = 1 THEN '0'+CONVERT(VARCHAR, @AnchorDate_Day) ELSE CONVERT(VARCHAR, @AnchorDate_Day) END)
DELETE
		FROM PopulationDefinitionPatientAnchorDate
		WHERE EXISTS (
				SELECT 1
				FROM PopulationDefinitionPatients pdp
				WHERE pdp.PopulationDefinitionPatientID = PopulationDefinitionPatientAnchorDate.PopulationDefinitionPatientID
					AND pdp.PopulationDefinitionID = @PopulationDefinitionID
				)
			AND DateKey = @v_DateKey
MERGE PopulationDefinitionPatientAnchorDate AS t
	USING (
		SELECT PopulationDefinitionPatientID,AnchorDateOUT
		FROM #PDDR
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
				,AnchorDateOUT 
				);
	--WHEN MATCHED
	--	THEN
	--		UPDATE
	--		SET t.StatusCode = 'A',
	--		t.OutPutAnchorDate = s.AnchorDateOUT;
		--	WHEN NOT MATCHED BY SOURCE
		--AND EXISTS (
		--	SELECT 1
		--	FROM #PDDR p
		--	WHERE p.PopulationDefinitionPatientID <> t.PopulationDefinitionPatientID
		--		AND t.DateKey = CONVERT(INT, @v_DateKey)
		--	)
		--THEN
		--	DELETE;		
		--DELETE FROM PopulationDefinitionPatientAnchorDate
		--	WHERE PopulationDefinitionPatientID IN (
		--	SELECT DISTINCT pdp.PopulationDefinitionPatientID
		--	  FROM PopulationDefinitionPatients pdp
		--	INNER JOIN PopulationDefinitionPatientAnchorDate pdpad
		--	ON pdpad.PopulationDefinitionPatientID = pdp.PopulationDefinitionPatientID
		--	LEFT JOIN #PDDR t
		--	ON t.PopulationDefinitionPatientID = pdp.PopulationDefinitionPatientID
		--	WHERE pdp.PopulationDefinitionID = @PopulationDefinitionID  
		--	AND pdpad.DateKey = @v_DateKey
		--	AND t.PopulationDefinitionPatientID IS NULL)
		--	AND DateKey = @v_DateKey			

SELECT COUNT(*)
FROM #PDDR

DROP TABLE #GSO_Insureds_Eligible_CurrentYear;

DROP TABLE #GSO_Insureds_Eligible_PriorYear;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_GSO_GetDenominator_2012] TO [FE_rohit.r-ext]
    AS [dbo];

