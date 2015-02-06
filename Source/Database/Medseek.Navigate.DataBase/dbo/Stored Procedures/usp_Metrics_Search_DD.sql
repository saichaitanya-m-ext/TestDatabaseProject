
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_Metrics_Search_DD]1
Description   : This Procedure used to Metric Page search dropdowns
Created By    : Rathnam
Created Date  : 8-Dec-2012
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
22/08/2013 Santosh modified denominatorid to managedpopulationid
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Metrics_Search_DD] (
	@i_AppUserId KEYID
	,@v_StatusCode STATUSCODE = 'A'
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

		--------------------------------------------------------------------
		SELECT DISTINCT s.StandardId
			,s.NAME
			,s.StandardOrganizationId
		FROM Standard s
		INNER JOIN Metric m ON s.StandardId = m.StandardId
		WHERE s.StatusCode = @v_StatusCode
			AND m.StatusCode = @v_StatusCode
		ORDER BY NAME

		SELECT DISTINCT so.StandardOrganizationId
			,so.NAME
			,so.Description
		FROM StandardOrganization so
		INNER JOIN Metric m ON so.StandardOrganizationId = m.StandardOrganizationId
		WHERE so.StatusCode = @v_StatusCode
			AND m.StatusCode = @v_StatusCode
		ORDER BY NAME

		SELECT DISTINCT ic.IOMCategoryid
			,ic.NAME
		FROM IOMCategory ic
		INNER JOIN Metric m ON ic.IOMCategoryid = m.IOMCategoryid
		WHERE ic.StatusCode = @v_StatusCode
			AND m.StatusCode = @v_StatusCode
		ORDER BY NAME

		SELECT DISTINCT ig.InsuranceGroupID
			,ig.GroupName
		FROM InsuranceGroup ig
		INNER JOIN Metric m ON ig.InsuranceGroupID = m.InsuranceGroupID
		WHERE ig.StatusCode = @v_StatusCode
			AND m.StatusCode = @v_StatusCode
		ORDER BY GroupName

		SELECT DISTINCT pd.PopulationDefinitionID NumeratorID
			,pd.PopulationDefinitionName NumeratorName
		FROM PopulationDefinition pd
		INNER JOIN Metric m ON pd.PopulationDefinitionID = m.NumeratorID
		WHERE DefinitionType = 'N'
			AND pd.StatusCode = @v_StatusCode
			AND m.StatusCode = @v_StatusCode

		SELECT DISTINCT pd.PopulationDefinitionID
			,pd.PopulationDefinitionName
			,pd.DefinitionType
		FROM PopulationDefinition pd
		INNER JOIN Metric m ON pd.PopulationDefinitionID = m.DenominatorID
			AND pd.DefinitionType = m.DenominatorType
		WHERE pd.DefinitionType IN (
				'P'
				,'C'
				)
			AND pd.StatusCode = @v_StatusCode
			AND m.StatusCode = @v_StatusCode
		
		UNION
		
		SELECT DISTINCT p.ProgramId
			,p.ProgramName
			,m.DenominatorType
		FROM Program p
		INNER JOIN Metric m ON p.ProgramId = m.managedpopulationID
		WHERE m.DenominatorType = 'M'
			AND p.StatusCode = @v_StatusCode
			AND m.StatusCode = @v_StatusCode
	END TRY

	---------------------------------------------------------------------   
	BEGIN CATCH
		-- Handle exception        
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Metrics_Search_DD] TO [FE_rohit.r-ext]
    AS [dbo];

