
/*
-------------------------------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_PopulationDefinition_Search_DD] 23
Description	  : This procedure is used to select the details from CohortWise Standards and their StandaradOrganizations
Created By    :	Rathnam
Created Date  : 10-Dec-2012
--------------------------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinition_Search_DD] -- 23
	(@i_AppUserId KEYID)
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

	----------- Select all the Activity details ---------------
	SELECT DISTINCT StandardId
		,NAME
	FROM Standard
	INNER JOIN PopulationDefinition ON Standard.StandardId = PopulationDefinition.StandardsId
	WHERE Standard.StatusCode = 'A'
	ORDER BY NAME

	SELECT DISTINCT StandardOrganization.StandardOrganizationId
		,StandardOrganization.NAME
	FROM StandardOrganization
	INNER JOIN PopulationDefinition ON StandardOrganization.StandardOrganizationId = PopulationDefinition.StandardOrganizationId
	WHERE StandardOrganization.StatusCode = 'A'
	ORDER BY NAME

	SELECT ConditionID
		,ConditionName
	FROM Condition
	WHERE StatusCode = 'A'
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinition_Search_DD] TO [FE_rohit.r-ext]
    AS [dbo];

