CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_CDC_GetPatients_EncounterClaims_2012]
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


CREATE TABLE [#ECTCodes_CDC_Table_C]
(
	[ECTCode] varchar(20) NOT NULL,
	[ECTCodeDescription] varchar(255) NOT NULL,
	[ECTHedisCodeTypeCode] varchar(20) NOT NULL
);

CREATE NONCLUSTERED INDEX [IDX_ECTCodes_CDC_Table_C] ON #ECTCodes_CDC_Table_C
(
	[ECTCode] ASC,
	[ECTCodeDescription] ASC,
	[ECTHedisCodeTypeCode] ASC
)WITH (FILLFACTOR = 90);


CREATE TABLE #CDC_Candidate_Patients
(
	[PatientID] int NOT NULL,
	[ClaimInfoID] int NOT NULL,
	[ClaimLineID] int NULL,
	[ProcedureCode] varchar(10) NULL,
	[RevenueCode] varchar(10) NULL,
	[BeginServiceDate] datetime NULL,
	[EndServiceDate] datetime NULL
);

CREATE CLUSTERED INDEX [IDX_CDC_Candidate_Patients] ON #CDC_Candidate_Patients
(
	[PatientID] ASC,
	[ClaimInfoID] ASC,
	[ClaimLineID] ASC,
	[ProcedureCode] ASC,
	[RevenueCode] ASC,
	[BeginServiceDate] ASC,
	[EndServiceDate] ASC
)WITH (FILLFACTOR = 90);


INSERT INTO #ECTCodes_CDC_Table_C
SELECT [ECTCode], [ECTCodeDescription], [ECTHedisCodeTypeCode]
FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-C', @ECTCodeVersion_Year, @ECTCodeStatus)


INSERT INTO #CDC_Candidate_Patients
SELECT DISTINCT [PatientID], [ClaimInfoID], [ClaimLineID], [ProcedureCode], [RevenueCode],
				[BeginServiceDate], [EndServiceDate]

FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByDiagnosis('CDC-B', @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day,
														  @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year,
														  @ECTCodeStatus)



/* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of type 'Out-Patient' and
   'Non-Acute In-Patient' visits. */
SELECT diag_pat1.[PatientID]
FROM
(
	-- Retrieve Patients meeting criteria of having requisite number of Encounter Claims, based on Procedures
	-- (CPT codes) specified on Medical Claim Forms "UB-04" and "CMS-1500" submitted for Patients.
	SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
	FROM #CDC_Candidate_Patients
	WHERE [ProcedureCode] IN (SELECT [ECTCode]
							  FROM #ECTCodes_CDC_Table_C
							  WHERE ([ECTHedisCodeTypeCode] = 'CPT') AND
									([ECTCodeDescription] IN ('Outpatient', 'Nonacute inpatient')))

	UNION

	-- Retrieve Patients meeting criteria of having requisite number of Encounter Claims, based on Revenue Codes
	-- specified on Medical Claim Forms "UB-04" submitted for Patients.
	SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
	FROM #CDC_Candidate_Patients
	WHERE [RevenueCode] IN (SELECT [ECTCode]
							FROM #ECTCodes_CDC_Table_C
							WHERE ([ECTHedisCodeTypeCode] = 'RevCode') AND
								  ([ECTCodeDescription] IN ('Outpatient', 'Nonacute inpatient')))

) AS diag_pat1
GROUP BY diag_pat1.[PatientID]
HAVING COUNT(*) >= @Num_Encounters_Outpatient_NonAcuteInPatient

UNION

/* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of type 'Out-Patient' and
   'Non-Acute In-Patient' visits. */
SELECT diag_pat2.[PatientID]
FROM
(
	-- Retrieve Patients meeting criteria of having requisite number of Encounter Claims, based on Procedures
	-- (CPT codes) specified on Medical Claim Forms "UB-04" and "CMS-1500" submitted for Patients.
	SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
	FROM #CDC_Candidate_Patients
	WHERE [ProcedureCode] IN (SELECT [ECTCode]
							  FROM #ECTCodes_CDC_Table_C
							  WHERE ([ECTHedisCodeTypeCode] = 'CPT') AND
									([ECTCodeDescription] IN ('Acute inpatient', 'ED')))

	UNION

	-- Retrieve Patients meeting criteria of having requisite number of Encounter Claims, based on Revenue Codes
	-- specified on Medical Claim Forms "UB-04" submitted for Patients.
	SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
	FROM #CDC_Candidate_Patients
	WHERE [RevenueCode] IN (SELECT [ECTCode]
							FROM #ECTCodes_CDC_Table_C
							WHERE ([ECTHedisCodeTypeCode] = 'RevCode') AND
								  ([ECTCodeDescription] IN ('Acute inpatient', 'ED')))

) AS diag_pat2
GROUP BY diag_pat2.[PatientID]
HAVING COUNT(*) >= @Num_Encounters_AcuteInpatient_ED


DROP TABLE #ECTCodes_CDC_Table_C;
DROP TABLE #CDC_Candidate_Patients;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_CDC_GetPatients_EncounterClaims_2012] TO [FE_rohit.r-ext]
    AS [dbo];

