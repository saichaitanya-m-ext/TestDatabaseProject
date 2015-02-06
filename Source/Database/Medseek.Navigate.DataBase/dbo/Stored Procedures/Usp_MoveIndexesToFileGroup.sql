--Exec [Usp_MoveIndexesToFileGroup] 'CCMV2DEV','dbo',NULL,NULL,'FG_Codesets_NCX','C'
CREATE  PROC [dbo].[Usp_MoveIndexesToFileGroup] (
	@DBName SYSNAME
	,@SchemaName SYSNAME = 'dbo'
	,@ObjectNameList VARCHAR(Max)
	,@IndexName SYSNAME = NULL
	,@FileGroupName VARCHAR(100)
	,@Flag CHAR(1) = 'C' ---(C-Codeset,T-Transactional,L-Library)
	)
	WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @IndexSQL NVARCHAR(Max)
	DECLARE @IndexKeySQL NVARCHAR(Max)
	DECLARE @IncludeColSQL NVARCHAR(Max)
	DECLARE @FinalSQL NVARCHAR(Max)
	DECLARE @CurLoopCount INT
	DECLARE @MaxLoopCount INT
	DECLARE @StartPos INT
	DECLARE @EndPos INT
	DECLARE @ObjectName SYSNAME
	DECLARE @IndName SYSNAME
	DECLARE @IsUnique VARCHAR(10)
	DECLARE @Type VARCHAR(25)
	DECLARE @IsPadded VARCHAR(5)
	DECLARE @IgnoreDupKey VARCHAR(5)
	DECLARE @AllowRowLocks VARCHAR(5)
	DECLARE @AllowPageLocks VARCHAR(5)
	DECLARE @FillFactor INT
	DECLARE @ExistingFGName VARCHAR(Max)
	DECLARE @FilterDef NVARCHAR(Max)
	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @SQL NVARCHAR(4000)
	DECLARE @RetVal BIT
	DECLARE @ObjectList TABLE (
		Id INT Identity(1, 1)
		,ObjectName SYSNAME
		)
	DECLARE @WholeIndexData TABLE (
		ObjectName SYSNAME
		,IndexName SYSNAME
		,Is_Unique BIT
		,Type_Desc VARCHAR(25)
		,Is_Padded BIT
		,Ignore_Dup_Key BIT
		,Allow_Row_Locks BIT
		,Allow_Page_Locks BIT
		,Fill_Factor INT
		,Is_Descending_Key BIT
		,ColumnName SYSNAME
		,Is_Included_Column BIT
		,FileGroupName VARCHAR(Max)
		,Has_Filter BIT
		,Filter_Definition NVARCHAR(Max)
		)
	DECLARE @DistinctIndexData TABLE (
		Id INT IDENTITY(1, 1)
		,ObjectName SYSNAME
		,IndexName SYSNAME
		,Is_Unique BIT
		,Type_Desc VARCHAR(25)
		,Is_Padded BIT
		,Ignore_Dup_Key BIT
		,Allow_Row_Locks BIT
		,Allow_Page_Locks BIT
		,Fill_Factor INT
		,FileGroupName VARCHAR(Max)
		,Has_Filter BIT
		,Filter_Definition NVARCHAR(Max)
		)

	-------------Validate arguments----------------------
	IF (@DBName IS NULL)
	BEGIN
		SELECT @ErrorMessage = 'Database Name must be supplied.'

		GOTO ABEND
	END

	IF (@FileGroupName IS NULL)
	BEGIN
		SELECT @ErrorMessage = 'FileGroup Name must be supplied.'

		GOTO ABEND
	END

	--Check for the existence of the Database
	IF NOT EXISTS (
			SELECT NAME
			FROM sys.databases
			WHERE NAME = @DBName
			)
	BEGIN
		SET @ErrorMessage = 'The specified Database does not exist'

		GOTO ABEND
	END

	--Check for the existence of the Schema
	IF (upper(@SchemaName) <> 'DBO')
	BEGIN
		SET @SQL = 'SELECT @RetVal = COUNT(*) FROM ' + QUOTENAME(@DBName) + '.sys.schemas WHERE name = ''' + @SchemaName + ''''

		BEGIN TRY
			EXEC sp_executesql @SQL
				,N'@RetVal Bit OUTPUT'
				,@RetVal OUTPUT
		END TRY

		BEGIN CATCH
			SELECT @ErrorMessage = ERROR_MESSAGE()

			GOTO ABEND
		END CATCH

		IF (@RetVal = 0)
		BEGIN
			SELECT @ErrorMessage = 'No Schema with the name ' + @SchemaName + ' exists in the Database ' + @DBName

			GOTO ABEND
		END
	END

	--Check for the existence of the FileGroup
	SET @SQL = 'SELECT @RetVal=COUNT(*) FROM ' + QUOTENAME(@DBName) + '.sys.filegroups WHERE name = ''' + @FileGroupName + ''''

	BEGIN TRY
		EXEC sp_executesql @SQL
			,N'@RetVal Bit OUTPUT'
			,@RetVal OUTPUT
	END TRY

	BEGIN CATCH
		SELECT @ErrorMessage = ERROR_MESSAGE()

		GOTO ABEND
	END CATCH

	IF (@RetVal = 0)
	BEGIN
		SELECT @ErrorMessage = 'No FileGroup with the name ' + @FileGroupName + ' exists in the Database ' + @DBName

		GOTO ABEND
	END

	---Get the Non clustered index Objects based on the Flag (C-Codeset,T-Transactional,L-Library)
	CREATE TABLE #Indexes (
		ID INT IDENTITY(1, 1)
		,ObjectName VARCHAR(100)
		)

	IF @Flag = 'C'
	BEGIN
		INSERT INTO #Indexes (ObjectName)
		SELECT DISTINCT OBJECT_NAME(object_id) AS TableName
		FROM sys.indexes SI
		WHERE SI.type <> '1'
			AND (
				OBJECT_NAME(SI.object_id) LIKE '%CodeSet%'
				OR OBJECT_NAME(SI.object_id) LIKE '%LKUP%'
				)
			AND type_desc <> 'HEAP'
	END

	IF @Flag = 'T'
	BEGIN
		INSERT INTO #Indexes (ObjectName)
		SELECT DISTINCT OBJECT_NAME(SI.object_id)
		FROM SYS.OBJECTS SO
		INNER JOIN SYS.OBJECTS SO1 ON SO.parent_object_id = SO1.object_id
		INNER JOIN sys.indexes SI ON SI.object_id = SO1.object_id
		WHERE SO.NAME LIKE 'FK%'
			AND SO1.TYPE = 'U'
			AND SI.type <> '1'
			AND (
				SO1.NAME NOT LIKE '%CODESET%'
				AND SO1.NAME NOT LIKE '%LKUP%'
				)
			AND SI.NAME IS NOT NULL
			--ORDER BY si.name
	END

	IF @Flag = 'L'
	BEGIN
		INSERT INTO #Indexes (ObjectName)
		SELECT DISTINCT OBJECT_NAME(SI.object_id)
		FROM SYS.objects SO
		INNER JOIN sys.indexes SI ON SO.object_id = SI.object_id
		INNER JOIN SYS.tables ST ON ST.object_id = SO.object_id
		WHERE ST.OBJECT_ID NOT IN (
				SELECT DISTINCT so1.object_id
				FROM SYS.OBJECTS so
				INNER JOIN SYS.OBJECTS so1 ON so.parent_object_id = so1.object_id
				WHERE so.NAME LIKE 'FK%'
					AND so1.type = 'U'
				
				UNION
				
				SELECT DISTINCT object_id
				FROM SYS.objects
				WHERE NAME LIKE '%CodeSet%'
					OR NAME LIKE '%LKUP%'
				)
			AND SI.type <> '1'
			AND SO.type = 'U'
			--ORDER BY name
	END

	-------------Loop till all the Objects are processed----------------------
	SET @StartPos = 1

	SELECT @EndPos = MAX(Id)
	FROM #Indexes

	WHILE (@StartPos <= @EndPos)
	BEGIN
		SELECT @ObjectName = ObjectName
		FROM #Indexes
		WHERE Id = @StartPos

		-------------Build the SQL to get the index data based on the inputs provided----------------------
		SET @IndexSQL = 'SELECT so.Name as ObjectName, si.Name as IndexName,si.Is_Unique,si.Type_Desc' + ',si.Is_Padded,si.Ignore_Dup_Key,si.Allow_Row_Locks,si.Allow_Page_Locks,si.Fill_Factor,sic.Is_Descending_Key' + ',sc.Name as ColumnName,sic.Is_Included_Column,sf.Name as FileGroupName,0 as Has_Filter,N'''' as Filter_Definition FROM ' + QUOTENAME(@DBName) + '.sys.Objects so INNER JOIN ' + QUOTENAME(@DBName) + '.sys.Indexes si ON so.Object_Id = si.Object_id INNER JOIN ' + QUOTENAME(@DBName) + '.sys.FileGroups sf ON sf.Data_Space_Id = si.Data_Space_Id INNER JOIN ' + QUOTENAME(@DBName) + '.sys.Index_columns sic ON si.Object_Id = sic.Object_Id AND si.Index_id = sic.Index_id INNER JOIN ' + QUOTENAME(@DBName) + '.sys.Columns sc ON sic.Column_Id = sc.Column_Id and sc.Object_Id = sic.Object_Id ' + ' WHERE so.Name = ''' + @ObjectName + '''' + ' AND so.Schema_id = ' + CAST(Schema_Id(@Schemaname) AS VARCHAR(25)) + ' AND si.Type_Desc = ''NONCLUSTERED'' AND SI.type<>''1'' '

		IF (@IndexName IS NOT NULL)
		BEGIN
			SET @IndexSQL = @IndexSQL + ' AND si.Name = ''' + @IndexName + ''''
		END

		SET @IndexSQL = @IndexSQL + ' ORDER BY ObjectName, IndexName, sic.Key_Ordinal'

		--PRINT @IndexSQL
		-------------Insert the Index Data in to a variable----------------------
		BEGIN TRY
			INSERT INTO @WholeIndexData
			EXEC sp_executesql @IndexSQL
		END TRY

		BEGIN CATCH
			SELECT @ErrorMessage = ERROR_MESSAGE()

			GOTO ABEND
		END CATCH

		--Check if any indexes are there on the object. Otherwise exit
		IF (
				SELECT COUNT(*)
				FROM @WholeIndexData
				) = 0
		BEGIN
			SELECT 'Object does not have any nonclustered indexes to move'

			GOTO FINAL
		END

		-------------Get the distinct index rows in to a variable----------------------
		INSERT INTO @DistinctIndexData
		SELECT DISTINCT ObjectName
			,IndexName
			,Is_Unique
			,Type_Desc
			,Is_Padded
			,Ignore_Dup_Key
			,Allow_Row_Locks
			,Allow_Page_Locks
			,Fill_Factor
			,FileGroupName
			,Has_Filter
			,Filter_Definition
		FROM @WholeIndexData
		WHERE ObjectName = @ObjectName

		SELECT @CurLoopCount = Min(Id)
			,@MaxLoopCount = Max(Id)
		FROM @DistinctIndexData
		WHERE ObjectName = @ObjectName

		--SELECT @CurLoopCount, @MaxLoopCount
		-------------Loop till all the indexes are processed----------------------
		WHILE (@CurLoopCount <= @MaxLoopCount)
		BEGIN
			SET @IndexKeySQL = ''
			SET @IncludeColSQL = ''

			-------------Get the current index row to be processed----------------------
			SELECT @IndName = IndexName
				,@Type = Type_Desc
				,@ExistingFGName = FileGroupName
				,@IsUnique = CASE 
					WHEN Is_Unique = 1
						THEN 'UNIQUE '
					ELSE ''
					END
				,@IsPadded = CASE 
					WHEN Is_Padded = 0
						THEN 'OFF,'
					ELSE 'ON,'
					END
				,@IgnoreDupKey = CASE 
					WHEN Ignore_Dup_Key = 0
						THEN 'OFF,'
					ELSE 'ON,'
					END
				,@AllowRowLocks = CASE 
					WHEN Allow_Row_Locks = 0
						THEN 'OFF,'
					ELSE 'ON,'
					END
				,@AllowPageLocks = CASE 
					WHEN Allow_Page_Locks = 0
						THEN 'OFF,'
					ELSE 'ON,'
					END
				,@FillFactor = CASE 
					WHEN Fill_Factor = 0
						THEN 100
					ELSE Fill_Factor
					END
				,@FilterDef = CASE 
					WHEN Has_Filter = 1
						THEN (' WHERE ' + Filter_Definition)
					ELSE ''
					END
			FROM @DistinctIndexData
			WHERE Id = @CurLoopCount

			-----------Check if the index is already not part of that FileGroup----------------------
			IF (@ExistingFGName = @FileGroupName)
			BEGIN
				PRINT 'Index ' + @IndName + ' is NOT moved as it is already part of the FileGroup ' + @FileGroupName + '.'

				SET @CurLoopCount = @CurLoopCount + 1

				CONTINUE
			END

			------- Construct the Index key string along with the direction--------------------
			SELECT @IndexKeySQL = CASE 
					WHEN @IndexKeySQL = ''
						THEN (
								@IndexKeySQL + QUOTENAME(ColumnName) + CASE 
									WHEN Is_Descending_Key = 0
										THEN ' ASC'
									ELSE ' DESC'
									END
								)
					ELSE (
							@IndexKeySQL + ',' + QUOTENAME(ColumnName) + CASE 
								WHEN Is_Descending_Key = 0
									THEN ' ASC'
								ELSE ' DESC'
								END
							)
					END
			FROM @WholeIndexData
			WHERE ObjectName = @ObjectName
				AND IndexName = @IndName
				AND Is_Included_Column = 0

			--PRINT @IndexKeySQL
			------ Construct the Included Column string --------------------------------------
			SELECT @IncludeColSQL = CASE 
					WHEN @IncludeColSQL = ''
						THEN (@IncludeColSQL + QUOTENAME(ColumnName))
					ELSE (@IncludeColSQL + ',' + QUOTENAME(ColumnName))
					END
			FROM @WholeIndexData
			WHERE ObjectName = @ObjectName
				AND IndexName = @IndName
				AND Is_Included_Column = 1

			--PRINT @IncludeColSQL
			-------------Construct the final Create Index statement----------------------
			SELECT @FinalSQL = 'CREATE ' + @IsUnique + @Type + ' INDEX ' + QUOTENAME(@IndName) + ' ON ' + QUOTENAME(@DBName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName) + '(' + @IndexKeySQL + ') ' + CASE 
					WHEN LEN(@IncludeColSQL) <> 0
						THEN 'INCLUDE(' + @IncludeColSQL + ') '
					ELSE ''
					END + @FilterDef + ' WITH (' + 'PAD_INDEX = ' + @IsPadded + 'IGNORE_DUP_KEY = ' + @IgnoreDupKey + 'ALLOW_ROW_LOCKS = ' + @AllowRowLocks + 'ALLOW_PAGE_LOCKS = ' + @AllowPageLocks + 'SORT_IN_TEMPDB = OFF,' + 'DROP_EXISTING = ON,' + 'ONLINE = OFF,' + 'FILLFACTOR = ' + CAST(@FillFactor AS VARCHAR(3)) + ') ON ' + QUOTENAME(@FileGroupName)

			PRINT @FinalSQL
			-------------Execute the Create Index statement to move to the specified filegroup----------------------
			BEGIN TRY
				PRINT (@FinalSQL)

				EXEC sp_executesql @FinalSQL
			END TRY

			BEGIN CATCH
				SELECT @ErrorMessage = ERROR_MESSAGE()

				GOTO ABEND
			END CATCH

			PRINT 'Index ' + @IndName + ' on Object ' + @ObjectName + ' is moved successfully.'

			SET @CurLoopCount = @CurLoopCount + 1
		END

		SET @StartPos = @StartPos + 1
	END

	SELECT 'The procedure completed successfully.'

	RETURN

	ABEND:

	RAISERROR 500001 @ErrorMessage

	FINAL:

	RETURN
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[Usp_MoveIndexesToFileGroup] TO [FE_rohit.r-ext]
    AS [dbo];

