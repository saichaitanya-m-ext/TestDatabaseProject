
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_PopulationDefinitionCriteria_Insert
Description   : This procedure is used to insert record into CohortListCriteria table    
Created By    : Rathnam        
Created Date  : 16-Dec-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION   
06-07-2012  Sivakrishna Removed JoinType,JoinStatement,OnClause,WhereClause,DiseaseDefinitionID 
realted params as per new requirement and added @vc_CohortGeneralizedIdList,@vc_CohortCriteriaSQL 
parameters.
12-07-2012  Kalyan Modified the output parameter to input parameter and added the update functionality
21-Aug-2012 Gurumoorthy Modified the CohortlistCriteria Update Statement for a perticular CohortlistId and PopulationDefPanelConfigurationID
29-Aug-2012 Gurumoorthy V modified Existing update condition
14-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinitionCriteria_Insert] (
	@i_AppUserId KEYID
	,@i_PopulationDefinitionID KEYID
	,@vc_PopulationDefinitionCriteriaText VARCHAR(MAX)
	,@i_PopulationDefPanelConfigurationID INT
	,@vc_PopulationDefinitionCriteriaSQL VARCHAR(MAX)
	,@vc_CohortGeneralizedIdList VARCHAR(MAX)
	,@i_PopulationDefinitionCriteriaID KEYID
	,@xml_XMLDefenition XML = NULL
	,@b_IsBuildDraft BIT = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsInserted INT
		,@i_CohortListCriteriaTypeID KEYID

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

	--------- Insert Operation into CohortListCriteria Table starts here ---------    
	IF EXISTS (
			SELECT 1
			FROM PopulationDefinitionCriteria clc
			INNER JOIN PopulationDefPanelConfiguration pd ON clc.PopulationDefPanelConfigurationID = pd.PopulationDefPanelConfigurationID
			WHERE clc.PopulationDefinitionID = @i_PopulationDefinitionID
				AND clc.PopulationDefPanelConfigurationID = @i_PopulationDefPanelConfigurationID
				AND pd.PanelorGroupName IN (
					'Compound'
					,'Build Definition'
					)
			)
	BEGIN
		UPDATE PopulationDefinitionCriteria
		SET PopulationDefinitionID = @i_PopulationDefinitionID
			,PopulationDefinitionCriteriaSQL = @vc_PopulationDefinitionCriteriaSQL
			,PopulationDefinitionCriteriaText = @vc_PopulationDefinitionCriteriaText
			,PopulationDefPanelConfigurationID = @i_PopulationDefPanelConfigurationID
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
			,CohortGeneralizedIdList = @vc_CohortGeneralizedIdList
			,XMLDefenition = @xml_XMLDefenition
			,IsBuildDraft = @b_IsBuildDraft
		WHERE PopulationDefinitionID = @i_PopulationDefinitionID
			AND PopulationDefPanelConfigurationID = @i_PopulationDefPanelConfigurationID
	END
	ELSE
	BEGIN
		INSERT INTO PopulationDefinitionCriteria (
			PopulationDefinitionID
			,PopulationDefinitionCriteriaSQL
			,PopulationDefinitionCriteriaText
			,PopulationDefPanelConfigurationID
			,CreatedByUserId
			,CohortGeneralizedIdList
			,XMLDefenition
			,IsBuildDraft
			)
		VALUES (
			@i_PopulationDefinitionID
			,@vc_PopulationDefinitionCriteriaSQL
			,@vc_PopulationDefinitionCriteriaText
			,@i_PopulationDefPanelConfigurationID
			,@i_AppUserId
			,@vc_CohortGeneralizedIdList
			,@xml_XMLDefenition
			,@b_IsBuildDraft
			)

		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT

		IF @l_numberOfRecordsInserted <> 1
		BEGIN
			RAISERROR (
					N'Invalid row count %d in insert CohortListCriteria'
					,17
					,1
					,@l_numberOfRecordsInserted
					)
		END
	END

	RETURN 0
END TRY

--------------------------------------------------------       
BEGIN CATCH
	-- Handle exception      
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinitionCriteria_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

