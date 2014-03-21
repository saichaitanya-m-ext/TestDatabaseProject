
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_PopulationDefinitionCopyInclude_Select]1,1
Description   : This procedure is used to select the details from CohortList,CohortListCriteria tables for describing the cohort definition.  
Created By    : Rathnam
Created Date  : 06.08.2012  
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
08-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added  PopulationDefinitionId 
12-19-2013 prathyusha added lastmodified column to result set for audit log
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinitionCopyInclude_Select] -- 1,45
	(
	@i_AppUserId INT
	,@i_PopulationDefinitionID INT
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

		DECLARE @t_CohortListIdAndType TYPEIDANDNAME

		INSERT INTO @t_CohortListIdAndType
		SELECT IncludedCohortListId
			,CASE 
				WHEN Type = 'C'
					THEN 'Copy'
				ELSE 'Include'
				END
		FROM CohortListDependencies WITH (NOLOCK)
		WHERE PopulationDefinitionID = @i_PopulationDefinitionID
			AND IsDraft = 0

		INSERT INTO @t_CohortListIdAndType
		SELECT @i_PopulationDefinitionID
			,'Copy'

		----------- Select all the CohortList details ---------------  
		CREATE TABLE #t_Cohort (
			ID INT IDENTITY(1, 1)
			,PopulationDefinitionID INT
			,PopulationDefinitionName VARCHAR(500)
			,DefinitionCriteria VARCHAR(MAX)
			,DefinitionCriteriaSQL VARCHAR(MAX)
			,ParentID INT
			,NAME VARCHAR(10)
			,ShortText VARCHAR(MAX)
			,FullDefinition VARCHAR(MAX)
			)

		INSERT INTO #t_Cohort
		SELECT cl.PopulationDefinitionID
			,cl.PopulationDefinitionName
			,cl.PopulationDefinitionName DefinitionCriteria
			,'' DefinitionCriteriaSQL
			,NULL AS ParentID
			,t.NAME
			,cl.PopulationDefinitionName ShortText
			,cl.PopulationDefinitionName FullDefinition
		FROM PopulationDefinition cl WITH (NOLOCK)
		INNER JOIN @t_CohortListIdAndType t ON cl.PopulationDefinitionID = t.TypeId
		WHERE StatusCode = 'A'
			AND t.NAME = 'Copy'
		
		UNION ALL
		
		SELECT cl.PopulationDefinitionID
			,cl.PopulationDefinitionName
			,cl.PopulationDefinitionName DefinitionCriteria
			,clc.PopulationDefinitionCriteriaText DefinitionCriteriaSQL
			,NULL AS ParentID
			,t.NAME
			,cl.PopulationDefinitionName ShortText
			,cl.PopulationDefinitionName FullDefinition
		FROM PopulationDefinition cl WITH (NOLOCK)
		INNER JOIN @t_CohortListIdAndType t ON cl.PopulationDefinitionID = t.TypeId
		LEFT JOIN PopulationDefinitionCriteria clc WITH (NOLOCK) ON clc.PopulationDefinitionID = cl.PopulationDefinitionID
			AND clc.PopulationDefPanelConfigurationID = (
				SELECT PopulationDefPanelConfigurationID
				FROM PopulationDefPanelConfiguration
				WHERE PanelorGroupName = ('Compound')
				)
		WHERE StatusCode = 'A'
			AND t.NAME = 'Include'
		
		UNION ALL
		
		SELECT DISTINCT clc.PopulationDefinitionCriteriaID
			,cl.PopulationDefinitionName
			,clc.PopulationDefinitionCriteriaText
			,clc.PopulationDefinitionCriteriaSQL
			,cl.PopulationDefinitionID ParentID
			,''
			,LTRIM(SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(clc.PopulationDefinitionCriteriaText, '<font color=''black''><b><br/>', ''), '</b></font>', ''), '(', ''), ')', ''), '<br/>', ''), '&nbsp;', ''), '<font color=''maroon''><b><br/>', ''), 0, 30)) + '...' ShortText
			,LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CLC.PopulationDefinitionCriteriaText, '<font color=''black''><b><br/>', ''), '</b></font>', ''), '<br/>', ''), '<font color=''black''><b>', ''), '</b></font>', ''), '<b></font>', ''), '&nbsp;', ''), '<font color=''maroon''><b><br/>', '')) + '...' FullDefinition
			
		FROM PopulationDefinitionCriteria clc WITH (NOLOCK)
		INNER JOIN @t_CohortListIdAndType t ON clc.PopulationDefinitionID = t.TypeId
		INNER JOIN PopulationDefinition cl WITH (NOLOCK) ON cl.PopulationDefinitionID = clc.PopulationDefinitionID
		WHERE t.NAME = 'Copy'
			AND cl.StatusCode = 'A'
			AND clc.PopulationDefPanelConfigurationID NOT IN (
				SELECT PopulationDefPanelConfigurationID
				FROM PopulationDefPanelConfiguration
				WHERE PanelorGroupName IN (
						'Compound'
						,'Build Definition'
						)
				)

		IF EXISTS (
				SELECT 1
				FROM #t_Cohort
				WHERE ParentID = @i_PopulationDefinitionID
				)
		BEGIN
			SELECT DISTINCT PopulationDefinitionID
				,PopulationDefinitionName
				,DefinitionCriteria
				,DefinitionCriteriaSQL
				,CASE 
					WHEN ParentID = @i_PopulationDefinitionID
						THEN (
								SELECT TOP 1 ID
								FROM #t_Cohort
								WHERE PopulationDefinitionID = @i_PopulationDefinitionID
								)
					WHEN ParentID <> @i_PopulationDefinitionID
						THEN (
								SELECT ID
								FROM #t_Cohort
								WHERE PopulationDefinitionID = t.ParentID
								)
					END AS ParentID
				,NAME
				,ShortText
				,FullDefinition
				,ID
			FROM #t_Cohort t
			ORDER BY ParentID
		END
		ELSE
		BEGIN
			SELECT DISTINCT PopulationDefinitionID
				,PopulationDefinitionName
				,DefinitionCriteria
				,DefinitionCriteriaSQL
				,CASE 
					WHEN ParentID = @i_PopulationDefinitionID
						THEN (
								SELECT TOP 1 ID
								FROM #t_Cohort
								WHERE PopulationDefinitionID = @i_PopulationDefinitionID
								)
					WHEN ParentID <> @i_PopulationDefinitionID
						THEN (
								SELECT ID
								FROM #t_Cohort
								WHERE PopulationDefinitionID = t.ParentID
								)
					END AS ParentID
				,NAME
				,ShortText
				,FullDefinition
				,ID
			FROM #t_Cohort t
			WHERE PopulationDefinitionID <> @i_PopulationDefinitionID
			ORDER BY ParentID
		END

		DECLARE @v_PopulationDefinitionCriteriaSQL VARCHAR(MAX)
			,@v_CohortCriteriaSQLTemp VARCHAR(MAX)

		IF EXISTS (
				SELECT 1
				FROM PopulationDefinition
				WHERE PopulationDefinitionID = @i_PopulationDefinitionID
					AND ProductionStatus = 'F'
				)
		BEGIN
			SELECT TOP 1 @v_PopulationDefinitionCriteriaSQL = PopulationDefinitionCriteriaSQL
			FROM PopulationDefinitionCriteria WITH (NOLOCK)
			INNER JOIN PopulationDefPanelConfiguration WITH (NOLOCK) ON PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID = PopulationDefinitionCriteria.PopulationDefPanelConfigurationID
			WHERE PopulationDefinitionCriteria.PopulationDefinitionID = @i_PopulationDefinitionID
				AND PanelorGroupName = 'Build Definition'
		END
		ELSE
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM PopulationDefinition WITH (NOLOCK)
					WHERE PopulationDefinitionID = @i_PopulationDefinitionID
						AND ProductionStatus = 'D'
					)
			BEGIN
				SELECT TOP 1 @v_PopulationDefinitionCriteriaSQL = PopulationDefinitionCriteriaSQL
				FROM CohortListCriteriaHistory WITH (NOLOCK)
				INNER JOIN PopulationDefPanelConfiguration WITH (NOLOCK) ON PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID = CohortListCriteriaHistory.PopulationDefPanelConfigurationID
				WHERE CohortListCriteriaHistory.PopulationDefinitionID = @i_PopulationDefinitionID
					AND PanelorGroupName = 'Build Definition'
				ORDER BY DefinitionVersion DESC
			END

			IF ISNULL(@v_PopulationDefinitionCriteriaSQL, '') = ''
			BEGIN
				SELECT TOP 1 @v_PopulationDefinitionCriteriaSQL = PopulationDefinitionCriteriaSQL
				FROM PopulationDefinitionCriteria WITH (NOLOCK)
				INNER JOIN PopulationDefPanelConfiguration WITH (NOLOCK) ON PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID = PopulationDefinitionCriteria.PopulationDefPanelConfigurationID
				INNER JOIN PopulationDefinition WITH (NOLOCK) ON PopulationDefinition.PopulationDefinitionID = PopulationDefinitionCriteria.PopulationDefinitionID
				WHERE PopulationDefinitionCriteria.PopulationDefinitionID = @i_PopulationDefinitionID
					AND PanelorGroupName = 'Build Definition'
					AND ProductionStatus = 'D'
			END
		END

		WHILE CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1) > 0
		BEGIN
			IF ISNUMERIC(RTRIM(LTRIM(REPLACE(SUBSTRING(@v_PopulationDefinitionCriteriaSQL, CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1), CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, (CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL) + 1)) - CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1) + 1), '$', '')))) = 1
			BEGIN
				SELECT @v_CohortCriteriaSQLTemp = PopulationDefinitionCriteriaSQL
				FROM PopulationDefinitionCriteria WITH (NOLOCK)
				INNER JOIN PopulationDefPanelConfiguration WITH (NOLOCK) ON PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID = PopulationDefinitionCriteria.PopulationDefPanelConfigurationID
				WHERE PopulationDefinitionID = RTRIM(LTRIM(REPLACE(SUBSTRING(@v_PopulationDefinitionCriteriaSQL, CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1), CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, (CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL) + 1)) - CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1) + 1), '$', '')))
					AND PanelorGroupName = 'Build Definition'

				SET @v_PopulationDefinitionCriteriaSQL = REPLACE(@v_PopulationDefinitionCriteriaSQL, SUBSTRING(@v_PopulationDefinitionCriteriaSQL, CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1), CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, (charindex('$', @v_PopulationDefinitionCriteriaSQL) + 1)) - CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1) + 1), (
							CASE 
								WHEN ISNULL(@v_CohortCriteriaSQLTemp, '') = ''
									THEN '1=1'
								ELSE @v_CohortCriteriaSQLTemp
								END
							))
				SET @v_CohortCriteriaSQLTemp = ''
			END
		END

		SELECT PopulationDefinitionCriteriaID
			,PopulationDefinitionID
			,XMLDefenition
			,ISNULL(@v_PopulationDefinitionCriteriaSQL, PopulationDefinitionCriteriaSQL) CohortCriteriaSQL
			,PopulationDefinitionCriteriaText
			,LastModifiedDate
		FROM PopulationDefinitionCriteria WITH (NOLOCK)
		WHERE PopulationDefPanelConfigurationID = (
				SELECT PopulationDefPanelConfigurationID
				FROM PopulationDefPanelConfiguration
				WHERE PanelorGroupName = 'Build Definition'
					AND PopulationType = 'Population'
				)
			AND PopulationDefinitionID = @i_PopulationDefinitionID
	END TRY

	BEGIN CATCH
		-- Handle exception  
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinitionCopyInclude_Select] TO [FE_rohit.r-ext]
    AS [dbo];

