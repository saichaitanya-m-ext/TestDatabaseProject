
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_TaskBundle_History]1,103
Description   : This proc is used to fetch the history information of a TaskBundle
Created By    : Rathnam
Created Date  : 13-Sep-2012
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_TaskBundle_History] (
	@i_AppUserId KEYID
	,@i_TaskbundleId KEYID
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

	CREATE TABLE #tblVersion (
		TaskBundleID INT
		,DefinitionVersion VARCHAR(5)
		,ModifiedDate DATETIME
		,ModifiedUserId INT
		,ModificationDescription VARCHAR(500)
		,IsCopy BIT
		)

	DECLARE @v_DefinitionVersion VARCHAR(5)
		,@v_DiseaseIdList VARCHAR(500)
		,@v_BundleHistoryList VARCHAR(2000)
		,@v_AdhocFrequencyList VARCHAR(2000)
		,@v_PEMList VARCHAR(2000)
		,@v_QuestionnaireList VARCHAR(2000)
		,@v_CPTList VARCHAR(2000)
		,@i_CreatedByUserId INT
		,@d_CreatedDate DATETIME
		,@v_ModifiedDiseaseList VARCHAR(2000)
		,@v_CopyIncludeList VARCHAR(2000)

	DECLARE curVersion CURSOR
	FOR
	SELECT TaskBundleId
		,DefinitionVersion
		,BundlehistoryList
		,AdhocFrequencyList
		,PEMList
		,QuestionnaireList
		,CPTList
		,CreatedByUserId
		,CreatedDate
		,CopyIncludeList
	FROM TaskBundleHistory
	WHERE TaskBundleID = @i_TaskBundleID

	OPEN curVersion

	FETCH NEXT
	FROM curVersion
	INTO @i_TaskBundleID
		,@v_DefinitionVersion
		,@v_BundleHistoryList
		,@v_AdhocFrequencyList
		,@v_PEMList
		,@v_QuestionnaireList
		,@v_CPTList
		,@i_CreatedByUserId
		,@d_CreatedDate
		,@v_CopyIncludeList

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #tblVersion
		SELECT DISTINCT @i_TaskBundleID
			,@v_DefinitionVersion
			,@d_CreatedDate
			,@i_CreatedByUserId
			,'TaskBundle - ' + KeyValue
			,0
		FROM dbo.udf_SplitStringToTable(@v_BundleHistoryList, '$$')
		WHERE ISNULL(KeyValue, '') <> ''
		
		UNION ALL
		
		SELECT DISTINCT @i_TaskBundleID
			,@v_DefinitionVersion
			,@d_CreatedDate
			,@i_CreatedByUserId
			,CASE 
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Name'
					THEN 'Other Task - ' + (
							SELECT NAME
							FROM AdhocTask
							WHERE AdhocTaskID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Name Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Frequency'
					THEN 'Other Task - ' + (
							SELECT NAME
							FROM AdhocTask
							WHERE AdhocTaskID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Frequency Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'UOM'
					THEN 'Other Task - ' + (
							SELECT NAME
							FROM AdhocTask
							WHERE AdhocTaskID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- UOM Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Status'
					THEN 'Other Task - ' + (
							SELECT NAME
							FROM AdhocTask
							WHERE AdhocTaskID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Status Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Comments'
					THEN 'Other Task - ' + (
							SELECT NAME
							FROM AdhocTask
							WHERE AdhocTaskID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Comments Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Added'
					THEN 'Other Task - ' + (
							SELECT NAME
							FROM AdhocTask
							WHERE AdhocTaskID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Added'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Deleted'
					THEN 'Other Task - ' + (
							SELECT NAME
							FROM AdhocTask
							WHERE AdhocTaskID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Deleted'
				END
			,0
		FROM dbo.udf_SplitStringToTable(@v_AdhocFrequencyList, '$$')
		WHERE ISNULL(KeyValue, '') <> ''
		
		UNION ALL
		
		SELECT DISTINCT @i_TaskBundleID
			,@v_DefinitionVersion
			,@d_CreatedDate
			,@i_CreatedByUserId
			,CASE 
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Name'
					THEN 'Questionnaire - ' + (
							SELECT QuestionaireName
							FROM Questionaire
							WHERE QuestionaireId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Tagged to another Questionnaire'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Frequency'
					THEN 'Questionnaire - ' + (
							SELECT QuestionaireName
							FROM Questionaire
							WHERE QuestionaireId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Frequency Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'UOM'
					THEN 'Questionnaire - ' + (
							SELECT QuestionaireName
							FROM Questionaire
							WHERE QuestionaireId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- UOM Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Status'
					THEN 'Questionnaire - ' + (
							SELECT QuestionaireName
							FROM Questionaire
							WHERE QuestionaireId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Status Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Disease'
					THEN 'Questionnaire - ' + (
							SELECT QuestionaireName
							FROM Questionaire
							WHERE QuestionaireId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Tagged to another Disease'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Preventive'
					THEN 'Questionnaire - ' + (
							SELECT QuestionaireName
							FROM Questionaire
							WHERE QuestionaireId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Preventive Option Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Added'
					THEN 'Questionnaire - ' + (
							SELECT QuestionaireName
							FROM Questionaire
							WHERE QuestionaireId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Added'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Deleted'
					THEN 'Questionnaire - ' + (
							SELECT QuestionaireName
							FROM Questionaire
							WHERE QuestionaireId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Deleted'
				END
			,0
		FROM dbo.udf_SplitStringToTable(@v_QuestionnaireList, '$$')
		WHERE ISNULL(KeyValue, '') <> ''
		
		UNION ALL
		
		SELECT DISTINCT @i_TaskBundleID
			,@v_DefinitionVersion
			,@d_CreatedDate
			,@i_CreatedByUserId
			,CASE 
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Name'
					THEN 'PEM - ' + (
							SELECT NAME
							FROM EducationMaterial
							WHERE EducationMaterialID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Name Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Status'
					THEN 'PEM - ' + (
							SELECT NAME
							FROM EducationMaterial
							WHERE EducationMaterialID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Status Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Comments'
					THEN 'PEM - ' + (
							SELECT NAME
							FROM EducationMaterial
							WHERE EducationMaterialID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Comments Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Added'
					THEN 'PEM - ' + (
							SELECT NAME
							FROM EducationMaterial
							WHERE EducationMaterialID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Added'
				WHEN KeyValue LIKE '%*I%'
					THEN 'PEM - ' + (
							SELECT NAME
							FROM Library
							WHERE LibraryId = RTRIM(LTRIM(SUBSTRING(KeyValue, 1, CHARINDEX('-', KeyValue) - 1)))
							) + '-' + (
							SELECT NAME
							FROM EducationMaterial
							WHERE EducationMaterialID = REPLACE(REPLACE(RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, CHARINDEX('*', KeyValue) - CHARINDEX('-', KeyValue)))), '-', ''), '*', '')
							) + '- Document Uploaded'
				WHEN KeyValue LIKE '%*D%'
					THEN 'PEM - ' + (
							SELECT NAME
							FROM Library
							WHERE LibraryId = RTRIM(LTRIM(SUBSTRING(KeyValue, 1, CHARINDEX('-', KeyValue) - 1)))
							) + '-' + (
							SELECT NAME
							FROM EducationMaterial
							WHERE EducationMaterialID = REPLACE(REPLACE(RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, CHARINDEX('*', KeyValue) - CHARINDEX('-', KeyValue)))), '-', ''), '*', '')
							) + '- Document Removed'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Deleted'
					THEN 'PEM - ' + (
							SELECT NAME
							FROM EducationMaterial
							WHERE EducationMaterialID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Deleted'
				END
			,0
		FROM dbo.udf_SplitStringToTable(@v_PEMList, '$$')
		WHERE ISNULL(KeyValue, '') <> ''
		
		UNION ALL
		
		SELECT DISTINCT @i_TaskBundleID
			,@v_DefinitionVersion
			,@d_CreatedDate
			,@i_CreatedByUserId
			,CASE 
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Name'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							WHERE CodeGroupingId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Tagged to another Procedure'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Frequency'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							WHERE CodeGroupingId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Frequency Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'UOM'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							WHERE CodeGroupingId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- UOM Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Status'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							WHERE CodeGroupingId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Status Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Never Schedule'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							WHERE CodeGroupingId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Never Schedule Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Disease'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							WHERE CodeGroupingId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Tagged to another Disease'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Exclusion Reason'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							WHERE CodeGroupingId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Exclusion Reason Option Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Preventive'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							WHERE CodeGroupingId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Preventive Option Updated'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Added'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							WHERE CodeGroupingId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Added'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue), LEN(KeyValue)))) = '-I'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							INNER JOIN TaskBundleProcedureFrequency ON TaskBundleProcedureFrequency.CodeGroupingId = CodeGrouping.CodeGroupingId
							WHERE TaskBundleProcedureFrequency.TaskBundleProcedureFrequencyId = RTRIM(LTRIM(SUBSTRING(KeyValue, 1, CHARINDEX('*', KeyValue) - 1)))
							) + ' - ' + (
							SELECT NAME
							FROM Measure
							WHERE MeasureID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Measure and Age Added'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue), LEN(KeyValue)))) = '- Added AgeOnly'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							INNER JOIN TaskBundleProcedureFrequency ON TaskBundleProcedureFrequency.CodeGroupingId = CodeGrouping.CodeGroupingId
							WHERE TaskBundleProcedureFrequency.TaskBundleProcedureFrequencyId = RTRIM(LTRIM(SUBSTRING(KeyValue, 1, CHARINDEX('*', KeyValue) - 1)))
							) + ' - ' + (
							SELECT NAME
							FROM Measure
							WHERE MeasureID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Age Only Added'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue), LEN(KeyValue)))) = '-D'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							INNER JOIN TaskBundleProcedureFrequency ON TaskBundleProcedureFrequency.CodeGroupingId = CodeGrouping.CodeGroupingId
							WHERE TaskBundleProcedureFrequency.TaskBundleProcedureFrequencyId = RTRIM(LTRIM(SUBSTRING(KeyValue, 1, CHARINDEX('*', KeyValue) - 1)))
							) + ' - ' + (
							SELECT NAME
							FROM Measure
							WHERE MeasureID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Measure and Age Removed'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue), LEN(KeyValue)))) = '- Removed AgeOnly'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							INNER JOIN TaskBundleProcedureFrequency ON TaskBundleProcedureFrequency.CodeGroupingId = CodeGrouping.CodeGroupingId
							WHERE TaskBundleProcedureFrequency.TaskBundleProcedureFrequencyId = RTRIM(LTRIM(SUBSTRING(KeyValue, 1, CHARINDEX('*', KeyValue) - 1)))
							) + ' - ' + (
							SELECT NAME
							FROM Measure
							WHERE MeasureID = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Age Only Removed'
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'Deleted'
					THEN 'Procedure - ' + (
							SELECT CodeGroupingName
							FROM CodeGrouping
							WHERE CodeGroupingId = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(KeyValue, CHARINDEX('*', KeyValue) + 1, CHARINDEX('-', KeyValue) - CHARINDEX('*', KeyValue)), '*', ''), '-', '')))
							) + '- Deleted'
				END
			,0
		FROM dbo.udf_SplitStringToTable(@v_CPTList, '$$')
		WHERE ISNULL(KeyValue, '') <> ''
		
		UNION ALL
		
		SELECT DISTINCT @i_TaskBundleID
			,@v_DefinitionVersion
			,@d_CreatedDate
			,@i_CreatedByUserId
			,'TaskBundle - ' + (
				SELECT TaskBundleName
				FROM TaskBundle
				WHERE TaskBundleId = RTRIM(LTRIM(SUBSTRING(KeyValue, 1, CHARINDEX('-', KeyValue) - 1)))
				) + CASE 
				WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'I'
					THEN '- InCluded'
				ELSE '- Copied'
				END
			,1
		FROM dbo.udf_SplitStringToTable(@v_CopyIncludeList, '$$')
		WHERE ISNULL(KeyValue, '') <> ''

		FETCH NEXT
		FROM curVersion
		INTO @i_TaskBundleID
			,@v_DefinitionVersion
			,@v_BundleHistoryList
			,@v_AdhocFrequencyList
			,@v_PEMList
			,@v_QuestionnaireList
			,@v_CPTList
			,@i_CreatedByUserId
			,@d_CreatedDate
			,@v_CopyIncludeList
	END

	CLOSE curVersion

	DEALLOCATE curVersion

	SELECT TaskBundleID
		,ModificationDescription
		,DefinitionVersion
		,ModifiedDate
		,ModifiedUserID
		,row_number() OVER (
			PARTITION BY ModificationDescription ORDER BY DefinitionVersion
			) sno
	INTO #temp
	FROM #tblVersion
	WHERE Iscopy = 1

	DELETE
	FROM #tblVersion
	WHERE IsCopy = 1
		AND EXISTS (
			SELECT 1
			FROM #temp t
			WHERE 
				t.DefinitionVersion = #tblVersion.DefinitionVersion
				AND t.ModificationDescription = #tblVersion.ModificationDescription
				AND t.sno > 1
			)

	SELECT DISTINCT TaskBundleID
		,dbo.ufn_GetVersionNumber(DefinitionVersion) DefinitionVersion
		,CONVERT(VARCHAR(10), ModifiedDate, 101) ModifiedDate
		,DBO.ufn_GetUserNameByID(ModifiedUserId) ModifiedBy
		,STUFF((
				SELECT ' , ' + ModificationDescription
				FROM #tblVersion t
				WHERE t.DefinitionVersion = t1.DefinitionVersion
				FOR XML PATH('')
				), 1, 2, '') AS ModificationDescription
	FROM #tblVersion t1
END TRY

-----------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskBundle_History] TO [FE_rohit.r-ext]
    AS [dbo];

