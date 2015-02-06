CREATE PROCEDURE [dbo].[usp_HEDIS_CMC_GetPatients_EncouterClaims_2012]
(
 @AnchorDate_Year int ,
 @AnchorDate_Month int ,
 @AnchorDate_Day int ,
 @Num_Years_Prior int ,
 @Num_Years_After int ,
 @Num_Encounters_IVD int ,
 @Num_Encounters_Outpatient_AcuteInPatient int ,
 @ECTCodeStatus varchar(1) ,
 @ECTCodeVersion_Year int
)
AS /************************************************************ INPUT PARAMETERS ************************************************************

	 @AnchorDate_Year = Year of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Month = Month of the Anchor Date during the Measurement Year for which Eligible Population is to be constructed.

	 @AnchorDate_Day = Day in the Month of the Anchor Date during the Measurement Year for which Eligible Population is to be constructed.

	 @Num_Years_Prior = Number of years prior to the Anchor Date for which Eligible Population of Patients with "Diabetes" are to be constructed.

	 @Num_Years_After = Number of years after the Anchor Date for which Eligible Population of Patients with "Diabetes" are to be constructed.

	 @Num_Encounters_Outpatient_NonAcuteInPatient = Number of 'OutPatient' and 'Non-Acute Inpatient' Medical Encounters/Events during the
													Measurement Period that identifies a Patient for inclusion in the Eligible Population of
													Patients with "Diabetes".

	 @Num_Encounters_AcuteInpatient_ED = Number of 'Acute Inpatient' and 'ED' Medical Encounters/Events during the Measurement Period that
										 identifies a Patient for inclusion in the Eligible Population of Patients with "Diabetes".

	 @ECTCodeStatus = Status of valid HEDIS-associated ICD-9 and CPT Codes that are retrieved for use in selection of Patients for inclusion in
					  the Eligible Population of Patients with "Diabetes" Encounter Claims during the Measurement Period.
					  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @ECTCodeVersion_Year = Code Version Year from which valid HEDIS-associated ICD-9 and CPT Codes are retrieved for use in selection of 
							Patients for inclusion in the Eligible Population of Patients with "Diabetes" Encounter Claims during the
							Measurement Period.

	 *********************************************************************************************************************************************/


DECLARE @UserID int


CREATE TABLE #DiabetesPatients_Candidates
(
  [UserId] int NULL ,
  [ClaimInfoId] int NULL ,
  [ClaimLineID] int NULL ,
  [ProcedureId] int NULL ,
  [BeginServiceDate] datetime NULL
)

CREATE NONCLUSTERED INDEX IX_DiabetesPatientsCandidates_UserId ON #DiabetesPatients_Candidates ( [UserId] ) ;


CREATE TABLE #DiabetesPatients
(
  [UserID] int
)

CREATE NONCLUSTERED INDEX IX_DiabetesPatients_UserID ON #DiabetesPatients ( [UserID] ) ;


INSERT INTO
    #DiabetesPatients_Candidates
    SELECT
        pat.[UserId] ,
        pat.[ClaimInfoId] ,
        pat.[ClaimLineID] ,
        pat.[ProcedureId] ,
        pat.[BeginServiceDate]
    FROM
        ufn_HEDIS_CMC_GetPatients_EncouterClaims(@AnchorDate_Year , @AnchorDate_Month , @AnchorDate_Day , @Num_Years_Prior , @Num_Years_After , @ECTCodeStatus , @ECTCodeVersion_Year) AS pat

INSERT INTO
    #DiabetesPatients
    SELECT
        cand_pat.[UserId]
    FROM
        ( SELECT DISTINCT
              [UserId] ,
              [ClaimInfoId] ,
              [ProcedureId] ,
              [BeginServiceDate]
          FROM
              #DiabetesPatients_Candidates
          WHERE
              [ProcedureId] IN ( SELECT
                                     cod.[ECTCode]
                                 FROM
                                     dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-B' , @ECTCodeVersion_Year , @ECTCodeStatus) AS cod
                                 WHERE
                                     ( cod.[ECTTypeCode] = 'ICD9-Diag' )
                                     AND ( cod.[ECTCodeDescription] IN ( 'IVD' ) ) ) ) AS cand_pat
    GROUP BY
        cand_pat.[UserId]
    HAVING
        COUNT(*) >= @Num_Encounters_IVD
INSERT INTO
    #DiabetesPatients
    SELECT
        cand_pat.[UserId]
    FROM
        ( SELECT DISTINCT
              [UserId] ,
              [ClaimInfoId] ,
              [ProcedureId] ,
              [BeginServiceDate]
          FROM
              #DiabetesPatients_Candidates
          WHERE
              [ProcedureId] IN ( SELECT
                                     cod.[ECTCode]
                                 FROM
                                     dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-C' , @ECTCodeVersion_Year , @ECTCodeStatus) AS cod
                                 WHERE
                                     ( cod.[ECTTypeCode] = 'CPT' )
                                     AND ( cod.[ECTCodeDescription] IN ( 'Outpatient' , 'Acute inpatient' ) ) ) ) AS cand_pat
    GROUP BY
        cand_pat.[UserId]
    HAVING
        COUNT(*) >= @Num_Encounters_Outpatient_AcuteInPatient


SELECT
    [UserID]
FROM
    #DiabetesPatients
ORDER BY
    [UserID]


DROP TABLE #DiabetesPatients_Candidates ;
DROP TABLE #DiabetesPatients ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_CMC_GetPatients_EncouterClaims_2012] TO [FE_rohit.r-ext]
    AS [dbo];

