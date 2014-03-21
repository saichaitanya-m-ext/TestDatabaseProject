




CREATE FUNCTION [dbo].[ufn_GetUserPCPInfo]
(
  @UserID int
)
RETURNS TABLE
AS
RETURN
      (
        /************************************************************ INPUT PARAMETERS ************************************************************

	 @UserId = System User ID of Insured for which 'Primary Care Physician' (or PCP) info is to be retrieved.

	 *********************************************************************************************************************************************/
        SELECT TOP 1
            [PatientId] ,
            [ProviderID] ,
            [PCPSystem] ,
            [CareBeginDate] ,
            [CareEndDate]
        FROM
            [PatientPCP]
        WHERE
            [PatientId] = @UserID
        ORDER BY
            [CareBeginDate] DESC ) ;

