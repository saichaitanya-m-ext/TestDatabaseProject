
/*
-------------------------------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_CohortListCriteria_Select]23,4
Description	  : This procedure is used to select the details from CohortListCriteria,CohortListCriteriaType tables.
Created By    :	Rathnam
Created Date  : 16-Dec-2011
--------------------------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
14-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID

--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinitionCriteria_Select] (
	@i_AppUserId KEYID
	,@i_PopulationDefinitionID KEYID
	)
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
	SELECT PopulationDefinitionCriteria.PopulationDefinitionCriteriaID
		,PopulationDefinitionCriteria.PopulationDefinitionID
		,PopulationDefPanelConfiguration.PanelorGroupName AS CriteriaTypeName
		,PopulationDefinitionCriteria.PopulationDefinitionCriteriaSQL
		,PopulationDefinitionCriteria.PopulationDefinitionCriteriaText
		,PopulationDefinitionCriteria.CreatedByUserId
		,PopulationDefinitionCriteria.CreatedDate
		,PopulationDefinitionCriteria.LastModifiedByUserId
		,PopulationDefinitionCriteria.LastModifiedDate
		,PopulationDefinitionCriteria.PopulationDefPanelConfigurationID
		,PopulationDefinitionCriteria.CohortGeneralizedIdList
		,PopulationDefinition.PopulationDefinitionName
	FROM PopulationDefinitionCriteria WITH (NOLOCK)
	INNER JOIN PopulationDefPanelConfiguration WITH (NOLOCK) ON PopulationDefinitionCriteria.PopulationDefPanelConfigurationID = PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID
	LEFT JOIN PopulationDefinition WITH (NOLOCK) ON PopulationDefinition.PopulationDefinitionID = PopulationDefinitionCriteria.PopulationDefinitionID
	WHERE PopulationDefinitionCriteria.PopulationDefinitionID = @i_PopulationDefinitionID
	ORDER BY PopulationDefinitionCriteria.PopulationDefinitionID
		,PopulationDefPanelConfiguration.PanelorGroupName
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinitionCriteria_Select] TO [FE_rohit.r-ext]
    AS [dbo];

