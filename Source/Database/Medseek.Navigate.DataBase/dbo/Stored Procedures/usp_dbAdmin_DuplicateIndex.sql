-- =============================================
-- Author:		Gouri Shankar
-- Create date: 16-MAY-2013
-- Description:	Check Duplicate Index
-- =============================================
/*
usp_dbAdmin_DuplicateIndex 1
*/
CREATE PROCEDURE usp_dbAdmin_DuplicateIndex
	@ExecuteDropSQL BIT = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	IF OBJECT_ID('tempdb..#usp_dbAdmin_DuplicateIndex')>0
	DROP TABLE #usp_dbAdmin_DuplicateIndex
	
	;WITH DuplicateIndex
	AS 
	(
	SELECT Sch.[name] AS SchemaName
		,Obj.[name] AS TableName
		,Idx.[name] AS IndexName
		,Idx.type_desc
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 1) AS Col1
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 2) AS Col2
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 3) AS Col3
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 4) AS Col4
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 5) AS Col5
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 6) AS Col6
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 7) AS Col7
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 8) AS Col8
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 9) AS Col9
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 10) AS Col10
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 11) AS Col11
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 12) AS Col12
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 13) AS Col13
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 14) AS Col14
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 15) AS Col15
		,INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 16) AS Col16
	FROM sys.indexes Idx
	INNER JOIN sys.objects Obj
		ON Idx.[object_id] = Obj.[object_id]
	INNER JOIN sys.schemas Sch
		ON Sch.[schema_id] = Obj.[schema_id]
	WHERE index_id > 0
	)
	,Resultset as
	(	
	SELECT ROW_NUMBER() OVER (
			PARTITION BY MD1.SchemaName
			,MD1.TableName ORDER BY md1.type_desc
			) AS ID
		,QUOTENAME(MD1.SchemaName)+'.'+QUOTENAME(MD1.TableName) AS TableName
		,MD1.IndexName
		,MD2.IndexName AS OverLappingIndex
		,md1.type_desc
		,MD1.Col1
		,MD1.Col2
		,MD1.Col3
		,MD1.Col4
		,MD1.Col5
		,MD1.Col6
		,MD1.Col7
		,MD1.Col8
		,MD1.Col9
		,MD1.Col10
		,MD1.Col11
		,MD1.Col12
		,MD1.Col13
		,MD1.Col14
		,MD1.Col15
		,MD1.Col16
	FROM DuplicateIndex MD1
	INNER JOIN DuplicateIndex MD2
		ON MD1.tablename = MD2.tablename
			AND MD1.indexname <> MD2.indexname
			AND ISNULL(MD1.Col1, '') = ISNULL(MD2.Col1, '')
			AND ISNULL(MD1.Col2, '') = ISNULL(MD2.Col2, '')
			AND ISNULL(MD1.Col3, '') = ISNULL(MD2.Col3, '')
			AND ISNULL(MD1.Col4, '') = ISNULL(MD2.Col4, '')
			AND ISNULL(MD1.Col5, '') = ISNULL(MD2.Col5, '')
			AND ISNULL(MD1.Col6, '') = ISNULL(MD2.Col6, '')
			AND ISNULL(MD1.Col7, '') = ISNULL(MD2.Col7, '')
			AND ISNULL(MD1.Col8, '') = ISNULL(MD2.Col8, '')
			AND ISNULL(MD1.Col9, '') = ISNULL(MD2.Col9, '')
			AND ISNULL(MD1.Col10, '') = ISNULL(MD2.Col10, '')
			AND ISNULL(MD1.Col11, '') = ISNULL(MD2.Col11, '')
			AND ISNULL(MD1.Col12, '') = ISNULL(MD2.Col12, '')
			AND ISNULL(MD1.Col13, '') = ISNULL(MD2.Col13, '')
			AND ISNULL(MD1.Col14, '') = ISNULL(MD2.Col14, '')
			AND ISNULL(MD1.Col15, '') = ISNULL(MD2.Col15, '')
			AND ISNULL(MD1.Col16, '') = ISNULL(MD2.Col16, '')
	)
	
	SELECT 
		 ROW_NUMBER() OVER (ORDER BY TableName,IndexName) AS ID
		,TableName
		,IndexName
		,OverLappingIndex
		,'DROP INDEX ' 
		+ OverLappingIndex
		+ ' ON ' 
		+ TableName as DropScript
	INTO #usp_dbAdmin_DuplicateIndex
	FROM Resultset
	WHERE ID % 2 = 1
	
	IF @ExecuteDropSQL=0
	BEGIN
		SELECT * from #usp_dbAdmin_DuplicateIndex
	END
	ELSE 
	IF @ExecuteDropSQL=1
	BEGIN
		DECLARE  @maxloop INT
				,@loopCount INT = 1

		SELECT @maxloop = MAX(id)
		FROM #usp_dbAdmin_DuplicateIndex
		
		WHILE @loopCount<=@maxloop
		BEGIN
			DECLARE @SQL VARCHAR(8000)
			
			SELECT @SQL = DropScript
			FROM #usp_dbAdmin_DuplicateIndex
			WHERE ID = @loopCount
			
			--exec sp_executesql @SQL
			PRINT @SQL+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)
			
			SET @loopCount= @loopCount + 1
		END

	END
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_dbAdmin_DuplicateIndex] TO [FE_rohit.r-ext]
    AS [dbo];

