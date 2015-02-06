CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_CMC_GetPatients_EncounterClaims_2012]
(
	@AnchorDate_Year int = 2012,
	@AnchorDate_Month int = 12,
	@AnchorDate_Day int = 31,

	@Num_Months_Prior int = 12,
	@Num_Months_After int = 0,

	@Num_Encounters_Outpatient int = 1,
	@Num_Encounters_AcuteInpatient int = 1,

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

	 @Num_Encounters_Outpatient = Minimum Number of 'OutPatient' Medical Encounters during the Measurement Period that identifies a Patient
								  for inclusion in the Eligible Population of Patients.

	 @Num_Encounters_AcuteInpatient = Minimum Number of 'Acute Inpatient' Medical Encounters during the Measurement Period that identifies a
									  Patient for inclusion in the Eligible Population of Patients.

	 @ECTCodeVersion_Year = Code Version Year from which valid HEDIS-associated Diagnosis, Procedure, and Revenue Codes are retrieved for use in
							selection of Patients for inclusion in the Eligible Population of Patients with Encounter Claims during the
							Measurement Period.

	 @ECTCodeStatus = Status of valid HEDIS-associated Diagnosis, Procedure, and Revenue Codes that are retrieved for use in selection of Patients
					  for inclusion in the Eligible Population of Patients with Encounter Claims during the Measurement Period.
					  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 *********************************************************************************************************************************************/


DECLARE	@PatientID int


CREATE TABLE [#ECTCodes_CMC_Table_A]
(
	[ECTCode] varchar(20) NOT NULL,
	[ECTCodeDescription] varchar(255) NOT NULL,
	[ECTHedisCodeTypeCode] varchar(20) NOT NULL
);

CREATE NONCLUSTERED INDEX [IDX_ECTCodes_CMC_Table_A] ON #ECTCodes_CMC_Table_A
(
	[ECTCode] ASC,
	[ECTCodeDescription] ASC,
	[ECTHedisCodeTypeCode] ASC
)WITH (FILLFACTOR = 90);


CREATE TABLE [#ECTCodes_CMC_Table_C]
(
	[ECTCode] varchar(20) NOT NULL,
	[ECTCodeDescription] varchar(255) NOT NULL,
	[ECTHedisCodeTypeCode] varchar(20) NOT NULL
);

CREATE NONCLUSTERED INDEX [IDX_ECTCodes_CMC_Table_C] ON #ECTCodes_CMC_Table_C
(
	[ECTCode] ASC,
	[ECTCodeDescription] ASC,
	[ECTHedisCodeTypeCode] ASC
)WITH (FILLFACTOR = 90);


CREATE TABLE #CMC_Candidate_EventsPatients
(
	[PatientID] int NOT NULL,
	[ClaimInfoID] int NOT NULL,
	[ClaimLineID] int NULL,
	[ProcedureCode] varchar(10) NULL,
	[ProcedureCodeType] varchar(10) NULL,
	[ICDProcedureCode] varchar(10) NULL,
	[ICDProcedureCodeType] varchar(10) NULL,
	[ICDDiagnosisCode] varchar(10) NULL,
	[ICDDiagnosisCodeType] varchar(10) NULL,
	[RevenueCode] varchar(10) NULL,
	[BeginServiceDate] datetime NULL,
	[EndServiceDate] datetime NULL
);

CREATE CLUSTERED INDEX [IDX_CMC_Candidate_EventsPatients] ON #CMC_Candidate_EventsPatients
(
	[PatientID] ASC,
	[ClaimInfoID] ASC,
	[ClaimLineID] ASC,
	[ProcedureCode] ASC,
	[ProcedureCodeType] ASC,
	[ICDProcedureCode] ASC,
	[ICDProcedureCodeType] ASC,
	[ICDDiagnosisCode] ASC,
	[ICDDiagnosisCodeType] ASC,
	[RevenueCode] ASC,
	[BeginServiceDate] ASC,
	[EndServiceDate] ASC
)WITH (FILLFACTOR = 90);


CREATE TABLE #CMC_Candidate_DiagnosesPatients
(
	[PatientID] int NOT NULL,
	[ClaimInfoID] int NOT NULL,
	[ClaimLineID] int NULL,
	[ProcedureCode] varchar(10) NULL,
	[RevenueCode] varchar(10) NULL,
	[BeginServiceDate] datetime NULL,
	[EndServiceDate] datetime NULL
);

CREATE CLUSTERED INDEX [IDX_CMC_Candidate_DiagnosesPatients] ON #CMC_Candidate_DiagnosesPatients
(
	[PatientID] ASC,
	[ClaimInfoID] ASC,
	[ClaimLineID] ASC,
	[ProcedureCode] ASC,
	[RevenueCode] ASC,
	[BeginServiceDate] ASC,
	[EndServiceDate] ASC
)WITH (FILLFACTOR = 90);



INSERT INTO #ECTCodes_CMC_Table_A
SELECT [ECTCode], [ECTCodeDescription], [ECTHedisCodeTypeCode]
FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CMC-A', @ECTCodeVersion_Year, @ECTCodeStatus)


/* Retrieve Patients with Medical Claims in which Events of type "AMI", "CABG", or "PCI" was
   identified on the Claims and in which they were discharged ALIVE at the end of the time period
   covered the Claims from January 1st thru November 1st of the Year Prior to the Measurement Year. */

INSERT INTO #CMC_Candidate_EventsPatients
SELECT DISTINCT [PatientID], [ClaimInfoID], [ClaimLineID], [ProcedureCode], [ProcedureCodeType],
				[ICDProcedureCode], [ICDProcedureCodeType], [ICDDiagnosisCode], [ICDDiagnosisCodeType],
				[RevenueCode], [BeginServiceDate], [EndServiceDate]

FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims('CMC-A', (@AnchorDate_Year - 1), CASE WHEN (@AnchorDate_Month - 1) = 0 THEN @AnchorDate_Month ELSE @AnchorDate_Month -1 END, case when (@AnchorDate_Day - 30) <1 then 1 else (@AnchorDate_Day - 30) end ,
											  (@Num_Months_Prior - 14), @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus)

-- Criteria for selecting Patients discharged ALIVE (i.e. Did Not Die) at the Medical Facility at the
-- end of the time period covered by the Medical Claim, via the 'Discharge Status' of the Patient
WHERE [PatientStatusCode] <> '20'


INSERT INTO #ECTCodes_CMC_Table_C
SELECT [ECTCode], [ECTCodeDescription], [ECTHedisCodeTypeCode]
FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CMC-C', @ECTCodeVersion_Year, @ECTCodeStatus)


/* Retrieve Patients with Medical Claims in which they were Diagnosed has having "IVD" during the
   Measurement Year and Year Prior to the Measurement Year. */

INSERT INTO #CMC_Candidate_DiagnosesPatients
SELECT DISTINCT [PatientID], [ClaimInfoID], [ClaimLineID], [ProcedureCode], [RevenueCode], [BeginServiceDate],
				[EndServiceDate]

FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByDiagnosis('CMC-B', @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day,
														  @Num_Months_Prior, @Num_Months_After, @ECTCodeVersion_Year,
														  @ECTCodeStatus)



/* Select Patients with Medical Claims in which Event of type "PCI" was identified on the Claims and
   in which they were discharged ALIVE at the end of the time period from January 1st thru November 1st
   of the Year Prior to the Measurement Year. */

SELECT DISTINCT [PatientID]
FROM #CMC_Candidate_EventsPatients
WHERE ([ProcedureCode] IN (SELECT [ECTCode]
						   FROM #ECTCodes_CMC_Table_A
						   WHERE [ECTCodeDescription] = 'PCI')) OR
	  ([ICDProcedureCode] IN (SELECT [ECTCode]
							  FROM #ECTCodes_CMC_Table_A
							  WHERE [ECTCodeDescription] = 'PCI'))

UNION


/* Select Patients with Medical Claims in which Event of type "AMI" or "CABG" was identified on the
   Claims and in which they were discharged ALIVE at the end of the time period from January 1st thru
   November 1st of the Year Prior to the Measurement Year. */

SELECT p.[PatientID]
FROM
	(
	  -- Select Patients meeting criteria of having Event of type "AMI" or "CABG" identified on Medical
	  -- Claims in which a visit type of 'Acute Inpatient' was also specified on the Claims, based on
	  -- Procedures (CPT codes) specified on Medical Claim Forms "UB-04" and "CMS-1500" submitted for Patients.
	  SELECT DISTINCT event_pat1.[PatientID]
	  FROM (SELECT [PatientID], [ProcedureCode]
			FROM #CMC_Candidate_EventsPatients
			WHERE ([ProcedureCode] IN (SELECT [ECTCode]
									   FROM #ECTCodes_CMC_Table_A
									   WHERE [ECTCodeDescription] = 'CABG (inpatient only)')) OR
				  ([ICDProcedureCode] IN (SELECT [ECTCode]
										  FROM #ECTCodes_CMC_Table_A
										  WHERE [ECTCodeDescription] = 'CABG (inpatient only)')) OR
				  ([ICDDiagnosisCode] IN (SELECT [ECTCode]
										  FROM #ECTCodes_CMC_Table_A
										  WHERE [ECTCodeDescription] = 'AMI (inpatient only)'))
		   ) AS event_pat1
		   WHERE event_pat1.[ProcedureCode] IN (SELECT [ECTCode]
												FROM #ECTCodes_CMC_Table_C
												WHERE ([ECTHedisCodeTypeCode] = 'CPT') AND
													  ([ECTCodeDescription] = 'Acute inpatient'))

	  UNION

	  -- Select Patients meeting criteria of having Event of type "AMI" or "CABG" identified on Medical
	  -- Claims in which a visit type of 'Acute Inpatient' was also specified on the Claims, based on
	  -- Revenue Codes specified on Medical Claim Forms "UB-04" submitted for Patients.
	  SELECT DISTINCT event_pat2.[PatientID]
	  FROM (SELECT [PatientID], [RevenueCode]
			FROM #CMC_Candidate_EventsPatients
			WHERE ([ProcedureCode] IN (SELECT [ECTCode]
									   FROM #ECTCodes_CMC_Table_A
									   WHERE [ECTCodeDescription] = 'CABG (inpatient only)')) OR
				  ([ICDProcedureCode] IN (SELECT [ECTCode]
										  FROM #ECTCodes_CMC_Table_A
										  WHERE [ECTCodeDescription] = 'CABG (inpatient only)')) OR
				  ([ICDDiagnosisCode] IN (SELECT [ECTCode]
										  FROM #ECTCodes_CMC_Table_A
										  WHERE [ECTCodeDescription] = 'AMI (inpatient only)'))
		   ) AS event_pat2
		   WHERE event_pat2.[RevenueCode] IN (SELECT [ECTCode]
											  FROM #ECTCodes_CMC_Table_C
											  WHERE ([ECTHedisCodeTypeCode] = 'RevCode') AND
													([ECTCodeDescription] = 'Acute inpatient'))
	) AS p

UNION


/* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of 'Outpatient'
   and 'Acute Inpatient' visit types during the Current Measurement Year and the Year Prior to the
   Current Measurement Year. */

SELECT p.[PatientID]
FROM
	(
	  /* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of
		 'Outpatient' and 'Acute Inpatient' visit types during the Current Measurement Year. */

	  SELECT p1.[PatientID]
	  FROM (
			/* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of
			   'Outpatient' and 'Acute Inpatient' visit types. */

			SELECT diag_pat1.[PatientID]
			FROM (
				  /* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of
					 'Outpatient' visit types. */

				  -- Retrieve Patients meeting criteria of having requisite number of Encounter Claims,
				  -- based on Procedures (CPT codes) specified on Medical Claim Forms "UB-04" and "CMS-1500"
				  -- submitted for Patients.
				  SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
				  FROM #CMC_Candidate_DiagnosesPatients
				  WHERE (DATEPART(yyyy, [BeginServiceDate]) = @AnchorDate_Year) AND
						([ProcedureCode] IN (SELECT [ECTCode]
											 FROM #ECTCodes_CMC_Table_C
											 WHERE ([ECTHedisCodeTypeCode] = 'CPT') AND ([ECTCodeDescription] = 'Outpatient')))

				  UNION

				  -- Retrieve Patients meeting criteria of having requisite number of Encounter Claims,
				  -- based on Revenue Codes specified on Medical Claim Forms "UB-04" submitted for Patients.
				  SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
				  FROM #CMC_Candidate_DiagnosesPatients
				  WHERE (DATEPART(yyyy, [BeginServiceDate]) = @AnchorDate_Year) AND
						([RevenueCode] IN (SELECT [ECTCode]
										   FROM #ECTCodes_CMC_Table_C
										   WHERE ([ECTHedisCodeTypeCode] = 'RevCode') AND ([ECTCodeDescription] = 'Outpatient')))
			) AS diag_pat1
			GROUP BY diag_pat1.[PatientID]
			HAVING COUNT(*) >= @Num_Encounters_Outpatient

			UNION

			SELECT diag_pat2.[PatientID]
			FROM (
				  /* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of
					 'Acute Inpatient' visit types. */

				  -- Retrieve Patients meeting criteria of having requisite number of Encounter Claims, based on Procedures
				  -- (CPT codes) specified on Medical Claim Forms "UB-04" and "CMS-1500" submitted for Patients.
				  SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
				  FROM #CMC_Candidate_DiagnosesPatients
				  WHERE (DATEPART(yyyy, [BeginServiceDate]) = @AnchorDate_Year) AND
						([ProcedureCode] IN (SELECT [ECTCode]
											 FROM #ECTCodes_CMC_Table_C
											 WHERE ([ECTHedisCodeTypeCode] = 'CPT') AND ([ECTCodeDescription] = 'Acute inpatient')))

				  UNION

				  -- Retrieve Patients meeting criteria of having requisite number of Encounter Claims,
				  -- based on Revenue Codes specified on Medical Claim Forms "UB-04" submitted for Patients.
				  SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
				  FROM #CMC_Candidate_DiagnosesPatients
				  WHERE (DATEPART(yyyy, [BeginServiceDate]) = @AnchorDate_Year) AND
						([RevenueCode] IN (SELECT [ECTCode]
										   FROM #ECTCodes_CMC_Table_C
										   WHERE ([ECTHedisCodeTypeCode] = 'RevCode') AND ([ECTCodeDescription] = 'Acute inpatient')))

			) AS diag_pat2
			GROUP BY diag_pat2.[PatientID]
			HAVING COUNT(*) >= @Num_Encounters_AcuteInpatient

	  ) AS p1

	  INTERSECT


	  /* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of
		 'Outpatient' and 'Acute Inpatient' visit types during the Year Prior to the Current
		  Measurement Year. */

	  SELECT p2.[PatientID]
	  FROM (
			/* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of
			   'Outpatient' and 'Acute Inpatient' visit types. */

			SELECT diag_pat1.[PatientID]
			FROM (
				  /* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of
					 'Outpatient' visit types. */

				  -- Retrieve Patients meeting criteria of having requisite number of Encounter Claims,
				  -- based on Procedures (CPT codes) specified on Medical Claim Forms "UB-04" and "CMS-1500"
				  -- submitted for Patients.
				  SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
				  FROM #CMC_Candidate_DiagnosesPatients
				  WHERE (DATEPART(yyyy, [BeginServiceDate]) = @AnchorDate_Year - 1) AND
						([ProcedureCode] IN (SELECT [ECTCode]
											 FROM #ECTCodes_CMC_Table_C
											 WHERE ([ECTHedisCodeTypeCode] = 'CPT') AND ([ECTCodeDescription] = 'Outpatient')))

				  UNION

				  -- Retrieve Patients meeting criteria of having requisite number of Encounter Claims,
				  -- based on Revenue Codes specified on Medical Claim Forms "UB-04" submitted for Patients.
				  SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
				  FROM #CMC_Candidate_DiagnosesPatients
				  WHERE (DATEPART(yyyy, [BeginServiceDate]) = @AnchorDate_Year - 1) AND
						([RevenueCode] IN (SELECT [ECTCode]
										   FROM #ECTCodes_CMC_Table_C
										   WHERE ([ECTHedisCodeTypeCode] = 'RevCode') AND ([ECTCodeDescription] = 'Outpatient')))
			) AS diag_pat1
			GROUP BY diag_pat1.[PatientID]
			HAVING COUNT(*) >= @Num_Encounters_Outpatient

			UNION

			SELECT diag_pat2.[PatientID]
			FROM (
				  /* Retrieve Patients meeting criteria of having requisite number of Encounter Claims of
					 'Acute Inpatient' visit types. */

				  -- Retrieve Patients meeting criteria of having requisite number of Encounter Claims, based on Procedures
				  -- (CPT codes) specified on Medical Claim Forms "UB-04" and "CMS-1500" submitted for Patients.
				  SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
				  FROM #CMC_Candidate_DiagnosesPatients
				  WHERE (DATEPART(yyyy, [BeginServiceDate]) = @AnchorDate_Year - 1) AND
						([ProcedureCode] IN (SELECT [ECTCode]
											 FROM #ECTCodes_CMC_Table_C
											 WHERE ([ECTHedisCodeTypeCode] = 'CPT') AND ([ECTCodeDescription] = 'Acute inpatient')))

				  UNION

				  -- Retrieve Patients meeting criteria of having requisite number of Encounter Claims,
				  -- based on Revenue Codes specified on Medical Claim Forms "UB-04" submitted for Patients.
				  SELECT DISTINCT [PatientID], [ClaimInfoID], [BeginServiceDate]
				  FROM #CMC_Candidate_DiagnosesPatients
				  WHERE (DATEPART(yyyy, [BeginServiceDate]) = @AnchorDate_Year - 1) AND
						([RevenueCode] IN (SELECT [ECTCode]
										   FROM #ECTCodes_CMC_Table_C
										   WHERE ([ECTHedisCodeTypeCode] = 'RevCode') AND ([ECTCodeDescription] = 'Acute inpatient')))

			) AS diag_pat2
			GROUP BY diag_pat2.[PatientID]
			HAVING COUNT(*) >= @Num_Encounters_AcuteInpatient

	  ) AS p2

	) AS p


DROP TABLE #ECTCodes_CMC_Table_A;
DROP TABLE #ECTCodes_CMC_Table_C;
DROP TABLE #CMC_Candidate_EventsPatients;
DROP TABLE #CMC_Candidate_DiagnosesPatients;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_CMC_GetPatients_EncounterClaims_2012] TO [FE_rohit.r-ext]
    AS [dbo];

