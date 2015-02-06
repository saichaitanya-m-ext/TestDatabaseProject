


CREATE FUNCTION [dbo].[ufn_GetInsureds2]
(	
	@InsurancePlanType varchar(100),
	@InsuranceProductType char(1),
	@InsuranceBenefitType varchar(100),

	@AnchorDate_Year int,
	@AnchorDate_Month int,
	@AnchorDate_Day int,

	@IsPrimary bit,

	@InsuranceGroupStatus varchar(1),
	@InsurancePlanStatus varchar(1),
	@InsurancePolicyStatus varchar(1)
)
RETURNS TABLE
AS

RETURN
(
	/************************************************************ INPUT PARAMETERS ************************************************************

	 @InsuranceProductType = Type of Insurance Products that Insureds selected for inclusion in Eligible Population can have.

	 @InsurancePlanType = Type of Insurance Plan that Insureds selected for inclusion in Eligible Population can have.

	 @InsuranceBenefitType = Type of Insurance Benefit that Insureds selected for inclusion in Eligible Population must have.

	 @AnchorDate_Year = Year of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Month = Month of the Anchor Date during the Measurement Year for which Eligible Population is to be constructed.

	 @AnchorDate_Day = Day in the Month of the Anchor Date during the Measurement Year for which Eligible Population is to be constructed.

	 @IsPrimary = Specification of whether an Insurance Benefit is Primary for an Insured.  Examples:  1 (for 'Yes'), or 0 (for 'No').

	 @InsuranceGroupStatus = Status of the Insurance Group with which Insureds included in the Eligible Population have Insurance Policy during
							 the Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @InsurancePlanStatus = Status of the Insurance Plan that Insureds subcribe to be included in the Eligible Population during the
							Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @InsurancePolicyStatus = Status of the Insurance Policy under which an Insured receives Insurance Benefit that qualifies an Insured for
							  inclusion in the Eligible Population during the Measurment.
							  Examples:  1 (for 'Enabled') or 0 (for 'Disabled').

	 *********************************************************************************************************************************************/


	SELECT pat_ins.[PatientID], pat_ins.[PatientInsuranceID], pat_ins.[StatusCode] AS 'InsurancePolicyStatus',
		   ibt.[BenefitTypeName], pat_insb.[IsPrimary], pat_insb.[DateOfEligibility], pat_insb.[CoverageEndsDate],
		   pat_ins.[MemberID],
		   pat_ins.[PolicyNumber], pat_ins.[GroupNumber], pat_ins.[DependentSequenceNo], pat_ins.[SequenceNo],
		   pat_ins.[PolicyHolderPatientID] AS 'PolicyHolderPatientID', pat_ins.[SuperGroupCategory],
		   (CASE
				 WHEN pcp.[PCPName] IS NOT NULL THEN pcp.[PCPName]
				 ELSE pat.[PCPName]
			END) AS 'PCPName',
		   (CASE
				 WHEN pcp.[ProviderID] IS NOT NULL THEN pcp.[ProviderID]
				 ELSE pat.[PCPInternalProviderID]
			END) AS 'PCPInternalProviderID',
		   (CASE
				 WHEN pcp.[NPINumber] IS NOT NULL THEN pcp.[NPINumber]
				 ELSE pat.[PCPNPI]
			END) AS 'PCPNPI', pcp.[PCPSystem], pcp.[CareBeginDate] AS 'PCPCareBeginDate',
		   pcp.[CareEndDate] AS 'PCPCareEndDate', ig.[InsuranceGroupID], ig.[GroupName] AS 'InsuranceGroupName', ig.[StatusCode] AS 'InsuranceGroupStatus',
		   pat_ins.[InsuranceGroupPlanID], igp.[PlanName] AS 'InsurancePlanName',
		   (CASE
				 WHEN igp.[ProductType] = 'C' THEN 'Commercial'
				 WHEN igp.[ProductType] = 'M' THEN 'Medicare'
				 WHEN igp.[ProductType] = 'I' THEN 'Medicaid'
			END) AS 'InsuranceProductType', 
		   hpc.[Name] AS 'InsurancePlanType', igp.[StatusCode] AS 'InsurancePlanStatus'

	FROM [dbo].[PatientInsurance] pat_ins
	INNER JOIN [dbo].[Patient] pat ON pat.[PatientID] = pat_ins.[PatientID]

	INNER JOIN [dbo].[PatientInsuranceBenefit] pat_insb ON (pat_insb.[PatientInsuranceID] = pat_ins.[PatientInsuranceID]) AND
														   (pat_insb.[IsPrimary] = @IsPrimary)

	INNER JOIN [dbo].[LkUpInsuranceBenefitType] ibt ON (ibt.[InsuranceBenefitTypeID] = pat_insb.[InsuranceBenefitTypeID]) AND
													   (ibt.[BenefitTypeName] = @InsuranceBenefitType)

	INNER JOIN [dbo].[InsuranceGroupPlan] igp ON (igp.[InsuranceGroupPlanID] = pat_ins.[InsuranceGroupPlanID]) AND
												 ((igp.[ProductType] = @InsuranceProductType) OR (igp.[ProductType] IS NULL)) AND
												  (igp.[StatusCode] = @InsurancePlanStatus)

	INNER JOIN [dbo].[InsuranceGroup] ig ON (ig.[InsuranceGroupID] = igp.[InsuranceGroupID]) AND
											(ig.[StatusCode] = @InsuranceGroupStatus)

	INNER JOIN [dbo].[HealthPlanCoverage] hpc ON (hpc.[HealthPlanCoverageID] = igp.[HealthPlanCoverageID]) AND
												 (hpc.[Name] = @InsurancePlanType)

	OUTER APPLY dbo.ufn_GetPatientPCPInfo(pat_ins.[PatientID], pat_insb.[DateOfEligibility], pat_insb.[CoverageEndsDate]) AS pcp

	WHERE (pat_ins.[StatusCode] = @InsurancePolicyStatus) AND
		  ((DATEPART(YYYY, pat_insb.[DateOfEligibility]) <= @AnchorDate_Year) AND
		   (DATEPART(YYYY, pat_insb.[CoverageEndsDate]) >= @AnchorDate_Year))

);


