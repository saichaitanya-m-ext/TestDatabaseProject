create PROCEDURE [dbo].[usp_HEDIS_HealthPlans_ART_GetPatients_EncouterClaims_2012] (
	@AnchorDate_Year INT = 2012
	,@AnchorDate_Month INT = 12
	,@AnchorDate_Day INT = 31
	,@Num_Months_Prior INT = 11
	,@Num_Months_After INT = 0
	,@Num_Encounters_Outpatient_NonAcuteInPatient INT = 2
	,@Num_Encounters_AcuteInpatient_ED INT = 1
	,@ECTCodeVersion_Year INT = 2012
	,@ECTCodeStatus VARCHAR(1) = 'A'
	)
AS
/************************************************************ INPUT PARAMETERS ************************************************************  
  
  @AnchorDate_Year = Year of the Anchor Date for which Eligible Population is to be constructed.  
  
  @AnchorDate_Month = Month of the Anchor Date for which Eligible Population is to be constructed.  
  
  @AnchorDate_Day = Day in the Month of the Anchor Date for which Eligible Population is to be constructed.  
  
  @Num_Months_Prior = Number of Months Before the Anchor Date from which Eligible Population of Patients with desired Encounter Claims  
       is to be constructed.  
  
  @Num_Months_After = Number of Months After the Anchor Date from which Eligible Population of Patients with desired Encounter Claims  
       is to be constructed.  
  
  @Num_Encounters_Outpatient_NonAcuteInPatient = Number of 'OutPatient' and 'Non-Acute Inpatient' Medical Encounters during the Measurement  
             Period that identifies a Patient for inclusion in the Eligible Population of Patients.  
  
  @Num_Encounters_AcuteInpatient_ED = Number of 'Acute Inpatient' and 'ED' Medical Encounters during the Measurement Period that identifies  
           a Patient for inclusion in the Eligible Population of Patients.  
  
  @ECTCodeVersion_Year = Code Version Year from which valid HEDIS-associated Diagnosis, Procedure, and Revenue Codes are retrieved for use in  
       selection of Patients for inclusion in the Eligible Population of Patients with Encounter Claims during the  
       Measurement Period.  
  
  @ECTCodeStatus = Status of valid HEDIS-associated Diagnosis, Procedure, and Revenue Codes that are retrieved for use in selection of Patients  
       for inclusion in the Eligible Population of Patients with Encounter Claims during the Measurement Period.  
       Examples = 1 (for 'Enabled') or 0 (for 'Disabled').  
  
  *********************************************************************************************************************************************/
DECLARE @PatientID INT

CREATE TABLE [#ECTCodes_ART_Table_B] (
	[ECTCode] VARCHAR(20) NOT NULL
	,[ECTCodeDescription] VARCHAR(255) NOT NULL
	,[ECTTypeCode] VARCHAR(20) NOT NULL
	);

CREATE NONCLUSTERED INDEX [IDX_ECTCodes_ART_Table_B] ON #ECTCodes_ART_Table_B (
	[ECTCode] ASC
	,[ECTCodeDescription] ASC
	,[ECTTypeCode] ASC
	)
	WITH (FILLFACTOR = 90);

CREATE TABLE #ART_Candidate_Patients (
	[PatientID] INT NOT NULL
	,[ClaimInfoID] INT NOT NULL
	,[ClaimLineID] INT NULL
	,[ProcedureCode] VARCHAR(10) NULL
	,[RevenueCode] VARCHAR(10) NULL
	,[BeginServiceDate] DATETIME NULL
	,[EndServiceDate] DATETIME NULL
	);

CREATE CLUSTERED INDEX [IDX_ART_Candidate_Patients] ON #ART_Candidate_Patients (
	[PatientID] ASC
	,[ClaimInfoID] ASC
	,[ClaimLineID] ASC
	,[ProcedureCode] ASC
	,[RevenueCode] ASC
	,[BeginServiceDate] ASC
	,[EndServiceDate] ASC
	)
	WITH (FILLFACTOR = 90);

INSERT INTO #ECTCodes_ART_Table_B
SELECT [ECTCode]
	,[ECTCodeDescription]
	,ECTHedisCodeTypeCode
FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('ART-B', @ECTCodeVersion_Year, @ECTCodeStatus)

--Date Fix for last day of last month
DECLARE @Date VARCHAR(10) = CAST(@AnchorDate_Year AS VARCHAR)+RIGHT('0'+CAST(@AnchorDate_Month AS VARCHAR),2)+'01'
PRINT @Date

SET @Date = CONVERT(varchar(10),DATEADD(DAY,-1,@Date),120)

SET @AnchorDate_Month = MONTH(@Date)
SET @AnchorDate_Day = DAY(@Date)
-----
INSERT INTO #ART_Candidate_Patients
SELECT DISTINCT [PatientID]
	,[ClaimInfoID]
	,[ClaimLineID]
	,[ProcedureCode]
	,[RevenueCode]
	,[BeginServiceDate]
	,[EndServiceDate]
FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByDiagnosis2('ART-A', @AnchorDate_Year, @AnchorDate_Month , @AnchorDate_Day , 
@Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus)

/* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of type 'Out-Patient' and  
   'Non-Acute In-Patient' visits. */
SELECT diag_pat1.[PatientID]
FROM (
	-- Retrieve Patients meeting criteria of having requisite number of Encounter Claims, based on Procedures  
	-- (CPT codes) specified on Medical Claim Forms "UB-04" and "CMS-1500" submitted for Patients.  
	SELECT DISTINCT [PatientID]
		,[ClaimInfoID]
		,[BeginServiceDate]
	FROM #ART_Candidate_Patients
	WHERE [ProcedureCode] IN (
			SELECT [ECTCode]
			FROM #ECTCodes_ART_Table_B
			WHERE ([ECTTypeCode] = 'CPT')
				AND (
					[ECTCodeDescription] IN (
						'Outpatient'
						,'Nonacute inpatient'
						)
					)
			)
	
	UNION
	
	-- Retrieve Patients meeting criteria of having requisite number of Encounter Claims, based on Revenue Codes  
	-- specified on Medical Claim Forms "UB-04" submitted for Patients.  
	SELECT DISTINCT [PatientID]
		,[ClaimInfoID]
		,[BeginServiceDate]
	FROM #ART_Candidate_Patients
	WHERE [RevenueCode] IN (
			SELECT [ECTCode]
			FROM #ECTCodes_ART_Table_B
			WHERE ([ECTTypeCode] = 'RevCode')
				AND (
					[ECTCodeDescription] IN (
						'Outpatient'
						,'Nonacute inpatient'
						)
					)
			)
	) AS diag_pat1
GROUP BY diag_pat1.[PatientID]
HAVING COUNT(*) >= @Num_Encounters_Outpatient_NonAcuteInPatient

DROP TABLE #ECTCodes_ART_Table_B;

DROP TABLE #ART_Candidate_Patients;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_ART_GetPatients_EncouterClaims_2012] TO [FE_rohit.r-ext]
    AS [dbo];

