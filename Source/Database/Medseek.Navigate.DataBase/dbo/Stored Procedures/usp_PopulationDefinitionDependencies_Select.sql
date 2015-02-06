
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_PopulationDefinitionDependencies_Select] 1 ,10   
Description   : 
Created By    : Rathnam       
Created Date  : 22-Aug-12
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
07-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinition & ConditionDefinition
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinitionDependencies_Select] (
	@i_AppUserId KEYID
	,@i_PopulationDefinitionID KEYID
	)
AS
BEGIN
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

		SELECT
			IncludedCohortListId PopulationDefinitionID
			,PopulationDefinition.PopulationDefinitionName
			,CASE 
				WHEN Type = 'C'
					THEN 'Copy'
				ELSE 'Include'
				END Type
			,CASE 
				WHEN NonModifiable = 0
					OR PopulationDefinition.DefinitionType = 'C'
					THEN 1
				ELSE 0
				END IsModifiable
			,dbo.ufn_GetDiseaseNameByID(PopulationDefinition.ConditionID) AS DiseaseName
		FROM CohortListDependencies WITH (NOLOCK)
		INNER JOIN PopulationDefinition WITH (NOLOCK) ON PopulationDefinition.PopulationDefinitionID = CohortListDependencies.IncludedCohortListId
		WHERE CohortListDependencies.PopulationDefinitionID = @i_PopulationDefinitionID
	END TRY

	--------------------------------------------------------         
	BEGIN CATCH
		-- Handle exception        
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinitionDependencies_Select] TO [FE_rohit.r-ext]
    AS [dbo];

