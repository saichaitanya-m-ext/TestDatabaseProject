


CREATE FUNCTION [dbo].[ufn_GetInsuredBenefits]
(
	@InsuranceProductTypes     VARCHAR(30),
	@InsurancePlanTypes        VARCHAR(1000),
	@InsuranceBenefitTypes     VARCHAR(1000),
	@AnchorDate_Year           INT,
	@AnchorDate_Month          INT,
	@AnchorDate_Day            INT,
	@IsPrimary                 BIT,
	@Num_Months_Prior          INT,
	@Num_Months_After          INT,
	@InsuranceGroupStatus      VARCHAR(1),
	@InsurancePlanStatus       VARCHAR(1),
	@InsurancePolicyStatus     VARCHAR(1)
)
RETURNS @retInsuredsBenefits TABLE 
        (
            [PatientID] INT NOT NULL,
            [InsuranceProductType] CHAR(1) NOT NULL,
            [InsurancePlanType] VARCHAR(100) NOT NULL,
            [InsuranceBenefitType] VARCHAR(150) NOT NULL,
            [DateOfEligibility] DATETIME NOT NULL,
            [CoverageEndsDate] DATETIME NOT NULL,
            [PolicyHolderPatientID] INT NOT NULL,
            PRIMARY KEY(
                [PatientID],
                [InsuranceProductType],
                [InsurancePlanType],
                [InsuranceBenefitType],
                [DateOfEligibility],
                [CoverageEndsDate],
                [PolicyHolderPatientID]
            )
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

	 @Num_Months_Prior = Number of Months Before the Anchor Date from which Eligible Population of Insureds is to be constructed.

	 @Num_Months_After = Number of Months After the Anchor Date from which Eligible Population of Insureds is to be constructed.

	 @InsuranceGroupStatus = Status of the Insurance Group with which Insureds included in the Eligible Population have Insurance Policy during
							 the Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @InsurancePlanStatus = Status of the Insurance Plan that Insureds subcribe to be included in the Eligible Population during the
							Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @InsurancePolicyStatus = Status of the Insurance Policy under which an Insured receives Insurance Benefit that qualifies an Insured for
							  inclusion in the Eligible Population during the Measurment.
							  Examples:  1 (for 'Enabled') or 0 (for 'Disabled').

	 *********************************************************************************************************************************************/

BEGIN
	DECLARE @InsuranceProductType CHAR(1),
	        @InsurancePlanType VARCHAR(100),
	        @InsuranceBenefitType VARCHAR(150),
	        @Num_InsuranceBenefitTypes INT,
	        @PatientID INT
	
	
	/* Temporary Table, as a Table Variable, containing intermediate list of Insureds to be evaluated for selection in Eligible Population of
	Insureds. */
	DECLARE @PatientsCandidate TABLE
	        (
	            [PatientID] INT NOT NULL,
	            [InsuranceProductType] CHAR(1) NOT NULL,
	            [InsurancePlanType] VARCHAR(100) NOT NULL,
	            [InsuranceBenefitType] VARCHAR(150) NOT NULL,
	            [DateOfEligibility] DATETIME NOT NULL,
	            [CoverageEndsDate] DATETIME NOT NULL,
	            [PolicyHolderPatientID] INT NOT NULL,
	            PRIMARY KEY(
	                [PatientID],
	                [InsuranceProductType],
	                [InsurancePlanType],
	                [InsuranceBenefitType],
	                [DateOfEligibility],
	                [CoverageEndsDate],
	                [PolicyHolderPatientID]
	            )
	        )
	
	
	/* Extracts 'Insurance Product Types' from Input List variable @InsuranceProductTypes into a table variable. */
	DECLARE @ListTable_ProductTypes tblListTable_String
	
	IF @InsuranceProductTypes IS NULL
	    SET @InsuranceProductTypes = 'C,M,I';
	
	INSERT INTO @ListTable_ProductTypes
	SELECT DISTINCT [ElementVal]
	FROM   dbo.ufn_ConvertListToTable_String (@InsuranceProductTypes, DEFAULT, DEFAULT)
	
	
	/* Extracts 'Insurance Plan Types' from Input List variable @InsurancePlanTypes into a table variable. */
	DECLARE @ListTable_PlanTypes tblListTable_String
	
	IF @InsurancePlanTypes IS NOT NULL
	BEGIN
	    INSERT INTO @ListTable_PlanTypes
	    SELECT DISTINCT [ElementVal]
	    FROM   dbo.ufn_ConvertListToTable_String (@InsurancePlanTypes, DEFAULT, DEFAULT)
	END
	ELSE
	BEGIN
	    INSERT INTO @ListTable_PlanTypes
	    SELECT DISTINCT [Name]
	    FROM   [dbo].[HealthPlanCoverage]
	END
	
	
	/* Extracts 'Insurance Benefit Types' from Input List variable @InsuranceBenefitTypes into a table variable. */
	DECLARE @ListTable_BenefitTypes tblListTable_String
	
	IF @InsuranceBenefitTypes IS NOT NULL
	BEGIN
	    INSERT INTO @ListTable_BenefitTypes
	    SELECT DISTINCT [ElementVal]
	    FROM   dbo.ufn_ConvertListToTable_String (@InsuranceBenefitTypes, DEFAULT, DEFAULT)
	END
	ELSE
	BEGIN
	    INSERT INTO @ListTable_BenefitTypes
	    SELECT DISTINCT [BenefitTypeName]
	    FROM   [dbo].[LkUpInsuranceBenefitType]
	END
	
	
	INSERT INTO @PatientsCandidate
	  (
	    PatientID,
	    InsuranceProductType,
	    InsurancePlanType,
	    InsuranceBenefitType,
	    DateOfEligibility,
	    CoverageEndsDate,
	    PolicyHolderPatientID
	  )
	SELECT [PatientID],
	       [ProductType],
	       [Name],
	       [BenefitTypeName],
	       [DateOfEligibility],
	       [CoverageEndsDate],
	       PolicyHolderPatientID
	FROM   (
	           SELECT DISTINCT 
	                  RANK() OVER(
	                      PARTITION BY pat.[PatientID],
	                      igp.[ProductType] ORDER BY pib.[CoverageEndsDate] DESC
	                  )     ID,
	                  pat.[PatientID],
	                  igp.[ProductType],
	                  hpc.[Name],
	                  ibt.[BenefitTypeName],
	                  pib.[DateOfEligibility],
	                  pib.[CoverageEndsDate],
	                  (
	                      CASE 
	                           WHEN pat_ins.[PolicyHolderPatientID] IS NOT NULL THEN 
	                                pat_ins.[PolicyHolderPatientID]
	                           ELSE ''
	                      END
	                  )  AS [PolicyHolderPatientID]
	           FROM   [dbo].[Patient] pat
	                  INNER JOIN [dbo].[PatientInsurance] pat_ins
	                       ON  (pat_ins.[PatientID] = pat.[PatientID])
	                       AND (pat_ins.StatusCode = @InsurancePolicyStatus)
	                  INNER JOIN [dbo].[InsuranceGroupPlan] igp
	                       ON  (
	                               igp.[InsuranceGroupPlanId] = pat_ins.[InsuranceGroupPlanId]
	                           )
	                       AND (
	                               (
	                                   igp.[ProductType] IN (SELECT [ElementVal]
	                                                         FROM   @ListTable_ProductTypes)
	                               )
	                               OR (igp.[ProductType] IS NULL)
	                           )
	                       AND (igp.[StatusCode] = @InsurancePlanStatus)
	                  INNER JOIN [dbo].[InsuranceGroup] ig
	                       ON  (ig.[InsuranceGroupID] = igp.[InsuranceGroupId])
	                       AND (ig.[StatusCode] = @InsuranceGroupStatus)
	                  INNER JOIN [dbo].[HealthPlanCoverage] hpc
	                       ON  (hpc.[HealthPlanCoverageID] = igp.[HealthPlanCoverageID])
	                       AND (
	                               hpc.[Name] IN (SELECT [ElementVal]
	                                              FROM   @ListTable_PlanTypes)
	                           )
	                  INNER JOIN [dbo].[PatientInsuranceBenefit] pib
	                       ON  (pib.[PatientInsuranceID] = pat_ins.[PatientInsuranceID])
	                       AND (pib.[IsPrimary] = @IsPrimary)
	                  INNER JOIN [dbo].[LkUpInsuranceBenefitType] ibt
	                       ON  (
	                               ibt.[InsuranceBenefitTypeID] = pib.[InsuranceBenefitTypeID]
	                           )
	                       AND (
	                               ibt.[BenefitTypeName] IN (SELECT [ElementVal]
	                                                         FROM   @ListTable_BenefitTypes)
	                           )
	           WHERE  (
	                      (
	                          (
	                              pib.[DateOfEligibility] <= (
	                                  DATEADD(
	                                      MM,
	                                      -@Num_Months_Prior,
	                                      (
	                                          CONVERT(VARCHAR, @AnchorDate_Year) 
	                                          + '-' +
	                                          CONVERT(VARCHAR, @AnchorDate_Month) 
	                                          + '-' +
	                                          CONVERT(VARCHAR, @AnchorDate_Day)
	                                      )
	                                  )
	                              )
	                          )
	                          AND (
	                                  pib.[CoverageEndsDate] > (
	                                      DATEADD(
	                                          MM,
	                                          -@Num_Months_Prior,
	                                          (
	                                              CONVERT(VARCHAR, @AnchorDate_Year) 
	                                              + '-' 
	                                              +
	                                              CONVERT(VARCHAR, @AnchorDate_Month) 
	                                              + '-' 
	                                              +
	                                              CONVERT(VARCHAR, @AnchorDate_Day)
	                                          )
	                                      )
	                                  )
	                              )
	                      )
	                      OR (
	                             (
	                                 pib.[DateOfEligibility] BETWEEN (
	                                     DATEADD(
	                                         MM,
	                                         -@Num_Months_Prior,
	                                         (
	                                             CONVERT(VARCHAR, @AnchorDate_Year) 
	                                             + '-' +
	                                             CONVERT(VARCHAR, @AnchorDate_Month) 
	                                             + '-' 
	                                             +
	                                             CONVERT(VARCHAR, @AnchorDate_Day)
	                                         )
	                                     )
	                                 ) AND
	                                 (
	                                     DATEADD(
	                                         MM,
	                                         @Num_Months_After,
	                                         (
	                                             CONVERT(VARCHAR, @AnchorDate_Year) 
	                                             + '-' +
	                                             CONVERT(VARCHAR, @AnchorDate_Month) 
	                                             + '-' 
	                                             +
	                                             CONVERT(VARCHAR, @AnchorDate_Day)
	                                         )
	                                     )
	                                 )
	                             )
	                             AND (
	                                     (
	                                         pib.[CoverageEndsDate] BETWEEN (
	                                             DATEADD(
	                                                 MM,
	                                                 -@Num_Months_Prior,
	                                                 (
	                                                     CONVERT(VARCHAR, @AnchorDate_Year) 
	                                                     + '-' +
	                                                     CONVERT(VARCHAR, @AnchorDate_Month) 
	                                                     + '-' +
	                                                     CONVERT(VARCHAR, @AnchorDate_Day)
	                                                 )
	                                             )
	                                         ) AND
	                                         (
	                                             DATEADD(
	                                                 MM,
	                                                 @Num_Months_After,
	                                                 (
	                                                     CONVERT(VARCHAR, @AnchorDate_Year) 
	                                                     + '-' +
	                                                     CONVERT(VARCHAR, @AnchorDate_Month) 
	                                                     + '-' +
	                                                     CONVERT(VARCHAR, @AnchorDate_Day)
	                                                 )
	                                             )
	                                         )
	                                     )
	                                     OR (
	                                            pib.[CoverageEndsDate] > (
	                                                DATEADD(
	                                                    MM,
	                                                    -@Num_Months_After,
	                                                    (
	                                                        CONVERT(VARCHAR, @AnchorDate_Year) 
	                                                        + '-' +
	                                                        CONVERT(VARCHAR, @AnchorDate_Month) 
	                                                        + '-' +
	                                                        CONVERT(VARCHAR, @AnchorDate_Day)
	                                                    )
	                                                )
	                                            )
	                                        )
	                                 )
	                         )
	                  )
	       )a
	WHERE  a.id = 1
	
	
	/* Loads the 'User IDs' of Insureds who have Health Coverage(s) for the Benefit Type that Insureds must subscribe to -- Current or Past --
	to be included in Eligible Population of Insureds, into a cursor. */
	-- Obtains the Number of Insurance Benefit Types for which benefit coverage must be checked for an Insured. --
	SELECT @Num_InsuranceBenefitTypes = COUNT(*)
	FROM   @ListTable_BenefitTypes
	
	INSERT INTO @retInsuredsBenefits
	SELECT DISTINCT pc.[PatientID],
	       pc.[InsuranceProductType],
	       pc.[InsurancePlanType],
	       pc.[InsuranceBenefitType],
	       pc.[DateOfEligibility],
	       pc.[CoverageEndsDate],
	       pc.[PolicyHolderPatientID]
	FROM   @PatientsCandidate pc
	       INNER JOIN (
	                SELECT DISTINCT [PatientID]
	                FROM   @PatientsCandidate
	                GROUP BY
	                       [PatientID]
	                       --,[InsuranceBenefitType]
	                HAVING (COUNT([PatientID]) >= @Num_InsuranceBenefitTypes)
	            ) AS dp
	            ON  dp.[PatientID] = pc.[PatientID]
	
	RETURN
END;


