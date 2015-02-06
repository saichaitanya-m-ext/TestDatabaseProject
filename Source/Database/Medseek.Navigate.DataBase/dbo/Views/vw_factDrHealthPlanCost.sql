
CREATE VIEW [dbo].[vw_factDrHealthPlanCost]
AS
SELECT DISTINCT dr.PatientID
	,dr.DateKey
	,Dr.DrID
	,igp.InsuranceGroupId
	,dr.ClaimAmt
FROM PatientDr dr WITH (NOLOCK)
INNER JOIN PatientInsurance pie WITH (NOLOCK)
	ON pie.PatientID = dr.PatientID
INNER JOIN PatientInsuranceBenefit pib WITH (NOLOCK)
	ON pib.PatientInsuranceID = pie.PatientInsuranceID
INNER JOIN ReportFrequencyConfiguration rfc WITH (NOLOCK)
	ON rfc.drid = dr.DrID
INNER JOIN ReportFrequency rf WITH (NOLOCK)
	ON rf.ReportFrequencyId = rfc.ReportFrequencyId
INNER JOIN InsuranceGroupPlan igp WITH (NOLOCK)
	ON igp.InsuranceGroupPlanId = pie.InsuranceGroupPlanId
INNER JOIN AnchorDate ad WITH (NOLOCK)
	ON ad.DateKey = dr.DateKey
INNER JOIN Report r WITH (NOLOCK)
	ON r.ReportId = rf.ReportID
WHERE AnchorDate BETWEEN DATEADD(dd, - (DAY(pib.DateOfEligibility) - 1), pib.DateOfEligibility)
		AND CASE 
				WHEN YEAR(pib.CoverageEndsDate) = 9999
					THEN pib.CoverageEndsDate
				ELSE DATEADD(d, - 1, DATEADD(m, DATEDIFF(m, 0, pib.CoverageEndsDate) + 1, 0))
				END
	AND r.ReportName = 'TotalPatient Vs Total Cost'
