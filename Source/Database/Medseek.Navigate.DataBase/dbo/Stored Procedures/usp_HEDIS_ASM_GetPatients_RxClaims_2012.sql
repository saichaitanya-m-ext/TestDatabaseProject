CREATE PROCEDURE [dbo].[usp_HEDIS_ASM_GetPatients_RxClaims_2012]
(
 @AnchorDate_Year int ,
 @AnchordDate_Month int ,
 @AnchordDate_Day int ,
 @Num_Years_Prior int ,
 @Num_Years_After int ,
 @Num_Rx_Dispense int ,
 @ECTCodeStatus varchar(1) ,
 @ECTCodeVersion_Year int
)
AS /************************************************************ INPUT PARAMETERS ************************************************************

	 @AnchorDate_Year = Year of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Month = Month of the Anchor Date during the Measurement Year for which Eligible Population is to be constructed.

	 @AnchorDate_Day = Day in the Month of the Anchor Date during the Measurement Year for which Eligible Population is to be constructed.

	 @Num_Years_Prior = Number of years prior to the Anchor Date for which Eligible Population of Patients with "Diabetes" are to be constructed.

	 @Num_Years_After = Number of years after the Anchor Date for which Eligible Population of Patients with "Diabetes" are to be constructed.

	 @Num_Rx_Dispense = Number of Pharmacy/Rx Claims during the Measurement Period that identifies a Patient for inclusion in the Eligible
						Population of Patients with "Diabetes".

	 @ECTCodeStatus = Status of valid HEDIS-associated NDC Drug Codes that are retrieved for use in selection of Patients for inclusion in
					  the Eligible Population of Patients with "Diabetes" Pharmacy/Rx Claims during the Measurement Period.
					  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @ECTCodeVersion_Year = Code Version Year from which valid HEDIS-associated NDC Drug Codes are retrieved for use in selection of Patients
							for inclusion in the Eligible Population of Patients with "Diabetes" Pharmacy/Rx Claims during the Measurement Period.

	 *********************************************************************************************************************************************/


DECLARE @UserID int


CREATE TABLE #DiabetesPatients_Candidates
(
  [UserId] int NULL ,
  [MemberNum] varchar(50) NULL ,
  [RxClaimNum] varchar(50) NULL ,
  [DrugCode] varchar(15) NULL ,
  [BrandName] varchar(100) NULL ,
  [DateFilled] datetime NULL
)

CREATE NONCLUSTERED INDEX IX_DiabetesPatientsCandidates_UserId ON #DiabetesPatients_Candidates ( [UserID] ) ;


CREATE TABLE #DiabetesPatients
(
  [UserID] int
)

CREATE NONCLUSTERED INDEX IX_DiabetesPatients_UserID ON #DiabetesPatients ( [UserID] ) ;


INSERT INTO
    #DiabetesPatients_Candidates
    SELECT
        pat.[UserId] ,
        pat.[MemberNum] ,
        pat.[RxClaimNum] ,
        pat.[DrugCode] ,
        pat.[BrandName] ,
        pat.[DateFilled]
    FROM
        dbo.ufn_HEDIS_ASM_GetPatients_RxClaims(@AnchorDate_Year , @AnchordDate_Month , @AnchordDate_Day , @Num_Years_Prior , @Num_Years_After , @ECTCodeStatus , @ECTCodeVersion_Year) AS pat


INSERT INTO
    #DiabetesPatients
    SELECT
        [UserId]
    FROM
        #DiabetesPatients_Candidates
    GROUP BY
        [UserId]
    HAVING
        ( COUNT(*) >= @Num_Rx_Dispense )


SELECT
    [UserID]
FROM
    #DiabetesPatients
ORDER BY
    [UserId]


DROP TABLE #DiabetesPatients_Candidates ;
DROP TABLE #DiabetesPatients ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_ASM_GetPatients_RxClaims_2012] TO [FE_rohit.r-ext]
    AS [dbo];

