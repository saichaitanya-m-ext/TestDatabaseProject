
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_TaskBundle_Usage]231,25
Description   : This proc is used to fetch the usage information of a TaskBundle
Created By    : Rathnam
Created Date  : 13-Sep-2012
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_TaskBundle_Usage] (
	@i_AppUserId KEYID
	,@i_TaskbundleId KEYID
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

		DECLARE @tblVersion TABLE (
			TaskBundleID INT
			,DefinitionVersion VARCHAR(5)
			,ModifiedDate DATETIME
			,ModifiedUserId INT
			,ModificationDescription VARCHAR(500)
			)
		DECLARE @v_DefinitionVersion VARCHAR(5)
			,@v_DiseaseIdList VARCHAR(500)
			,@i_CreatedByUserId INT
			,@d_CreatedDate DATETIME
			,@v_ParentTaskBundleList VARCHAR(2000)

		DECLARE curVersion CURSOR
		FOR
		SELECT TaskBundleId
			,DefinitionVersion
			,CreatedByUserId
			,CreatedDate
			,ParentTaskBundleList
		FROM TaskBundleHistory
		WHERE TaskBundleID = @i_TaskBundleID

		OPEN curVersion

		FETCH NEXT
		FROM curVersion
		INTO @i_TaskBundleID
			,@v_DefinitionVersion
			,@i_CreatedByUserId
			,@d_CreatedDate
			,@v_ParentTaskBundleList

		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO @tblVersion
			SELECT DISTINCT RTRIM(LTRIM(SUBSTRING(KeyValue, 1, CHARINDEX('-', KeyValue) - 1)))
				,@v_DefinitionVersion
				,@d_CreatedDate
				,@i_CreatedByUserId
				,(
					SELECT TaskBundleName
					FROM TaskBundle
					WHERE TaskBundleId = RTRIM(LTRIM(SUBSTRING(KeyValue, 1, CHARINDEX('-', KeyValue) - 1)))
					) + CASE 
					WHEN RTRIM(LTRIM(SUBSTRING(KeyValue, CHARINDEX('-', KeyValue) + 1, LEN(KeyValue)))) = 'I'
						THEN '- Included'
					ELSE '- Copied'
					END
			FROM dbo.udf_SplitStringToTable(@v_ParentTaskBundleList, '$$')
			WHERE ISNULL(KeyValue, '') <> ''

			FETCH NEXT
			FROM curVersion
			INTO @i_TaskBundleID
				,@v_DefinitionVersion
				,@i_CreatedByUserId
				,@d_CreatedDate
				,@v_ParentTaskBundleList
		END

		CLOSE curVersion

		DEALLOCATE curVersion

		--SELECT '0.1' AS VersionNumber
		--	,'Programs' ProgramType
		--	,'Under Construction' ProgramName
		--	,GETDATE() UsageStartDate
		--	,'Admin1' CreatedBy
		--	,GETDATE() UsageEndDate;
		
		SELECT DISTINCT TaskBundle.DefinitionVersion VersionNumber,
		 'Programs' ProgramType,
		  Program.ProgramName,
		  ProgramTaskBundle.CreatedDate UsageStartDate,
          DBO.ufn_GetUserNameByID(Program.CreatedByUserId) CreatedBy FROM ProgramTaskBundle 
		INNER JOIN TaskBundle 
		 ON TaskBundle.TaskBundleId = ProgramTaskBundle.TaskBundleID
		INNER JOIN Program
		 ON ProgramTaskBundle.ProgramID = Program.ProgramId 
		WHERE TaskBundle.TaskBundleId = @i_TaskBundleID
		
		
		
      

		;WITH cteTask
		AS (
			SELECT DISTINCT t1.TaskBundleID
				,t1.ModificationDescription TaskBundleName
				,t1.DefinitionVersion VersionNumber
				,CONVERT(VARCHAR(10), ModifiedDate, 101) ModifiedDate
				,DBO.ufn_GetUserNameByID(ModifiedUserId) ModifiedBy
			FROM @tblVersion t1
			
			UNION
			
			SELECT t.TaskBundleID
				,tb.TaskBundleName + '-' + CASE 
					WHEN RTRIM(LTRIM(SUBSTRING(t.CopyInclude, CHARINDEX('-', t.CopyInclude) + 1, LEN(t.CopyInclude)))) = 'I'
						THEN '- Included'
					ELSE '- Copied'
					END
				,tb.DefinitionVersion VersionNumber
				,CONVERT(VARCHAR(10), t.CreatedDate, 101) ModifiedDate
				,DBO.ufn_GetUserNameByID(t.CreatedByUserId) ModifiedBy
			FROM TaskBundleCopyInclude t
			INNER JOIN TaskBundle tb ON tb.TaskBundleId = t.TaskBundleID
			WHERE ParentTaskBundleId = @i_TaskbundleId
				AND t.ParentTaskBundleId <> t.TaskBundleID
			)
		SELECT *
		FROM cteTask
		ORDER BY 3
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
    ON OBJECT::[dbo].[usp_TaskBundle_Usage] TO [FE_rohit.r-ext]
    AS [dbo];

