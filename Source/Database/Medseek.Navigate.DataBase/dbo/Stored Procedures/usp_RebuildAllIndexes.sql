CREATE PROCEDURE [dbo].[usp_RebuildAllIndexes] 
(  
 @i_FillFactor INT
)  
AS
BEGIN
DECLARE @TableName VARCHAR(255)
DECLARE @sql NVARCHAR(500)
DECLARE TableCursor CURSOR FOR
SELECT OBJECT_SCHEMA_NAME([object_id])+'.'+name AS TableName
FROM sys.tables
OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @TableName
WHILE @@FETCH_STATUS = 0
BEGIN
SET @sql = 'ALTER INDEX ALL ON ' + @TableName + ' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR(3),@i_FillFactor) + ')'
print(@sql)
EXEC (@sql)
FETCH NEXT FROM TableCursor INTO @TableName
END
CLOSE TableCursor
DEALLOCATE TableCursor
END

--SELECT * FROM MeasureUOM WHERE UOMText IN(
--SELECT UOMText FROM MeasureUOM GROUP BY UOMText HAVING COUNT(*)>1)

--DELETE FROM MeasureUOM WHERE MeasureUOMId IN (815,187,531,736,780,796)


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_RebuildAllIndexes] TO [FE_rohit.r-ext]
    AS [dbo];

