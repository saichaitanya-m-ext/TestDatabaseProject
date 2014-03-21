
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_Metrics_Select_DD] 23
Description   : This Procedure used to Metric Page drop downs
Created By    : P.V.P.Mohan
Created Date  : 15-Nov-2012
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Metrics_Select_DD] (
	@i_AppUserId KEYID
	,@v_PopulationType VARCHAR(1) = NULL --> P- PopulationDef , C-Condition Def, M- ManagedPopulation
	)
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

	--------------------------------------------------------------------
	IF @v_PopulationType IS NULL
	BEGIN
		SELECT StandardId
			,NAME
			,StandardOrganizationId
		FROM Standard
		WHERE Standard.StatusCode = 'A'
		ORDER BY NAME

		SELECT StandardOrganizationId
			,NAME
			,Description
		FROM StandardOrganization
		WHERE StatusCode = 'A'
		ORDER BY NAME

		SELECT IOMCategoryid
			,NAME
		FROM IOMCategory
		WHERE StatusCode = 'A'
		ORDER BY NAME

		SELECT InsuranceGroupID
			,GroupName
		FROM InsuranceGroup
		WHERE StatusCode = 'A'
		ORDER BY GroupName

		SELECT PopulationDefinitionID
			,PopulationDefinitionName
		FROM PopulationDefinition
		WHERE DefinitionType = 'P'
			AND StatusCode = 'A'
			AND ProductionStatus = 'F'

		SELECT MeasureId
			,NAME
		FROM Measure
		WHERE IsVital = 0
			AND IsSynonym = 0
			AND StatusCode = 'A'
		ORDER BY NAME
	END
	ELSE
	BEGIN
		IF @v_PopulationType = 'P'
		BEGIN
			SELECT PopulationDefinitionID
				,PopulationDefinitionName
			FROM PopulationDefinition
			WHERE DefinitionType = 'P'
				AND StatusCode = 'A'
				AND ProductionStatus = 'F'
		END

		IF @v_PopulationType = 'C'
		BEGIN
			SELECT PopulationDefinitionID
				,PopulationDefinitionName
			FROM PopulationDefinition
			WHERE DefinitionType = 'C'
				AND StatusCode = 'A'
				AND ProductionStatus = 'F'
		END

		IF @v_PopulationType = 'M'
		BEGIN
			SELECT ProgramId
				,ProgramName
			FROM Program
			WHERE StatusCode = 'A'
		END

		IF @v_PopulationType = 'N'
		BEGIN
			SELECT PopulationDefinitionID
				,PopulationDefinitionName
			FROM PopulationDefinition
			WHERE DefinitionType IN ('N','U')
				AND StatusCode = 'A'
				AND ProductionStatus = 'F'
		END
	END
END TRY

---------------------------------------------------------------------   
BEGIN CATCH
	-- Handle exception        
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Metrics_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

