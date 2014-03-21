
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_PopulationDefinitionFilter_Select] 1,14
Description   : This procedure is used to select the details from CohortList tables.  
Created By    : Gurumoorthy.V  
Created Date  : 28-Aug-2012
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
06-Nov-2012 P.V.P.Mohan changes the name of Procedure, changed parameters and added parameters 
10-Dec-2012 Rathnam removed the conditiondefinitionid parameter
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinitionFilter_Select] (
	@i_AppUserId KEYID
	,@i_PopulationDefinitionID KeyID = NULL
	,@v_PopulationDefinitionName VARCHAR(250) = NULL
	,@i_ConditionDefinitionID KeyID = NULL
	,@v_DefinitionType VARCHAR(1) = 'P'
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
	IF (@v_DefinitionType = 'P')
	BEGIN
		SELECT DISTINCT PopulationDefinition.PopulationDefinitionID
			,PopulationDefinition.PopulationDefinitionName
			,CASE 
				WHEN PopulationDefinition.DefinitionType = 'C'
					THEN 'True'
				ELSE 'False'
				END IsDiseaseDefinition
			,dbo.ufn_GetDiseaseNameByID(PopulationDefinition.ConditionID) AS DiseaseName
			,CASE 
				WHEN PopulationDefinition.NonModifiable = 0
					THEN 1
				ELSE 0
				END IsModifiable
		FROM PopulationDefinition WITH (NOLOCK)
		INNER JOIN PopulationDefinitionCriteria WITH (NOLOCK) ON PopulationDefinition.PopulationDefinitionID = PopulationDefinitionCriteria.PopulationDefinitionID
		INNER JOIN PopulationDefPanelConfiguration WITH (NOLOCK) ON PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID = PopulationDefinitionCriteria.PopulationDefPanelConfigurationID
		WHERE (
				PopulationDefinition.PopulationDefinitionID <> @i_PopulationDefinitionID
				OR @i_PopulationDefinitionID IS NULL
				)
			AND (
				PopulationDefinition.ConditionID = @i_ConditionDefinitionID
				OR @i_ConditionDefinitionID IS NULL
				)
			AND StatusCode = 'A'
			AND ProductionStatus = 'F'
			AND (
				PopulationDefinition.PopulationDefinitionName LIKE '%' + @v_PopulationDefinitionName + '%'
				OR @v_PopulationDefinitionName IS NULL
				)
			AND PanelorGroupName = 'Build Definition'
			AND PopulationDefinition.DefinitionType IN (
				'P'
				,'C'
				)
		ORDER BY PopulationDefinition.PopulationDefinitionName
	END
	ELSE
	BEGIN
		SELECT DISTINCT PopulationDefinition.PopulationDefinitionID
			,PopulationDefinition.PopulationDefinitionName
			,'' AS IsDiseaseDefinition
			,'' AS IsModifiable
		FROM PopulationDefinition WITH (NOLOCK)
		INNER JOIN PopulationDefinitionCriteria WITH (NOLOCK) ON PopulationDefinition.PopulationDefinitionID = PopulationDefinitionCriteria.PopulationDefinitionID
		INNER JOIN PopulationDefPanelConfiguration WITH (NOLOCK) ON PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID = PopulationDefinitionCriteria.PopulationDefPanelConfigurationID
		WHERE (
				PopulationDefinition.PopulationDefinitionID <> @i_PopulationDefinitionID
				OR @i_PopulationDefinitionID IS NULL
				)
			AND StatusCode = 'A'
			AND ProductionStatus = 'F'
			AND (
				PopulationDefinition.PopulationDefinitionName LIKE '%' + @v_PopulationDefinitionName + '%'
				OR @v_PopulationDefinitionName IS NULL
				)
			AND PanelorGroupName = 'Build Definition'
			AND PopulationDefinition.DefinitionType IN ('N')
		ORDER BY PopulationDefinition.PopulationDefinitionName
	END
END TRY

BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinitionFilter_Select] TO [FE_rohit.r-ext]
    AS [dbo];

