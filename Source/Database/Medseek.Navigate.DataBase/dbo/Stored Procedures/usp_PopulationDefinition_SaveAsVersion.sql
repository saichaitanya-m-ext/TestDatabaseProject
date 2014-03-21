
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_PopulationDefinition_SaveAsVersion]1,9
Description   : This proc is used to store the history information of a cohort
Created By    : Rathnam
Created Date  : 30-Aug-2012
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
06-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added   
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinition_SaveAsVersion] (
	@i_AppUserId KEYID
	,@i_PopulationDefinitionID KEYID
	)
AS
BEGIN
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

		DECLARE @v_Version VARCHAR(5)

		SELECT @v_Version = DefinitionVersion
		FROM PopulationDefinition
		WHERE PopulationDefinitionID = @i_PopulationDefinitionID

		INSERT INTO CohortListHistory (
			PopulationDefinitionID
			,DefinitionVersion
			,CohortListName
			,CohortListDescription
			,LastDateListGenerated
			,StatusCode
			,RefreshPatientListDaily
			,CreatedByUserId
			,CreatedDate
			,NonModifiable
			,StandardId
			,Private
			,ProductionStatus
			,StandardOrganizationId
			,NumeratorType
			)
		SELECT PopulationDefinitionID
			,DefinitionVersion
			,PopulationDefinitionName
			,PopulationDefinitionDescription
			,LastDateListGenerated
			,StatusCode
			,RefreshPatientListDaily
			,@i_AppUserId
			,GETDATE()
			,NonModifiable
			,StandardsId
			,Private
			,ProductionStatus
			,StandardOrganizationId
			,NumeratorType
		FROM PopulationDefinition
		WHERE PopulationDefinitionID = @i_PopulationDefinitionID

		INSERT INTO CohortListCriteriaHistory (
			CohortCriteriaID
			,DefinitionVersion
			,PopulationDefinitionID
			,PopulationDefinitionCriteriaSQL
			,CohortCriteriaText
			,PopulationDefPanelConfigurationID
			,IsBuildDraft
			,CreatedByUserId
			,CreatedDate
			)
		SELECT clc.PopulationDefinitionCriteriaID
			,@v_Version
			,clc.PopulationDefinitionID
			,clc.PopulationDefinitionCriteriaSQL
			,clc.PopulationDefinitionCriteriaText
			,clc.PopulationDefPanelConfigurationID
			,clc.IsBuildDraft
			,@i_AppUserId
			,GETDATE()
		FROM PopulationDefinitionCriteria clc
		WHERE clC.PopulationDefinitionID = @i_PopulationDefinitionID

		INSERT INTO CohortListDependenciesHistory (
			CohortDependencyId
			,DefinitionVersion
			,PopulationDefinitionID
			,IncludedCohortListId
			,Type
			,IsDraft
			,CreatedByUserId
			,CreatedDate
			)
		SELECT DISTINCT cld.CohortDependencyId
			,@v_Version
			,cld.PopulationDefinitionID
			,cld.IncludedCohortListId
			,cld.Type
			,cld.IsDraft
			,@i_AppUserId
			,GETDATE()
		FROM CohortListDependencies cld
		WHERE cld.PopulationDefinitionID = @i_PopulationDefinitionID

		UPDATE PopulationDefinition
		SET DefinitionVersion = DBO.ufn_GetVersionNumber(@v_Version)
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		WHERE PopulationDefinitionID = @i_PopulationDefinitionID
	END TRY

	-----------------------------------------------------------------------------------------------------------------------------------------------      
	BEGIN CATCH
		-- Handle exception  
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinition_SaveAsVersion] TO [FE_rohit.r-ext]
    AS [dbo];

