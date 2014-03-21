CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_ART_GetPatients_EncounterClaims_2012]
(
 @AnchorDate_Year int = 2011 ,
 @AnchorDate_Month int = 12 ,
 @AnchorDate_Day int = 31 ,
 @Num_Months_Prior int = 24 ,
 @Num_Months_After int = 0 ,
 @Num_Encounters_Outpatient_NonAcuteInPatient int = 2 ,
 @ECTCodeVersion_Year int = 2012 ,
 @ECTCodeStatus varchar(1) = 'A'
)
AS /************************************************************ INPUT PARAMETERS ************************************************************

	 @AnchorDate_Year = Year of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Month = Month of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Day = Day in the Month of the Anchor Date for which Eligible Population is to be constructed.

	 @Num_Months_Prior = Number of Months Before the Anchor Date from which Eligible Population of Patients with "Diabetes" Encounter Claims
						 is to be constructed.

	 @Num_Months_After = Number of Months After the Anchor Date from which Eligible Population of Patients with "Diabetes" Encounter Claims
						 is to be constructed.

	 @Num_Encounters_Outpatient_NonAcuteInPatient = Number of 'OutPatient' and 'Non-Acute Inpatient' Medical Encounters during the Measurement
													Period that identifies a Patient for inclusion in the Eligible Population of Patients with
													"Diabetes".

	 @Num_Encounters_AcuteInpatient_ED = Number of 'Acute Inpatient' and 'ED' Medical Encounters during the Measurement Period that identifies
										 a Patient for inclusion in the Eligible Population of Patients with "Diabetes".

	 @ECTCodeVersion_Year = Code Version Year from which valid HEDIS-associated ICD-9 and CPT Codes are retrieved for use in selection of 
							Patients for inclusion in the Eligible Population of Patients with "Diabetes" Encounter Claims during the
							Measurement Period.

	 @ECTCodeStatus = Status of valid HEDIS-associated ICD-9 and CPT Codes that are retrieved for use in selection of Patients for inclusion in
					  the Eligible Population of Patients with "Diabetes" Encounter Claims during the Measurement Period.
					  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 *********************************************************************************************************************************************/


DECLARE @UserID int




CREATE TABLE [#ECTCodes_Table_ART_B]
(
	[ECTCode] varchar(20) NOT NULL,
	[ECTCodeDescription] varchar(255) NOT NULL,
	[ECTHedisCodeTypeCode] varchar(20) NOT NULL
);

CREATE NONCLUSTERED INDEX [IX_ECTCodes_Table_ART_B] ON #ECTCodes_Table_ART_B 
(
	[ECTCode] ASC,
	[ECTCodeDescription] ASC,
	[ECTHedisCodeTypeCode] ASC
);


CREATE TABLE #DiabetesPatients_Candidates
(
	[PatientID] int NOT NULL,
	[ClaimInfoID] int NOT NULL,
	[ClaimLineID] int NULL,
	[ProcedureCodeID] VARCHAR(20) NULL,
	[RevenueCodeID] VARCHAR(20) NULL,
	[ICDCode] varchar(20) NULL,
	[BeginServiceDate] datetime NULL
);

CREATE CLUSTERED INDEX [IX_DiabetesPatients_Candidates] ON [#DiabetesPatients_Candidates] 
(
	[PatientID] ASC,
	[ClaimInfoID] ASC,
	[ClaimLineID] ASC,
	[ProcedureCodeID] ASC,
	[RevenueCodeID] ASC,
	[ICDCode] ASC,
	[BeginServiceDate] ASC
)WITH (FILLFACTOR = 90)

CREATE TABLE #DiabetesPatients
(
  [UserID] int NOT NULL
               PRIMARY KEY CLUSTERED
)


INSERT INTO
    #ECTCodes_Table_ART_B
    SELECT
        [ECTCode] ,
        [ECTCodeDescription] ,
        [ECTHedisCodeTypeCode]
    FROM
        dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('ART-B' , @ECTCodeVersion_Year , @ECTCodeStatus)


INSERT INTO
    #DiabetesPatients_Candidates
    SELECT
        [PatientID],
        [ClaimInfoId] ,
        [ClaimLineID] ,
        [ProcedureCodeID] ,
        [RevenueCodeID] ,
        [ICDDiagnosisCode] ,
        [BeginServiceDate]
    FROM
        dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByDiagnosis('ART' , @AnchorDate_Year , @AnchorDate_Month , @AnchorDate_Day , @Num_Months_Prior , @Num_Months_After , @ECTCodeVersion_Year , @ECTCodeStatus)

UPDATE #DiabetesPatients_Candidates 
  SET ProcedureCodeID = csp.ProcedureCode
FROM 
   #DiabetesPatients_Candidates tdp
INNER JOIN CodeSetProcedure csp 
   ON csp.ProcedureCodeID = CAST(tdp.ProcedureCodeID AS INT)
   
UPDATE #DiabetesPatients_Candidates 
  SET RevenueCodeID = csp.RevenueCode
FROM 
   #DiabetesPatients_Candidates tdp
INNER JOIN RevenueCode csp 
   ON csp.RevenueCodeID = CAST(tdp.RevenueCodeID AS INT)
--dbo.ufn_HEDIS_GetPatients_EncouterClaims('CDC', @AnchorDate_Year, @AnchorDate_BeginMonth, @AnchorDate_BeginDay, @AnchorDate_EndMonth,
--											  @AnchorDate_EndDay, @Num_Years_Prior, @Num_Years_After, @ECTCodeStatus, @ECTCodeVersion_Year)


/* Retrieve Patients meeting criteria of having requisite number of Diabetes encounter claims of type 'Out-Patient' and
   'Non-Acute In-Patient' visits. */
INSERT INTO
    #DiabetesPatients
    SELECT
        diab_pat.[PatientID]
    FROM
        (
          -- Retrieve Patients meeting criteria of having requisite number of Diabetes encounter claims, based on Procedures (CPT codes)
          -- specified on health claim forms "UB-04" and "CMS-1500" submitted for Patients.
          SELECT
              claims_BY_procs.[PatientID]
          FROM
              ( SELECT DISTINCT
                    [PatientID] ,
                    [ClaimInfoId] ,
                    [ProcedureCodeID] ,
                    [BeginServiceDate]
                FROM
                    #DiabetesPatients_Candidates
                WHERE
                    [ProcedureCodeID] IN ( SELECT
                                           [ECTCode]
                                       FROM
                                           #ECTCodes_Table_ART_B
                                       WHERE
                                           ( [ECTHedisCodeTypeCode] = 'CPT' )
                                           AND ( [ECTCodeDescription] IN ( 'Outpatient' , 'Nonacute inpatient' ) ) ) ) AS claims_BY_procs
          UNION

          -- Retrieve Patients meeting criteria of having requisite number of Diabetes encounter claims, based on Revenue Codes specified
          -- on health claim forms "UB-04" submitted for Patients.
          SELECT
              claims_BY_revcode.[PatientID]
          FROM
              ( SELECT DISTINCT
                    [PatientID] ,
                    [ClaimInfoId] ,
                    [RevenueCodeID] ,
                    [BeginServiceDate]
                FROM
                    #DiabetesPatients_Candidates
                WHERE
                    [RevenueCodeID] IN ( SELECT
                                             [ECTCode]
                                         FROM
                                             #ECTCodes_Table_ART_B
                                         WHERE
                                             ( [ECTHedisCodeTypeCode] = 'RevCode' )
                                             AND ( [ECTCodeDescription] IN ( 'Outpatient' , 'Nonacute inpatient' ) ) ) ) AS claims_BY_revcode ) AS diab_pat
    GROUP BY
        diab_pat.[PatientID]
    HAVING
        COUNT(*) >= @Num_Encounters_Outpatient_NonAcuteInPatient





SELECT
    [UserID]
FROM
    #DiabetesPatients
ORDER BY
    [UserID]


DROP TABLE #ECTCodes_Table_ART_B ;
DROP TABLE #DiabetesPatients_Candidates ;
DROP TABLE #DiabetesPatients ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_ART_GetPatients_EncounterClaims_2012] TO [FE_rohit.r-ext]
    AS [dbo];

