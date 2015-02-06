CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_CDC_GetPatients_RxClaims_2012]
(
	@AnchorDate_Year int = 2012,
	@AnchorDate_Month int = 12,
	@AnchorDate_Day int = 31,

	@Num_Months_Prior int = 24,
	@Num_Months_After int = 0,

	@Num_Rx_Dispense int = 1,

	@ECTCodeVersion_Year int = 2012,
	@ECTCodeStatus varchar(1) = 'A'
)
AS

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @AnchorDate_Year = Year of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Month = Month of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Day = Day in the Month of the Anchor Date for which Eligible Population is to be constructed.

	 @Num_Months_Prior = Number of Months Before the Anchor Date from which Eligible Population of Patients with Pharmacy/Rx Claims
						 is to be constructed.

	 @Num_Months_After = Number of Months After the Anchor Date from which Eligible Population of Patients with Pharmacy/Rx Claims
						 is to be constructed.

	 @Num_Rx_Dispense = Number of Pharmacy/Rx Claims during the Measurement Period that identifies a Patient for inclusion in the Eligible
						Population of Patients.

	 @ECTCodeVersion_Year = Code Version Year from which valid HEDIS-associated NDC Drug Codes are retrieved for use in selection of Patients
							for inclusion in the Eligible Population of Patients with Pharmacy/Rx Claims during the Measurement Period.

	 @ECTCodeStatus = Status of valid HEDIS-associated NDC Drug Codes that are retrieved for use in selection of Patients for inclusion in
					  the Eligible Population of Patients with Pharmacy/Rx Claims during the Measurement Period.
					  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 *********************************************************************************************************************************************/


SELECT cp.[PatientID]
FROM
(
 SELECT [PatientID], [MemberID], [RxClaimNumber], [NDCCode], [BrandName], [DateFilled], [DaysSupply], [QuantityDispensed]

 FROM dbo.ufn_HEDIS_GetPatients_RxClaims('CDC-A', @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @Num_Months_Prior,
										 @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus)
 WHERE [DaysSupply] > 0
) AS cp
GROUP BY cp.[PatientID]
HAVING (COUNT(*) >= @Num_Rx_Dispense)

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_CDC_GetPatients_RxClaims_2012] TO [FE_rohit.r-ext]
    AS [dbo];

