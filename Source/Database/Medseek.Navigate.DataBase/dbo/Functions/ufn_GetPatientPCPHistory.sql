


CREATE FUNCTION [dbo].[ufn_GetPatientPCPHistory]
(
	@PatientID int
)
RETURNS TABLE
AS

RETURN
(
	/************************************************************ INPUT PARAMETERS ************************************************************

	 @PatientID = System-Internal Unique ID of the Insured Patient for which 'Primary Care Physician' (or PCP) History is to be retrieved.

	 *********************************************************************************************************************************************/


	 SELECT pcp.[PCPHistoryID], prov.[FirstName] + ' ' + prov.[LastName] AS 'PCPName',
			pcp.[ProviderID], prov.[NPINumber], pcp.[PCPSystem], pcp.[CareBeginDate],
			pcp.[CareEndDate]

	 FROM [dbo].[PatientPCP] pcp
	 LEFT OUTER JOIN [dbo].[Provider] prov ON prov.[ProviderID] = pcp.[ProviderID]

	 WHERE pcp.[PatientID] = @PatientID

) ;


