
      
      
CREATE PROCEDURE [dbo].[usp_Non-HEDIS-L_HealthPlans_ASTH_GetDenominator_2012]     
(      
    @PopulationDefinitionID INT,      
 @InsuranceProductTypes varchar(30) = 'C, I',      
 @InsurancePlanTypes varchar(1000) = NULL,      
 @InsuranceBenefitTypes varchar(1000) = 'Major Medical (MM)',      
      
 @AnchorDate_Year int = 2012,      
 @AnchorDate_Month int = 12,      
 @AnchorDate_Day int = 31,      
      
 @IsPrimary bit = 1,      
      
 @Num_Months_Prior_EligiblePop int = 0,      
 @Num_Months_After_EligiblePop int = 0,      
      
 @EligibleAge_MIN int = 5,      
 @EligibleAge_MAX int = 64,      
      
 @NumMonths_Prior_Insured_Commercial int = 12,      
 @NumMonths_After_Insured_Commercial int = 0,      
      
 @NumMonths_Prior_Insured_Medicare int = 12,      
 @NumMonths_After_Insured_Medicare int = 0,      
      
 @NumMonths_Prior_Insured_Medicaid int = 12,      
 @NumMonths_After_Insured_Medicaid int = 0,      
      
 @Enrollment_AllowedNumGaps_Commercial int = 1,      
 @Enrollment_MAXDaysPerGap_Commercial int = 45,      
      
 @Enrollment_AllowedNumGaps_Medicare int = 1,      
 @Enrollment_MAXDaysPerGap_Medicare int = 45,      
      
 @Enrollment_AllowedNumGaps_Medicaid int = 1,      
 @Enrollment_MAXDaysPerGap_Medicaid int = 30,      
      
 @Num_Months_Prior_Encounters int = 24,      
 @Num_Months_After_Encounters int = 0,      
      
 @Num_Encounters_Outpatient_NonAcuteInPatient int = 2,      
 @Num_Encounters_AcuteInpatient_ED int = 1,      
      
 @Num_Months_Prior_Rx int = 24,      
 @Num_Months_After_Rx int = 0,      
      
 @Num_Rx_Dispense int = 1,      
      
 @IsDeceased bit = 0,      
      
 @InsuranceGroupStatus varchar(1) = 'A',      
 @InsurancePlanStatus varchar(1) = 'A',      
 @InsurancePolicyStatus varchar(1) = 'A',      
 @PatientStatus varchar(1) = 'A',      
      
 @ECTCodeVersion_Year int = 2012,      
 @ECTCodeStatus varchar(1) = 'A'      
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
      
  @IsPrimary = Specification of whether an Insurance Benefit is Primary for an Insured.  Examples:  1 (for 'Yes'), or 0 (for 'No').      
      
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
      
      
  @Num_Months_Prior_Encounters = Number of Months Before the Anchor Date from which Eligible Population of Patients with Encounter Claims      
         is to be constructed.      
      
  @Num_Months_After_Encounters = Number of Months After the Anchor Date from which Eligible Population of Patients with Encounter Claims      
         is to be constructed.      
      
  @Num_Encounters_Outpatient_NonAcuteInPatient = Minimum Number of 'OutPatient' and 'Non-Acute Inpatient' Medical Encounters during the      
             Measurement Period that identifies a Patient for inclusion in the Eligible Population of      
             Patients.      
      
  @Num_Encounters_AcuteInpatient_ED = Minimum Number of 'Acute Inpatient' and 'ED' Medical Encounters during the Measurement Period that      
           identifies a Patient for inclusion in the Eligible Population of Patients.      
      
  @Num_Months_Prior_Rx = Number of Months Before the Anchor Date from which Eligible Population of Patients with Pharmacy/Rx Claims is to be      
       constructed.      
      
  @Num_Months_After_Rx = Number of Months After the Anchor Date from which Eligible Population of Patients with Pharmacy/Rx Claims is to be      
       constructed.      
      
  @Num_Rx_Dispense = Minimum Number of Pharmacy/Rx Claims during the Measurement Period that designates a Patient for inclusion in the Eligible      
      Population of Patients.      
      
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
IF NOT EXISTS (SELECT * FROM [sys].[types] WHERE ([is_table_type] = 1) AND ([Name] = 'tblListTable_String'))      
BEGIN      
   CREATE TYPE [tblListTable_String] AS TABLE      
   (      
  [ElementVal] varchar(900) NOT NULL PRIMARY KEY CLUSTERED      
   )      
END      
      
      
/* Temporary Table to store 'Patient IDs' of Patients in the Eligible Population of Insureds. */      
CREATE TABLE #ASTH_Insureds_Eligible      
(      
 [PatientID] int PRIMARY KEY CLUSTERED      
)      
      
/* Temporary Table to store 'Patient IDs' of Patients in the Eligible Population of Patients with required      
   number of Encounters during the Measurement Period. */      
CREATE TABLE #ASTH_Encounters_Eligible      
(      
 [PatientID] int PRIMARY KEY CLUSTERED      
)      
      
/* Temporary Table to store 'Patient IDs' of Patients in the Eligible Population of Patients with required      
   number of Pharmacy/Rx Claims during the Measurement Period. */      
CREATE TABLE #ASTH_Rx_Eligible      
(      
 [PatientID] int PRIMARY KEY CLUSTERED      
)      
      
      
/* Retrieves the 'Patient IDs' of Patients in the Eligible Population of Insureds, and store the 'Patient IDs'      
   in the created Temporary table. */      
INSERT INTO #ASTH_Insureds_Eligible      
EXEC dbo.usp_HEDIS_HealthPlans_GetInsureds_2012 @InsuranceProductTypes, @InsurancePlanTypes, @InsuranceBenefitTypes,      
            @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @IsPrimary,      
            @NumMonths_Prior_Insured_Commercial, @NumMonths_After_Insured_Commercial,      
            @NumMonths_Prior_Insured_Medicare, @NumMonths_After_Insured_Medicare,      
            @NumMonths_Prior_Insured_Medicaid, @NumMonths_After_Insured_Medicaid,      
            @Enrollment_AllowedNumGaps_Commercial, @Enrollment_MAXDaysPerGap_Commercial,      
            @Enrollment_AllowedNumGaps_Medicare, @Enrollment_MAXDaysPerGap_Medicare,      
            @Enrollment_AllowedNumGaps_Medicaid, @Enrollment_MAXDaysPerGap_Medicaid,      
            @InsuranceGroupStatus, @InsurancePlanStatus, @InsurancePolicyStatus      
      
      
/* Retrieves the 'Patient IDs' of Patients in the Eligible Population of Patients with required number      
   of Encounters or Diagnosed Events during the Measurement Period, and store the 'Patient IDs' in the      
   created Temporary table. */      
INSERT INTO #ASTH_Encounters_Eligible      
EXEC dbo.usp_HEDIS_HealthPlans_ASTH_GetPatients_EncouterClaims_2012 @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day,      
                   @Num_Months_Prior_Encounters, @Num_Months_After_Encounters,      
                   @Num_Encounters_Outpatient_NonAcuteInPatient,      
                   @Num_Encounters_AcuteInpatient_ED, @ECTCodeVersion_Year,      
                   @ECTCodeStatus      
      
      
/* Retrieves the 'Patient IDs' of Patients in the Eligible Population of Patients with required number      
   of Pharmacy/Rx Claims during the Measurement Period, and store the 'Patient IDs' in the created Temporary      
   table. */      
INSERT INTO #ASTH_Rx_Eligible      
EXEC dbo.usp_HEDIS_HealthPlans_ASTH_GetPatients_RxClaims_2012 @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day,      
                @Num_Months_Prior_Rx, @Num_Months_After_Rx, @Num_Rx_Dispense,      
                @ECTCodeVersion_Year, @ECTCodeStatus      
      
SELECT p.[PatientID], (CONVERT(varchar, @AnchorDate_Year) + '-' + CONVERT(varchar, @AnchorDate_Month) + '-' + CONVERT(varchar, @AnchorDate_Day)) AS 'AnchorDateOUT'      
INTO #PDDR      
FROM       
(      
  --Retrieves the 'Patient IDs' of Patients in the Age-Eligible Population during the Measurement Period. --      
 --SELECT [PatientID]      
 --FROM dbo.ufn_GetAgeEligiblePopulation(@AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @Num_Months_Prior_EligiblePop,      
 --           @Num_Months_After_EligiblePop, @EligibleAge_MIN, @EligibleAge_MAX, @IsDeceased,      
 --           @PatientStatus)      
      
 --INTERSECT      
      
 ---- Retrieves Eligible Insureds with required Insurance Coverage/Coverage Gaps during Measurement Period. --      
 --SELECT [PatientID]      
 --FROM #ASTH_Insureds_Eligible      
      
 --INTERSECT      
      
 (      
  -- Retrieves Patients with required number of Encounters Claims during Measurement Period.  --      
  SELECT [PatientID]      
  FROM #ASTH_Encounters_Eligible      
      
  UNION      
      
  -- Retrieves Patients with required number of Pharmacy/Rx Claims during Measurement Period.  --      
  SELECT [PatientID]      
  FROM #ASTH_Rx_Eligible      
 )      
) AS p      
UPDATE PopulationDefinitionPatients      
SET StatusCode = 'P'      
 ,EndDate = GETDATE()      
WHERE PopulationDefinitionID = @PopulationDefinitionID      
 AND LeaveInList <> 1      
 AND NOT EXISTS (      
  SELECT 1      
  FROM #PDDR usr      
  WHERE usr.PatientID = PopulationDefinitionPatients.PatientID      
  )      
      
UPDATE PopulationDefinitionPatients      
SET StatusCode = 'A'      
 ,EndDate = NULL      
WHERE PopulationDefinitionID = @PopulationDefinitionID      
 AND LeaveInList <> 1      
 AND EXISTS (      
  SELECT 1      
  FROM #PDDR usr      
  WHERE usr.PatientID = PopulationDefinitionPatients.PatientID      
  )      
 AND StatusCode = 'P'      
      
INSERT INTO PopulationDefinitionPatients (      
 PopulationDefinitionID      
 ,PatientID      
 ,StatusCode      
 ,LeaveInList      
 ,CreatedByUserId      
 ,StartDate      
 ,OutputAnchorDate      
 )      
SELECT @PopulationDefinitionID      
 ,usr.PatientID      
 ,'A'      
 ,0      
 ,1      
 ,GETDATE()      
 ,usr.AnchorDateOUT      
FROM #PDDR usr      
WHERE NOT EXISTS (      
  SELECT 1      
  FROM PopulationDefinitionPatients      
  WHERE PopulationDefinitionPatients.PopulationDefinitionID = @PopulationDefinitionID      
   AND PopulationDefinitionPatients.PatientID = usr.PatientID      
  )      
      
SELECT COUNT(*)      
FROM #PDDR      
DROP TABLE #ASTH_Insureds_Eligible;      
DROP TABLE #ASTH_Encounters_Eligible;      
DROP TABLE #ASTH_Rx_Eligible; 


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Non-HEDIS-L_HealthPlans_ASTH_GetDenominator_2012] TO [FE_rohit.r-ext]
    AS [dbo];

