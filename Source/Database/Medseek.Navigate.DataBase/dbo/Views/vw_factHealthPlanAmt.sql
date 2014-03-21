
CREATE VIEW [dbo].[vw_factHealthPlanAmt]
AS
SELECT PatientID
	,InsuranceGroupId
	,DateKey
	,Amt
FROM (
	SELECT *
		,(
			SELECT SUM(NetPaidAmount)
			FROM ClaimInfo ci WITH (NOLOCK)
			WHERE t.AnchorDate BETWEEN DATEADD(dd, - (DAY(ci.DateOfAdmit) - 1), ci.DateOfAdmit)
					AND DATEADD(d, - 1, DATEADD(m, DATEDIFF(m, 0, ci.DateOfDischarge) + 1, 0))
				AND ci.PatientID = t.PatientID
			) Amt
	FROM (
		SELECT DISTINCT pi1.PatientID
			,igp.InsuranceGroupId
			,ad.DateKey
			,ad.AnchorDate
		FROM PatientInsuranceBenefit pib WITH (NOLOCK)
		INNER JOIN PatientInsurance pi1 WITH (NOLOCK)
			ON pi1.PatientInsuranceID = pib.PatientInsuranceID
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
		) t
	) t1
WHERE Amt IS NOT NULL
