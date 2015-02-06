


CREATE FUNCTION [dbo].[ufn_GetPatientPCPInfo]
(
	@PatientID int,

	@CareBeginDate date,
	@CareEndDate date
)
RETURNS TABLE
AS

RETURN
(
	/************************************************************ INPUT PARAMETERS ************************************************************

	 @PatientID = System-Internal Unique ID of the Insured Patient for which 'Primary Care Physician' (or PCP) info is to be retrieved.

	 *********************************************************************************************************************************************/


	 SELECT TOP 1 pcp.[PCPHistoryID], prov.[FirstName] + ' ' + prov.[LastName] AS 'PCPName',
				  pcp.[ProviderID], prov.[NPINumber], pcp.[PCPSystem], pcp.[CareBeginDate],
				  pcp.[CareEndDate]

	 FROM [dbo].[PatientPCP] pcp
	 LEFT OUTER JOIN [dbo].[Provider] prov ON prov.[ProviderID] = pcp.[ProviderID]

	 WHERE (pcp.[PatientID] = @PatientID) AND
		   (((pcp.[CareBeginDate] < @CareBeginDate) AND (pcp.[CareEndDate] > @CareBeginDate)) OR
			(pcp.[CareBeginDate] >= @CareBeginDate))
	 ORDER BY [CareBeginDate] DESC, [CareEndDate] DESC

) ;


