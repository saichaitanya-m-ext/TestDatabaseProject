
/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_InsuranceGroupAndPlan_Select]
Description	  : This procedure is used to select all the active Groups and plans 
Created By    :	Rathnam 
Created Date  : 07-July-2012
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

----------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_InsuranceGroupAndPlan_Select] (@i_AppUserId KEYID)
AS
BEGIN TRY
	-- Check if valid Application User ID is passed
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.'
				,17
				,1
				,@i_AppUserId
				)
	END

	---------------- All the Active Insurance Group Names are retrieved --------
	SELECT InsuranceGroupID
		,GroupName
	FROM InsuranceGroup
	WHERE StatusCode = 'A'
	ORDER BY GroupName

	SELECT InsuranceGroupPlanId
		,InsuranceGroupId
		,PlanName
	FROM InsuranceGroupPlan
	WHERE StatusCode = 'A'
	ORDER BY PlanName
END TRY

BEGIN CATCH
	-----------------------------------------------------------------------------------------
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_InsuranceGroupAndPlan_Select] TO [FE_rohit.r-ext]
    AS [dbo];

