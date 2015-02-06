
CREATE VIEW [dbo].[vw_factProviderHealthPlanAmt]
AS
SELECT DISTINCT igp.InsuranceGroupId
	,ad.DateKey
	,cp.ProviderID
	,cp.ClaimInfoID
	,ci.NetPaidAmount Amt
FROM PatientInsuranceBenefit pib WITH (NOLOCK)
INNER JOIN PatientInsurance pi1 WITH (NOLOCK)
	ON pi1.PatientInsuranceID = pib.PatientInsuranceID
INNER JOIN ClaimInfo ci
	ON ci.PatientID = pi1.PatientID
INNER JOIN ClaimProvider cp
	ON cp.ClaimInfoID = ci.ClaimInfoId
INNER JOIN InsuranceGroupPlan igp WITH (NOLOCK)
	ON igp.InsuranceGroupPlanId = pi1.InsuranceGroupPlanId
INNER JOIN AnchorDate ad
	ON ad.AnchorDate = CASE 
			WHEN ad.AnchorDate BETWEEN DATEADD(dd, - (DAY(pib.DateOfEligibility) - 1), pib.DateOfEligibility)
					AND CASE 
							WHEN YEAR(pib.CoverageEndsDate) = 9999
								THEN pib.CoverageEndsDate
							ELSE DATEADD(d, - 1, DATEADD(m, DATEDIFF(m, 0, pib.CoverageEndsDate) + 1, 0))
							END
				THEN ad.AnchorDate
			ELSE NULL
			END
		AND ad.AnchorDate BETWEEN DATEADD(dd, - (DAY(ci.DateOfAdmit) - 1), ci.DateOfAdmit)
			AND DATEADD(d, - 1, DATEADD(m, DATEDIFF(m, 0, ci.DateOfDischarge) + 1, 0))
