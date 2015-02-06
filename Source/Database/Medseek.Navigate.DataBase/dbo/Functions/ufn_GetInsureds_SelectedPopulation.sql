


CREATE FUNCTION [dbo].[ufn_GetInsureds_SelectedPopulation]
(	
	@InsurancePlanType varchar(100),
	@InsuranceProductType char(1),
	@InsuranceBenefitType varchar(100),

	@PopulationDefinitionID int,
	@AnchorYear_NumYearsOffset int,

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

	 @PopulationDefinitionID = Handle to the selected Population of Patients from which the Eligible Population of Patients of the Numerator
							   are to be constructed.

	 @AnchorYear_NumYearsOffset = Number of Years of OFFSET -- After (+) or Before (-) -- from the Anchor Year around which the Patients in the
								  selected Population was chosen, serving as the new Anchor Year around which the Eligible Population of
								  Patients is to be constructed.

	 @IsPrimary = Specification of whether an Insurance Benefit is Primary for an Insured.  Examples:  1 (for 'Yes'), or 0 (for 'No').

	 @InsuranceGroupStatus = Status of the Insurance Group with which Insureds included in the Eligible Population have Insurance Policy during
							 the Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @InsurancePlanStatus = Status of the Insurance Plan that Insureds subcribe to be included in the Eligible Population during the
							Measurement Period.  Examples = 1 (for 'Enabled') or 0 (for 'Disabled').

	 @InsurancePolicyStatus = Status of the Insurance Policy under which an Insured receives Insurance Benefit that qualifies an Insured for
							  inclusion in the Eligible Population during the Measurment.
							  Examples:  1 (for 'Enabled') or 0 (for 'Disabled').

	 *********************************************************************************************************************************************/


	SELECT p.[PatientID], pat_ins.[PatientInsuranceID], pat_ins.[StatusCode] AS 'InsurancePolicyStatus',
		   ibt.[BenefitTypeName], pat_insb.[IsPrimary], pat_insb.[DateOfEligibility], pat_insb.[CoverageEndsDate],
		   pat_ins.[MemberID], pat_ins.[PolicyNumber], pat_ins.[GroupNumber], pat_ins.[DependentSequenceNo],
		   pat_ins.[SequenceNo], pat_ins.[PolicyHolderPatientID] AS 'PolicyHolderPatientID',
		   pat_ins.[SuperGroupCategory], ig.[InsuranceGroupID], ig.[GroupName] AS 'InsuranceGroupName',
		   ig.[StatusCode] AS 'InsuranceGroupStatus', pat_ins.[InsuranceGroupPlanID], igp.[PlanName] AS 'InsurancePlanName',
		   (CASE
				 WHEN igp.[ProductType] = 'C' THEN 'Commercial'
				 WHEN igp.[ProductType] = 'M' THEN 'Medicare'
				 WHEN igp.[ProductType] = 'I' THEN 'Medicaid'
			END) AS 'InsuranceProductType', 
		   hpc.[Name] AS 'InsurancePlanType', igp.[StatusCode] AS 'InsurancePlanStatus'

	FROM [dbo].[PopulationDefinitionPatients] p
	INNER JOIN [dbo].[PopulationDefinitionPatientAnchorDate] pa ON pa.PopulationDefinitionPatientID = p.PopulationDefinitionPatientID
	INNER JOIN [dbo].[PatientInsurance] pat_ins ON (pat_ins.[PatientID] = p.[PatientID]) AND
												   (pat_ins.StatusCode = @InsurancePolicyStatus)

	INNER JOIN [dbo].[PatientInsuranceBenefit] pat_insb ON (pat_insb.[PatientInsuranceID] = pat_ins.[PatientInsuranceID]) AND
														   (pat_insb.[IsPrimary] = @IsPrimary)

	INNER JOIN [dbo].[LkUpInsuranceBenefitType] ibt ON (ibt.[InsuranceBenefitTypeID] = pat_insb.[InsuranceBenefitTypeID]) AND
													   (ibt.[BenefitTypeName] = @InsuranceBenefitType)

	INNER JOIN [dbo].[InsuranceGroupPlan] igp ON (igp.[InsuranceGroupPlanID] = pat_ins.[InsuranceGroupPlanID]) AND
												 ((igp.[ProductType] = @InsuranceProductType) OR (igp.[ProductType] IS NULL)) AND
												  (igp.[StatusCode] = @InsurancePlanStatus)

	INNER JOIN [dbo].[InsuranceGroup] ig ON (ig.[InsuranceGroupID] = igp.[InsuranceGroupID]) AND (ig.[StatusCode] = @InsuranceGroupStatus)

	INNER JOIN [dbo].[HealthPlanCoverage] hpc ON (hpc.[HealthPlanCoverageID] = igp.[HealthPlanCoverageID]) AND
												 (hpc.[Name] = @InsurancePlanType)

	WHERE (p.[PopulationDefinitionID] = @PopulationDefinitionID) AND (p.[StatusCode] = 'A') AND
		  (DATEPART(YYYY, pat_insb.[DateOfEligibility]) <=DATEPART(YYYY,DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate])))AND
		  (DATEPART(YYYY, pat_insb.[CoverageEndsDate]) >= DATEPART(YYYY,DATEADD(YYYY, @AnchorYear_NumYearsOffset, pa.[OutputAnchorDate]))))


