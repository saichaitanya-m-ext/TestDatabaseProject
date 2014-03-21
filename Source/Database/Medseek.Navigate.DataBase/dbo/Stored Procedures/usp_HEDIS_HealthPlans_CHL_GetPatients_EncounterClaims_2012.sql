CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_CHL_GetPatients_EncounterClaims_2012]
(
	@AnchorDate_Year int = 2012,
	@AnchorDate_Month int = 12,
	@AnchorDate_Day int = 31,

	@Num_Months_Prior int = 24,
	@Num_Months_After int = 0,

	@Num_Encounters_Outpatient_NonAcuteInPatient int = 2,
	@Num_Encounters_AcuteInpatient_ED int = 1,

	@ECTCodeVersion_Year int = 2012,
	@ECTCodeStatus varchar(1) = 'A'
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

DECLARE	@PatientID int

CREATE TABLE #CHL_Diagnosis_Patients
(
	[PatientID] int NOT NULL,
	[ProcedureCode] varchar(10) NULL
);

CREATE CLUSTERED INDEX [IDX_CHL_Diagnosis_Patients] ON #CHL_Diagnosis_Patients
(
	[PatientID] ASC,
	[ProcedureCode] ASC
)WITH (FILLFACTOR = 90);


CREATE TABLE #CHL_Procedure_Patients
(
	[PatientID] int NOT NULL,
	[ProcedureCode] varchar(10) NULL
);

CREATE CLUSTERED INDEX [IDX_CHL_Procedure_Patients] ON #CHL_Procedure_Patients
(
	[PatientID] ASC,
	[ProcedureCode] ASC
)WITH (FILLFACTOR = 90);


CREATE TABLE #CHL_Revenue_Patients
(
	[PatientID] int NOT NULL,
	[ProcedureCode] varchar(10) NULL
);

CREATE CLUSTERED INDEX [IDX_CHL_Revenue_Patients] ON #CHL_Revenue_Patients
(
	[PatientID] ASC,
	[ProcedureCode] ASC
)WITH (FILLFACTOR = 90);


CREATE TABLE #CHL_LAB_Patients
(
	[PatientID] int NOT NULL,
	[ProcedureCode] varchar(10) NULL
);

CREATE CLUSTERED INDEX [IDX_CHL_LAB_Patients] ON #CHL_LAB_Patients
(
	[PatientID] ASC,
	[ProcedureCode] ASC
)WITH (FILLFACTOR = 90);



INSERT INTO #CHL_Diagnosis_Patients
SELECT DISTINCT [PatientID], [ProcedureCode]

FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByDiagnosis('CHL-B', @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day,
														  @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year,
														  @ECTCodeStatus)

INSERT INTO #CHL_Procedure_Patients
SELECT DISTINCT [PatientID], [ProcedureCode]

FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure('CHL-B', @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day,
														  @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year,
														  @ECTCodeStatus)

INSERT INTO #CHL_Revenue_Patients
SELECT DISTINCT [PatientID], [ProcedureCode]

FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByRevenue('CHL-B', @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day,
														  @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year,
														  @ECTCodeStatus)


INSERT INTO #CHL_Lab_Patients
SELECT DISTINCT [PatientID], [ProcedureCode]

FROM dbo.ufn_HEDIS_GetPatients_LabData('CHL-B', @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day,
														  @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year,
														  @ECTCodeStatus)


SELECT DISTINCT [PatientID]
FROM
(
  SELECT DISTINCT [PatientID]  FROM #CHL_Diagnosis_Patients
      
  UNION
  
  SELECT DISTINCT [PatientID] FROM #CHL_Procedure_Patients
      
  UNION
  
  SELECT DISTINCT [PatientID] FROM #CHL_Revenue_Patients
       
  UNION
  
  SELECT DISTINCT [PatientID] FROM #CHL_Lab_Patients
       
)P



DROP TABLE #CHL_Diagnosis_Patients;
DROP TABLE #CHL_Procedure_Patients;
DROP TABLE #CHL_Revenue_Patients;
DROP TABLE #CHL_Lab_Patients;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_CHL_GetPatients_EncounterClaims_2012] TO [FE_rohit.r-ext]
    AS [dbo];

