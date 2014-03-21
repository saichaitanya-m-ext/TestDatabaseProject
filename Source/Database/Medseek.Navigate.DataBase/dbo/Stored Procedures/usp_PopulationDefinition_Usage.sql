
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_CohortList_Usage] 1,14
Description   : This Proc is used to get the Usage information of the cohort
Created By    : Rathnam
Created Date  : 04-09-12
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION
14-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID  
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinition_Usage] (
	@i_AppUserId KEYID
	,@i_PopulationDefinitionId KEYID
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

		-----------------------------------------------------------------------  
		SELECT pcl.CohortVersion
			,pt.NAME ProgramTypeID
			,p.ProgramName
			,pcl.CreatedDate UsageStartDate
			,dbo.ufn_GetUserNameByID(pcl.CreatedByUserId) CreatedBy
		FROM Program p WITH (NOLOCK)
		INNER JOIN ProgramCohortList pcl WITH (NOLOCK) ON p.ProgramId = pcl.ProgramID
		LEFT JOIN ProgramType pt WITH (NOLOCK) ON pt.ProgramTypeId = p.PopulationDefinitionID
		WHERE pcl.PopulationDefinitionID = @i_PopulationDefinitionID

		       
		DECLARE @tblVersion TABLE (
			PopulationDefinitionID INT
			,DefinitionVersion VARCHAR(5)
			,ModifiedDate DATETIME
			,ModifiedUserId INT
			,IncludedPopulationDefinition VARCHAR(500)
			,InclusionType VARCHAR(50)
			,IncludedPopulationDefinitionID INT
			)

		INSERT INTO @tblVersion
		SELECT DISTINCT cl1.PopulationDefinitionID
			,cdp.DefinitionVersion
			,CONVERT(VARCHAR(10), cdp.CreatedDate, 101) UsageStartDate
			,cdp.CreatedByUserId
			,cl2.PopulationDefinitionName PopulationDefinition
			,CASE 
				WHEN cdp.Type = 'C'
					THEN 'Copied'
				ELSE 'InCluded'
				END InclusionType
			,cl2.PopulationDefinitionID
		FROM CohortListDependenciesHistory cdp
		INNER JOIN PopulationDefinition cl1 ON cdp.IncludedCohortListId = cl1.PopulationDefinitionID
		INNER JOIN PopulationDefinition cl2 ON cdp.PopulationDefinitionID = cl2.PopulationDefinitionID
		WHERE cdp.IncludedCohortListId = @i_PopulationDefinitionID

		INSERT INTO @tblVersion
		SELECT cl1.PopulationDefinitionID
			,cl2.DefinitionVersion
			,CONVERT(VARCHAR(10), cdp.CreatedDate, 101) UsageStartDate
			,cdp.CreatedByUserId CreatedBy
			,cl2.PopulationDefinitionName PopulationDefinition
			,CASE 
				WHEN cdp.Type = 'C'
					THEN 'Copied'
				ELSE 'InCluded'
				END InclusionType
			,cl2.PopulationDefinitionID
		FROM CohortListDependencies cdp
		INNER JOIN PopulationDefinition cl1 ON cdp.IncludedCohortListId = cl1.PopulationDefinitionID
		INNER JOIN PopulationDefinition cl2 ON cdp.PopulationDefinitionID = cl2.PopulationDefinitionID
		WHERE cdp.IncludedCohortListId = @i_PopulationDefinitionID

		SELECT DefinitionVersion
			,IncludedPopulationDefinition PopulationDefinition
			,InclusionType
			,CONVERT(VARCHAR(10), ModifiedDate, 101) UsageStartDate
			,DBO.ufn_GetUserNameByID(ModifiedUserId) CreatedBy
			,IncludedPopulationDefinitionID
		FROM @tblVersion
	END TRY

	----------------------------------------------------------------------------------------------------------      
	BEGIN CATCH
		-- Handle exception  
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinition_Usage] TO [FE_rohit.r-ext]
    AS [dbo];

