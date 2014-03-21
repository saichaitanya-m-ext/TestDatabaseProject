
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_NumeratorDefinition_Search] 23,1
Description   : This procedure is used to select the details from population definition table regarding the numerator information.  
Created By    : Rathnam  
Created Date  : 10-Dec-2012
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_NumeratorDefinition_Search] (
	@i_AppUserId KEYID
	,@i_NumeratorDefinitionID KEYID = NULL
	,@v_StatusCode STATUSCODE = 'A'
	,@vc_NumeratorDefinitionName SHORTDESCRIPTION = NULL
	,@vc_NumeratorDefinitionDescription SHORTDESCRIPTION = NULL
	,@v_ProductionStatus VARCHAR(1) = NULL
	,@b_DisplayStatus BIT = NULL
	,@v_NumeratoryType VARCHAR(1) = NULL
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
		SELECT NumeratorDefinition.PopulationDefinitionID
			,NumeratorDefinition.PopulationDefinitionName
			,NumeratorDefinition.PopulationDefinitionDescription
			,CASE 
				WHEN NumeratorDefinition.NumeratorType = 'C'
					THEN 'Count'
				WHEN NumeratorDefinition.NumeratorType = 'V'
					THEN 'Value'
				END NumeratorType
			,DefinitionVersion
			,CASE 
				WHEN NumeratorDefinition.ProductionStatus IN (
						'D'
						,'U'
						)
					THEN 'Draft'
				ELSE 'Final'
				END AS ProductionStatus
			,CASE 
				WHEN NumeratorDefinition.Private = 0
					THEN 'No'
				ELSE 'Yes'
				END AS Private
			,CASE NumeratorDefinition.StatusCode
				WHEN 'A'
					THEN 'Active'
				WHEN 'I'
					THEN 'InActive'
				ELSE ''
				END StatusCode
			,dbo.ufn_GetUserNameByID(NumeratorDefinition.CreatedByUserId) AS CreatedBy
			,CONVERT(VARCHAR(10), NumeratorDefinition.CreatedDate, 101) AS CreatedDate
			,dbo.ufn_GetUserNameByID(NumeratorDefinition.LastModifiedByUserId) AS ModifiedBy
			,CONVERT(VARCHAR(10), NumeratorDefinition.LastModifiedDate, 101) AS LastModifiedDate
		FROM PopulationDefinition NumeratorDefinition WITH (NOLOCK)
		WHERE NumeratorDefinition.DefinitionType = 'N'
			AND (
				NumeratorDefinition.PopulationDefinitionName LIKE '%' + @vc_NumeratorDefinitionName + '%'
				OR @vc_NumeratorDefinitionName IS NULL
				)
			AND (
				NumeratorDefinition.PopulationDefinitionDescription LIKE '%' + @vc_NumeratorDefinitionDescription + '%'
				OR @vc_NumeratorDefinitionDescription IS NULL
				)
			AND (
				NumeratorDefinition.NumeratorType = @v_NumeratoryType
				OR @v_NumeratoryType IS NULL
				)
			AND (
				NumeratorDefinition.StatusCode = @v_StatusCode
				OR @v_StatusCode IS NULL
				)
			AND (
				NumeratorDefinition.ProductionStatus = @v_ProductionStatus
				OR @v_ProductionStatus IS NULL
				)
			AND (
				NumeratorDefinition.Private = @b_DisplayStatus
				OR @b_DisplayStatus IS NULL
				)
			AND (
				NumeratorDefinition.PopulationDefinitionID = @i_NumeratorDefinitionID
				OR @i_NumeratorDefinitionID IS NULL
				)
		ORDER BY NumeratorDefinition.PopulationDefinitionName

		DECLARE @tblVersion TABLE (
			PopulationDefinitionID INT
			,DefinitionVersion VARCHAR(5)
			,ModifiedDate DATETIME
			,ModifiedUserId INT
			,ModificationDescription VARCHAR(500)
			)
		DECLARE @v_DefinitionVersion VARCHAR(5)
			,@v_CohortModificationList VARCHAR(500)
			,@v_CohortCriteriaModificationList VARCHAR(500)
			,@v_CohortDependencyModificationList VARCHAR(500)
			,@i_CreatedByUserId INT
			,@d_CreatedDate DATETIME

		DECLARE curVersion CURSOR
		FOR
		SELECT @i_NumeratorDefinitionID
			,DefinitionVersion
			,CohortModificationList
			,CohortCriteriaModificationList
			,CohortDependencyModificationList
			,CreatedByUserId
			,CreatedDate
		FROM CohortListHistory
		WHERE PopulationDefinitionID = @i_NumeratorDefinitionID

		OPEN curVersion

		FETCH NEXT
		FROM curVersion
		INTO @i_NumeratorDefinitionID
			,@v_DefinitionVersion
			,@v_CohortModificationList
			,@v_CohortCriteriaModificationList
			,@v_CohortDependencyModificationList
			,@i_CreatedByUserId
			,@d_CreatedDate

		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO @tblVersion
			SELECT DISTINCT @i_NumeratorDefinitionID
				,@v_DefinitionVersion
				,@d_CreatedDate
				,@i_CreatedByUserId
				,KeyValue
			FROM dbo.udf_SplitStringToTable(@v_CohortModificationList, '$$')
			WHERE ISNULL(KeyValue, '') <> ''
			
			UNION ALL
			
			SELECT DISTINCT @i_NumeratorDefinitionID
				,@v_DefinitionVersion
				,@d_CreatedDate
				,@i_CreatedByUserId
				,
				(
					(
						SELECT PanelorGroupName
						FROM PopulationDefPanelConfiguration
						WHERE PopulationDefPanelConfigurationID = SUBSTRING(KeyValue, charindex('-', KeyValue, 1) + 1, CHARINDEX('*', KeyValue, 1) - charindex('-', KeyValue, 1) - 1)
						) + '-' + CASE 
						WHEN SUBSTRING(KeyValue, CHARINDEX('*', KeyValue, 1) + 1, 1) = 'I'
							THEN 'Inserted'
						ELSE 'Deleted'
						END + '-' + (
						SELECT TOP 1 LTRIM(SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PopulationDefinitionCriteriaText, '<font color=''black''><b><br/>', ''), '</b></font>', ''), '(', ''), ')', ''), '<br/>', ''), '&nbsp;', ''), '<font color=''maroon''><b><br/>', ''), 0, 4000))
						FROM PopulationDefinitionCriteria
						WHERE PopulationDefinitionCriteriaID = SUBSTRING(KeyValue, 1, CHARINDEX('-', KeyValue, 1) - 1)
						)
					)
			FROM dbo.udf_SplitStringToTable(@v_CohortCriteriaModificationList, '$$')
			WHERE ISNULL(KeyValue, '') <> ''
			
			UNION ALL
			
			SELECT DISTINCT @i_NumeratorDefinitionID
				,@v_DefinitionVersion
				,@d_CreatedDate
				,@i_CreatedByUserId
				,(
					(
						SELECT PopulationDefinitionName
						FROM PopulationDefinition
						WHERE PopulationDefinitionID = SUBSTRING(KeyValue, 1, charindex('-', KeyValue, 1) - 1)
						) + '-' + CASE 
						WHEN SUBSTRING(KeyValue, CHARINDEX('-', KeyValue, 1) + 1, 1) = 'I'
							THEN 'InCluded'
						ELSE 'Copied'
						END + '-' + CASE 
						WHEN SUBSTRING(KeyValue, CHARINDEX('*', KeyValue, 1) + 1, 1) = 'I'
							THEN 'Inserted'
						ELSE 'Deleted'
						END
					)
			FROM dbo.udf_SplitStringToTable(@v_CohortDependencyModificationList, '$$')
			WHERE ISNULL(KeyValue, '') <> ''

			FETCH NEXT
			FROM curVersion
			INTO @i_NumeratorDefinitionID
				,@v_DefinitionVersion
				,@v_CohortModificationList
				,@v_CohortCriteriaModificationList
				,@v_CohortDependencyModificationList
				,@i_CreatedByUserId
				,@d_CreatedDate
		END

		CLOSE curVersion

		DEALLOCATE curVersion

		SELECT DISTINCT @i_NumeratorDefinitionID NumeratorDefinitionID
			,dbo.ufn_GetVersionNumber(DefinitionVersion) DefinitionVersion
			,CONVERT(VARCHAR(10), ModifiedDate, 101) ModifiedDate
			,DBO.ufn_GetUserNameByID(ModifiedUserId) ModifiedBy
			,STUFF((
					SELECT ' , ' + ModificationDescription
					FROM @tblVersion t
					WHERE t.DefinitionVersion = t1.DefinitionVersion
					FOR XML PATH('')
					), 1, 2, '') AS ModificationDescription
		FROM @tblVersion t1
	END TRY

	---------------------------------------------------------------------------------------------------------------------------------
	BEGIN CATCH
		-- Handle exception  
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_NumeratorDefinition_Search] TO [FE_rohit.r-ext]
    AS [dbo];

