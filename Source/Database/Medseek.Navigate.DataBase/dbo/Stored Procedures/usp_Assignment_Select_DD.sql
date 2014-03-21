
/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_Assignment_Select_DD]  
Description   : This procedure is used to get the list of all populations, Diseases which are assigned to program
Created By    : Rathanm
Created Date  : 28-Sep-2012 
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION 
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers 
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Assignment_Select_DD] (@i_AppUserId INT)
AS
BEGIN TRY
	SET NOCOUNT ON

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

	SELECT DISTINCT cl.PopulationDefinitionID
		,cl.PopulationDefinitionName
	FROM Program p WITH (NOLOCK)
	INNER JOIN PopulationDefinition cl WITH (NOLOCK) ON cl.PopulationDefinitionId = p.PopulationDefinitionId
	WHERE p.PopulationDefinitionId IS NOT NULL

	SELECT DISTINCT d.ConditionDefinitionID
		,d.ConditionName
	FROM Program p WITH (NOLOCK)
	INNER JOIN PopulationDefinition cl WITH (NOLOCK) ON cl.PopulationDefinitionId = p.PopulationDefinitionId
	INNER JOIN ConditionDefinition d WITH (NOLOCK) ON d.ConditionDefinitionID = cl.PopulationDefinitionID
	WHERE p.PopulationDefinitionId IS NOT NULL
END TRY

----------------------------------------------------------   
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Assignment_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

