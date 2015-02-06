CREATE PROCEDURE [dbo].[usp_NonHEDIS-L_HealthPlans_COPD_GetDenominator_2012] (  
 @PopulationDefinitionID INT  
 ,@InsuranceProductTypes VARCHAR(30) = NULL  
 ,@InsurancePlanTypes VARCHAR(1000) = NULL  
 ,@InsuranceBenefitTypes VARCHAR(1000) = 'Major Medical (MM)'  
 ,@AnchorDate_Year INT = 2012  
 ,@AnchorDate_Month INT = 12  
 ,@AnchorDate_Day INT = 31  
 ,@IsPrimary BIT = 1  
 ,@Num_Months_Prior_EligiblePop INT = 0  
 ,@Num_Months_After_EligiblePop INT = 0  
 ,@EligibleAge_MIN INT = 42  
 ,@EligibleAge_MAX INT = 130  
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
    
  @Num_Months_Prior_Encounters = Number of Months Before the Anchor Date from which Eligible Population of Patients with Encounter Claims    
         is to be constructed.    
    
  @Num_Months_After_Encounters = Number of Months After the Anchor Date from which Eligible Population of Patients with Encounter Claims    
         is to be constructed.    
    
  @Num_Encounters_Outpatient_NonAcuteInPatient = Minimum Number of 'OutPatient' and 'Non-Acute Inpatient' Medical Encounters during the    
             Measurement Period that identifies a Patient for inclusion in the Eligible Population of    
             Patients.    
    
  @Num_Encounters_AcuteInpatient_ED = Minimum Number of 'Acute Inpatient' and 'ED' Medical Encounters during the Measurement Period that    
           identifies a Patient for inclusion in the Eligible Population of Patients.    
    
    
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
CREATE TABLE #SPR_Insureds_Eligible ([PatientID] INT PRIMARY KEY CLUSTERED)  
  
/* Temporary Table to store 'Patient IDs' of Patients in the Eligible Population of Patients with required    
   number of Encounters during the Measurement Period. */  
CREATE TABLE #SPR_Encounters_Eligible ([PatientID] INT PRIMARY KEY CLUSTERED)  
  
/* Retrieves the 'Patient IDs' of Patients in the Eligible Population of Insureds, and store the 'Patient IDs'    
   in the created Temporary table. */  
INSERT INTO #SPR_Insureds_Eligible  
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
  
/* Retrieves the 'Patient IDs' of Patients in the Eligible Population of Patients with required number    
   of Encounters or Diagnosed Events during the Measurement Period, and store the 'Patient IDs' in the    
   created Temporary table. */  
INSERT INTO #SPR_Encounters_Eligible  
EXEC dbo.usp_NonHEDIS_HealthPlans_COPD_GetPatients_EncouterClaims_2012 @AnchorDate_Year  
 ,@AnchorDate_Month  
 ,@AnchorDate_Day  
 ,@Num_Months_Prior_Encounters  
 ,@Num_Months_After_Encounters  
 ,@Num_Encounters_Outpatient_NonAcuteInPatient  
 ,@Num_Encounters_AcuteInpatient_ED  
 ,@ECTCodeVersion_Year  
 ,@ECTCodeStatus  
  
SELECT p.[PatientID]  
 ,(CONVERT(VARCHAR, @AnchorDate_Year) + '-' + CONVERT(VARCHAR, @AnchorDate_Month) + '-' + CONVERT(VARCHAR, @AnchorDate_Day)) AS 'AnchorDateOUT'  
INTO #PDDR  
FROM (  
 -- Retrieves the 'Patient IDs' of Patients in the Age-Eligible Population during the Measurement Period. --    
 --SELECT [PatientID]  
 --FROM dbo.ufn_GetAgeEligiblePopulation(@AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @Num_Months_Prior_EligiblePop, @Num_Months_After_EligiblePop, @EligibleAge_MIN, @EligibleAge_MAX, @IsDeceased, @PatientStatus)  
   
 --INTERSECT  
   
 ---- Retrieves Eligible Insureds with required Insurance Coverage/Coverage Gaps during Measurement Period. --    
 --SELECT [PatientID]  
 --FROM #SPR_Insureds_Eligible  
   
 --INTERSECT  
   
 -- Retrieves Patients with required number of Encounters Claims during Measurement Period.  --    
 SELECT [PatientID]  
 FROM #SPR_Encounters_Eligible  
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
  
DROP TABLE #SPR_Insureds_Eligible;  
  
DROP TABLE #SPR_Encounters_Eligible;  

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_NonHEDIS-L_HealthPlans_COPD_GetDenominator_2012] TO [FE_rohit.r-ext]
    AS [dbo];

