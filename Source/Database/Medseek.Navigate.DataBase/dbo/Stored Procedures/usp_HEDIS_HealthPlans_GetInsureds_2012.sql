CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_GetInsureds_2012]
(
	@InsuranceProductTypes varchar(30) = NULL,
	@InsurancePlanTypes varchar(1000) = NULL,
	@InsuranceBenefitTypes varchar(1000) = 'Major Medical (MM)',

	@AnchorDate_Year int = 2011,
	@AnchorDate_Month int = 12,
	@AnchorDate_Day int = 31,

	@IsPrimary bit = 1,

	@NumMonths_Prior_Insured_Commercial int = 12,
	@NumMonths_After_Insured_Commercial int = 0,

	@NumMonths_Prior_Insured_Medicare int = 12,
	@NumMonths_After_Insured_Medicare int = 0,

	@NumMonths_Prior_Insured_Medicaid int = 12,
	@NumMonths_After_Insured_Medicaid int = 0,

	@Enrollment_AllowedNumGaps_Commercial int = 1,
	@Enrollment_MAXDaysPerGap_Commercial int = 45,

	@Enrollment_AllowedNumGaps_Medicare int = 1,
	@Enrollment_MAXDaysPerGap_Medicare int = 45,

	@Enrollment_AllowedNumGaps_Medicaid int = 1,
	@Enrollment_MAXDaysPerGap_Medicaid int = 30,

	@InsuranceGroupStatus varchar(1) = 'A',
	@InsurancePlanStatus varchar(1) = 'A',
	@InsurancePolicyStatus varchar(1) = 'A'
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

	 @IsPrimary = Specification of whether an Insurance Benefit is Primary for an Insured.  Examples:  1 (for 'Yes'), or 0 (for 'No').


	 @NumMonths_Prior_Insured_Commercial = Number of Months Prior to the Anchor Date from which Eligible Population of Insureds for an Insurance
										   Product of Type "Commercial" is to be constructed.

	 @NumMonths_After_Insured_Commercial = Number of Months After the Anchor Date from which Eligible Population of Insureds for an Insurance
										   Product of Type "Commercial" is to be constructed.

	 @NumMonths_Prior_Insured_Medicare = Number of Months Prior to the Anchor Date from which Eligible Population of Insureds for an Insurance
										 Product of Type "Medicare" is to be constructed.

	 @NumMonths_After_Insured_Medicare = Number of Months After the Anchor Date from which Eligible Population of Insureds for an Insurance
										 Product of Type "Medicare" is to be constructed.

	 @NumMonths_Prior_Insured_Medicaid = Number of Months Prior to the Anchor Date from which Eligible Population of Insureds for an Insurance
										 Product of Type "Medicaid" is to be constructed.

	 @NumMonths_After_Insured_Medicaid = Number of Months After the Anchor Date from which Eligible Population of Insureds for an Insurance
										 Product of Type "Medicaid" is to be constructed.


	 @Enrollment_AllowedNumGaps_Commercial = Maximum number of 'Allowable Number of Gaps in Coverage Enrollment' for a specified Insurance
											 Benefit on an Insurance Policy of Type "Commercial" Insurance Product by an Insured.

	 @Enrollment_MAXDaysPerGap_Commercial = Maximum number of 'Allowable Number of Days During a Gap in Coverage Enrollment' for a specified
											Insurance Benefit on an Insurance Policy of Type "Commercial" Insurance Product by an Insured.

	 @Enrollment_AllowedNumGaps_Medicare = Maximum number of 'Allowable Number of Gaps in Coverage Enrollment' for a specified Insurance
										   Benefit on an Insurance Policy of Type "Medicare" Insurance Product by an Insured.

	 @Enrollment_MAXDaysPerGap_Medicare = Maximum number of 'Allowable Number of Days During a Gap in Coverage Enrollment' for a specified
										  Insurance Benefit on an Insurance Policy of Type "Medicare" Insurance Product by an Insured.

	 @Enrollment_AllowedNumGaps_Medicaid = Maximum number of 'Allowable Number of Gaps in Coverage Enrollment' for a specified Insurance
										   Benefit on an Insurance Policy of Type "Medicaid" Insurance Product by an Insured.

	 @Enrollment_MAXDaysPerGap_Medicaid = Maximum number of 'Allowable Number of Days During a Gap in Coverage Enrollment' for a specified
										  Insurance Benefit on an Insurance Policy of Type "Medicaid" Insurance Product by an Insured.


	 @InsuranceGroupStatus = Status of the Insurance Group with which Insureds included in the Eligible Population have Insurance Policy during
							 the Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @InsurancePlanStatus = Status of the Insurance Plan that Insureds subcribe to be included in the Eligible Population during the
							Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @InsurancePolicyStatus = Status of the Insurance Policy under which an Insured receives Insurance Benefit that qualifies an Insured for
							  inclusion in the Eligible Population during the Measurment.
							  Examples:  1 (for 'Enabled') or 0 (for 'Disabled').

	 *********************************************************************************************************************************************/


/* Checks for existence of user-defined Table Type "tblLookupTable_String".  The Table Type is created if it does not exist.
   The Table Type is used to create Table variables that store String element values.   */
IF NOT EXISTS (SELECT * FROM [sys].[types] WHERE ([is_table_type] = 1) AND ([Name] = 'tblListTable_String'))
BEGIN
   CREATE TYPE [tblListTable_String] AS TABLE
   (
	 [ElementVal] varchar(900) NOT NULL PRIMARY KEY CLUSTERED
   )
END


DECLARE	@PatientID int,
		@InsuranceProductType char(1),
		@InsuranceBenefitType varchar(150),
		@DateOfEligibility datetime,
		@CoverageEndsDate datetime,
		@CoverageEndsDate_Previous datetime,
		@CoverageGaps_Count int,
		@CoverageGap_NumDays int,
		@InsuredEligible bit


/* Temporary Table containing list of Insureds that have Insurance Benefit coverages -- with gaps in coverages. */
CREATE TABLE #InsuredsBenefits
(
	[PatientID] int NOT NULL,
	[InsuranceProductType] char(1) NOT NULL,
	[InsurancePlanType] varchar(100) NOT NULL,
	[InsuranceBenefitType] varchar(150) NOT NULL,
	[DateOfEligibility] datetime NOT NULL,
	[CoverageEndsDate] datetime NOT NULL,
	[PolicyHolderPatientID] int NOT NULL,
	PRIMARY KEY ([PatientID], [InsuranceProductType], [InsurancePlanType], [InsuranceBenefitType], [DateOfEligibility],
				 [CoverageEndsDate], [PolicyHolderPatientID])
)


/* Temporary Table containing list of Insureds that have Insurance Benefit coverages -- with gaps in coverages -- that match requirements for
   inclusion in Eligible Population of Insureds. */
CREATE TABLE #EligibleInsureds
(
	[PatientID] int NOT NULL PRIMARY KEY CLUSTERED
)


/* Extracts 'Insurance Product Types' from Input List variable @InsuranceProductTypes into a table variable. */
DECLARE @ListTbl_ProductTypes tblListTable_String

IF @InsuranceProductTypes IS NULL
   SET @InsuranceProductTypes = 'C,M,I';

INSERT INTO @ListTbl_ProductTypes
SELECT DISTINCT [ElementVal]
FROM dbo.ufn_ConvertListToTable_String (@InsuranceProductTypes, DEFAULT, DEFAULT)



/* Retrieve Insureds with Insurance Policy of Type "Commercial" Insurance Product and their 'Insurance Coverage Periods'. */

IF EXISTS (SELECT * FROM @ListTbl_ProductTypes WHERE [ElementVal] = 'C')
BEGIN
   INSERT INTO #InsuredsBenefits
   SELECT [PatientID], [InsuranceProductType], [InsurancePlanType], [InsuranceBenefitType], [DateOfEligibility],
		  [CoverageEndsDate], [PolicyHolderPatientID]
   FROM dbo.ufn_GetInsuredBenefits('C', @InsurancePlanTypes, @InsuranceBenefitTypes,
								   @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @IsPrimary,
								   @NumMonths_Prior_Insured_Commercial, @NumMonths_After_Insured_Commercial,
								   @InsuranceGroupStatus, @InsurancePlanStatus, @InsurancePolicyStatus)
END


/* Retrieve Insureds with Insurance Policy of Type "Medicare" Insurance Product and their 'Insurance Coverage Periods'. */

IF EXISTS (SELECT * FROM @ListTbl_ProductTypes WHERE [ElementVal] = 'M')
BEGIN
   INSERT INTO #InsuredsBenefits
   SELECT [PatientID], [InsuranceProductType], [InsurancePlanType], [InsuranceBenefitType], [DateOfEligibility],
		  [CoverageEndsDate], [PolicyHolderPatientID]
   FROM dbo.ufn_GetInsuredBenefits('M', @InsurancePlanTypes, @InsuranceBenefitTypes,
								   @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @IsPrimary,
								   @NumMonths_Prior_Insured_Medicare, @NumMonths_After_Insured_Medicare,
								   @InsuranceGroupStatus, @InsurancePlanStatus, @InsurancePolicyStatus)
END


/* Retrieve Insureds with Insurance Policy of Type "Medicaid" Insurance Product and their 'Insurance Coverage Periods'. */

IF EXISTS (SELECT * FROM @ListTbl_ProductTypes WHERE [ElementVal] = 'I')
BEGIN
   INSERT INTO #InsuredsBenefits
   SELECT [PatientID], [InsuranceProductType], [InsurancePlanType], [InsuranceBenefitType], [DateOfEligibility],
		  [CoverageEndsDate], [PolicyHolderPatientID]
   FROM dbo.ufn_GetInsuredBenefits('I', @InsurancePlanTypes, @InsuranceBenefitTypes,
								   @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @IsPrimary,
								   @NumMonths_Prior_Insured_Medicaid, @NumMonths_After_Insured_Medicaid,
								   @InsuranceGroupStatus, @InsurancePlanStatus, @InsurancePolicyStatus)
END



/* Creates a cursor of 'Insurance Benefit Types', extracted from input List variable @InsuranceBenefitTypes. */
DECLARE BenefitTypes_cursor CURSOR FOR
SELECT [ElementVal]
FROM dbo.ufn_ConvertListToTable_String (@InsuranceBenefitTypes, DEFAULT, DEFAULT)


/* Creates a cursor of distinct 'Users' with a subscription to an Insurance Benefity (of ANY type). */
DECLARE Insureds_cursor CURSOR FOR
SELECT DISTINCT [PatientID]
FROM #InsuredsBenefits


OPEN Insureds_cursor;

FETCH NEXT FROM Insureds_cursor
INTO @PatientID;

WHILE @@FETCH_STATUS = 0
BEGIN
   SET @InsuredEligible = 1;

   OPEN BenefitTypes_cursor;

   FETCH NEXT FROM BenefitTypes_cursor
   INTO @InsuranceBenefitType;

   WHILE @@FETCH_STATUS = 0
   BEGIN
	  DECLARE Insureds_Coverages_cursor CURSOR FOR
	  SELECT [PatientID], [InsuranceProductType], [DateOfEligibility], [CoverageEndsDate]
	  FROM #InsuredsBenefits
	  WHERE ([PatientID] = @PatientID) AND ([InsuranceBenefitType] = @InsuranceBenefitType)

	  OPEN Insureds_Coverages_cursor;

	  FETCH NEXT FROM Insureds_Coverages_cursor
	  INTO @PatientID, @InsuranceProductType, @DateOfEligibility, @CoverageEndsDate;

	  SET @CoverageEndsDate_Previous = NULL;
	  SET @CoverageGaps_Count = 0;

	  WHILE (@@FETCH_STATUS = 0) AND (@InsuredEligible = 1) AND (@CoverageEndsDate < (CONVERT(varchar, @AnchorDate_Year) + '-' +
																					  CONVERT(varchar, @AnchorDate_Month) + '-' +
																					  CONVERT(varchar, @AnchorDate_Day)))
	  BEGIN
		 SET @CoverageGaps_Count = @CoverageGaps_Count + 1;

		 IF @InsuranceProductType = 'C' -- 'Commercial Insurance' --
		 BEGIN
			IF @CoverageGaps_Count > (@Enrollment_AllowedNumGaps_Commercial + 1)
			   SET @InsuredEligible = 0
			ELSE
			BEGIN
			   IF @CoverageEndsDate_Previous IS NOT NULL
			   BEGIN
				  SET @CoverageGap_NumDays = DATEDIFF(dd, @CoverageEndsDate_Previous, @DateOfEligibility);

				  IF (@CoverageGap_NumDays > 1) AND (@CoverageGap_NumDays > @Enrollment_MAXDaysPerGap_Commercial)
					 SET @InsuredEligible = 0
			   END

			   SET @CoverageEndsDate_Previous = @CoverageEndsDate;
			END
		 END
		 ELSE IF @InsuranceProductType = 'M' -- 'Medicare Insurance' --
		 BEGIN
			IF @CoverageGaps_Count > (@Enrollment_AllowedNumGaps_Medicare + 1)
			   SET @InsuredEligible = 0
			ELSE
			BEGIN
			   IF @CoverageEndsDate_Previous IS NOT NULL
			   BEGIN
				  SET @CoverageGap_NumDays = DATEDIFF(dd, @CoverageEndsDate_Previous, @DateOfEligibility);

				  IF (@CoverageGap_NumDays > 1) AND (@CoverageGap_NumDays > @Enrollment_MAXDaysPerGap_Medicare)
					 SET @InsuredEligible = 0
			   END

			   SET @CoverageEndsDate_Previous = @CoverageEndsDate;
			END
		 END
		 ELSE IF @InsuranceProductType = 'I' -- 'Medicaid Insurance' --
		 BEGIN
			IF @CoverageGaps_Count > (@Enrollment_AllowedNumGaps_Medicaid + 1)
			   SET @InsuredEligible = 0
			ELSE
			BEGIN
			   IF @CoverageEndsDate_Previous IS NOT NULL
			   BEGIN
				  SET @CoverageGap_NumDays = DATEDIFF(dd, @CoverageEndsDate_Previous, @DateOfEligibility);

				  IF (@CoverageGap_NumDays > 1) AND (@CoverageGap_NumDays > @Enrollment_MAXDaysPerGap_Medicaid)
					 SET @InsuredEligible = 0
			   END

			   SET @CoverageEndsDate_Previous = @CoverageEndsDate;
			END
		 END

		 FETCH NEXT FROM Insureds_Coverages_cursor
		 INTO @PatientID, @InsuranceProductType, @DateOfEligibility, @CoverageEndsDate;
	  END

	  CLOSE Insureds_Coverages_cursor;
	  DEALLOCATE Insureds_Coverages_cursor;


	  IF (@CoverageEndsDate_Previous IS NOT NULL) AND (@CoverageEndsDate_Previous < (CONVERT(varchar, @AnchorDate_Year) + '-' +
																					 CONVERT(varchar, @AnchorDate_Month) + '-' +
																					 CONVERT(varchar, @AnchorDate_Day)))
	  BEGIN
		 SET @InsuredEligible = 0
	  END

	  FETCH NEXT FROM BenefitTypes_cursor
	  INTO @InsuranceBenefitType;
   END

   CLOSE BenefitTypes_cursor;


   IF @InsuredEligible = 1
   BEGIN
	  INSERT INTO #EligibleInsureds
	  (
		[PatientID]
	  )
	  SELECT @PatientID
   END

   FETCH NEXT FROM Insureds_cursor
   INTO @PatientID;
END


DEALLOCATE BenefitTypes_cursor;

CLOSE insureds_cursor;
DEALLOCATE insureds_cursor;


SELECT [PatientID]
FROM #EligibleInsureds
ORDER BY [PatientID]

DROP TABLE #EligibleInsureds;
DROP TABLE #InsuredsBenefits;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_GetInsureds_2012] TO [FE_rohit.r-ext]
    AS [dbo];

