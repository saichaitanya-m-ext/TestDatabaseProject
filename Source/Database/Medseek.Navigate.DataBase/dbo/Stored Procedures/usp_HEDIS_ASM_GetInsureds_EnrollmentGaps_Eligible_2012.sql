CREATE PROCEDURE [dbo].[usp_HEDIS_ASM_GetInsureds_EnrollmentGaps_Eligible_2012]
(
 @InsurancePlanType varchar(100) ,
 @InsuranceProductType char(1) ,
 @InsuranceBenefitType varchar(100) ,
 @AnchorDate_Year int ,
 @AnchorDate_Month int ,
 @AnchorDate_Day int ,
 @IsPrimary bit ,
 @AllowedEnrollmentGaps int ,
 @AllowedEnrollmentGaps_MAXDays int ,
 @InsuranceGroupStatus varchar(1) ,
 @InsurancePlanStatus varchar(1) ,
 @InsurancePolicyStatus varchar(1)
)
AS /************************************************************ INPUT PARAMETERS ************************************************************

	 @InsuranceProductType = Type of Insurance Products that Insureds selected for inclusion in Eligible Population can have.

	 @InsurancePlanType = Type of Insurance Plan that Insureds selected for inclusion in Eligible Population can have.

	 @InsuranceBenefitType = Type of Insurance Benefit that Insureds selected for inclusion in Eligible Population must have.

	 @AnchorDate_Year = Year of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Month = Month of the Anchor Date during the Measurement Year for which Eligible Population is to be constructed.

	 @AnchorDate_Day = Day in the Month of the Anchor Date during the Measurement Year for which Eligible Population is to be constructed.

	 @IsPrimary = Specification of whether an Insurance Benefit is Primary for an Insured.  Examples:  1 (for 'Yes'), or 0 (for 'No').

	 @AllowedEnrollmentGaps = Maximum number of allowable number of Gaps in Coverage Enrollment in a specified Insurance Benefit by an Insured.

	 @AllowedEnrollmentGaps_MAXDays = Maximum number of allowable number of days during any given Gap in Coverage Enrollment in a specified
									  Insurance Benefit by an Insured.

	 @InsuranceGroupStatus = Status of the Insurance Group with which Insureds included in the Eligible Population have Insurance Policy during
							 the Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @InsurancePlanStatus = Status of the Insurance Plan that Insureds subcribe to be included in the Eligible Population during the
							Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @InsurancePolicyStatus = Status of the Insurance Policy under which an Insured receives Insurance Benefit that qualifies an Insured for
							  inclusion in the Eligible Population during the Measurment.
							  Examples:  1 (for 'Enabled') or 0 (for 'Disabled').

	 *********************************************************************************************************************************************/


DECLARE
        @UserID int ,
        @UserInsuranceID int ,
        @DateOfEligibility datetime ,
        @CoverageEndsDate datetime ,
        @CoverageEndsDate_Previous datetime ,
        @InsuredEligible bit


CREATE TABLE #Insureds
(
  [UserID] int NULL ,
  [DateOfEligibility] datetime NULL ,
  [CoverageEndsDate] datetime NULL
)

CREATE NONCLUSTERED INDEX IX_Insureds_UserID ON #Insureds ( [UserID] ) ;


CREATE TABLE #Insureds_Eligible
(
  [UserID] int
)

CREATE CLUSTERED INDEX IX_InsuredsEligible_UserID ON #Insureds_Eligible ( [UserID] ) ;


INSERT INTO
    #Insureds
    SELECT
        insureds.[UserId] ,
        insureds.[DateOfEligibility] ,
        insureds.[CoverageEndsDate]
    FROM
        dbo.ufn_GetInsureds(@InsurancePlanType , @InsuranceProductType , @InsuranceBenefitType , @AnchorDate_Year , @AnchorDate_Month , @AnchorDate_Day , @IsPrimary , @InsuranceGroupStatus , @InsurancePlanStatus , @InsurancePolicyStatus) AS insureds
    INNER JOIN dbo.ufn_GetInsureds_AllowedEnrollmentGaps(@InsurancePlanType , @InsuranceProductType , @InsuranceBenefitType , @AnchorDate_Year , @AnchorDate_Month , @AnchorDate_Day , @IsPrimary , @AllowedEnrollmentGaps , @AllowedEnrollmentGaps_MAXDays , @InsuranceGroupStatus , @InsurancePlanStatus , @InsurancePolicyStatus) AS insureds_elig
        ON insureds_elig.[UserId] = insureds.[UserId]


DECLARE insureds_cursor CURSOR
        FOR SELECT DISTINCT
                [UserId]
            FROM
                #Insureds

OPEN insureds_cursor ;

FETCH NEXT FROM insureds_cursor INTO @UserID
WHILE @@FETCH_STATUS = 0
      BEGIN
            DECLARE insureds_coverages_cursor CURSOR
                    FOR SELECT
                            [UserId] ,
                            [DateOfEligibility] ,
                            [CoverageEndsDate]
                        FROM
                            #Insureds
                        WHERE
                            [UserId] = @UserID

            OPEN insureds_coverages_cursor ;

            FETCH NEXT FROM insureds_coverages_cursor INTO @UserID,@DateOfEligibility,@CoverageEndsDate

            SET @CoverageEndsDate_Previous = NULL

            SET @InsuredEligible = 1
            WHILE ( @@FETCH_STATUS = 0 )
            AND ( @InsuredEligible = 1 )
                  BEGIN
                        IF @CoverageEndsDate_Previous IS NOT NULL
                           BEGIN
                                 IF DATEDIFF(dd , @CoverageEndsDate_Previous , @DateOfEligibility) > @AllowedEnrollmentGaps_MAXDays
                                    SET @InsuredEligible = 0

                                 SET @CoverageEndsDate_Previous = @CoverageEndsDate
                           END
                        ELSE
                           BEGIN
                                 SET @CoverageEndsDate_Previous = @CoverageEndsDate
                           END

                        FETCH NEXT FROM insureds_coverages_cursor INTO @UserID,@DateOfEligibility,@CoverageEndsDate
                  END

            CLOSE insureds_coverages_cursor ;
            DEALLOCATE insureds_coverages_cursor ;

            IF @InsuredEligible = 1
               BEGIN
                     INSERT INTO
                         #Insureds_Eligible
                         (
                           UserId
                         )
                         SELECT
                             @UserID
               END

            FETCH NEXT FROM insureds_cursor INTO @UserID
      END

CLOSE insureds_cursor ;
DEALLOCATE insureds_cursor ;


SELECT
    [UserID]
FROM
    #Insureds_Eligible
ORDER BY
    [UserId]


DROP TABLE #Insureds ;
DROP TABLE #Insureds_Eligible ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_ASM_GetInsureds_EnrollmentGaps_Eligible_2012] TO [FE_rohit.r-ext]
    AS [dbo];

