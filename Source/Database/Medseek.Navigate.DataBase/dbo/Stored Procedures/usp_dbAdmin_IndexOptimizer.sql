-- ===================================================================
-- Author:      Gouri Shankar Goverdhan Aechoor

-- Create date: 17-MAY-2013

-- Description: Checks for non-maintaned indexes in the databes it is
--              invoked in and based on the condition it either rebuilds
--              or re-organizes those indexes.
--              A value between 5-30% indicates moderate fragmentation,
--              while any value over 30% indicates high fragmentation
-- ===================================================================
CREATE PROCEDURE usp_dbAdmin_IndexOptimizer
    @tintFragPerc        TINYINT        = 30,
    @txtIndexName        VARCHAR(50) = N'PK_Customer_CustomerID',
    @txtTableName        VARCHAR(50) = N'Customer',
    @tintBuildOnline		BIT            = 0,        --Default is (0) No. (1) is for Yes
    @Debug                BIT            = 1
AS
BEGIN
    SET NOCOUNT ON;
   
--------------------------------------------------------------------
--Retreve Indexes to be processes
--------------------------------------------------------------------
IF @txtIndexName IS NULL AND @txtTableName IS NULL GOTO Begin_Block;

IF @txtIndexName IS NULL
   AND @txtTableName IS NOT NULL
BEGIN
    RAISERROR ('Please enter Index Name in the table %s that needs to be re-built',
                0,1,@txtIndexName)
    RETURN
END
IF @txtIndexName IS NOT NULL
   AND @txtTableName IS NULL
BEGIN
    RAISERROR ('Please enter Table Name on which the %s Index is applied',
                0,1,@txtIndexName)
    RETURN
END


Begin_Block:
;WITH CTE AS (
                SELECT DB_NAME() AS DBNAME,
                       (
                           OBJECT_SCHEMA_NAME(FRAG.[object_id])
                           + '.' + OBJECT_NAME(FRAG.[object_id])
                       ) AS TableName,
                       SIX.[name] IndexName,
                       FRAG.avg_fragmentation_in_percent,
                       FRAG.page_count,
                       FRAG.index_type_desc
                FROM   sys.dm_db_index_physical_stats
                       (
                           DB_ID()                --use the currently connected database
                           ,NULL                --Parameter for object_id.
                           ,DEFAULT                --Parameter for index_id.
                           ,NULL                --Parameter for partition_number.
                           ,DEFAULT
                       ) FRAG                    --Scanning mode. Default to "LIMITED", which is good enough
                       JOIN sys.indexes SIX
                            ON  FRAG.[object_id] = SIX.[object_id]
                            AND FRAG.index_id = SIX.index_id
                WHERE  FRAG.index_type_desc <> 'HEAP'
                AND (
                        FRAG.page_count > 20 AND                --exclude tables with not many rows
                        FRAG.avg_fragmentation_in_percent > 10    --not worth fragmenting if less than 10
                     )
            )

--------------------------------------------------------------------
--Generate Index Re-build queries
--------------------------------------------------------------------
,cte2 AS (
        SELECT 1 AS OrderNo,
               'BEGIN TRANSACTION; '
               + 'ALTER INDEX [' + IndexName
               + '] ON [' + DB_NAME()
               + '].[' + SUBSTRING(TABLEName, 1, CHARINDEX('.', TABLEName) -1)
               + '].[' + SUBSTRING(TABLEName, CHARINDEX('.', TABLEName) + 1, LEN(TABLEName))
               + '] REBUILD WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON,STATISTICS_NORECOMPUTE = OFF,ONLINE = ON) '
               + 'COMMIT TRANSACTION;' AS SQLQuery
        FROM   cte
        WHERE  avg_fragmentation_in_percent >= @tintFragPerc
        AND        (@txtIndexName IS NULL OR @txtIndexName = IndexName)
        AND        (@txtTableName IS NULL OR @txtTableName = SUBSTRING(TABLEName,CHARINDEX('.',TABLEName)+1,LEN(TABLEName)))
        UNION
        SELECT 2 AS OrderNo,
               'BEGIN TRANSACTION; '
               + 'ALTER INDEX [' + IndexName
               + '] ON [' + DB_NAME()
               + '].[' + SUBSTRING(TABLEName, 1, CHARINDEX('.', TABLEName) -1)
               + '].[' + SUBSTRING(TABLEName, CHARINDEX('.', TABLEName) + 1, LEN(TABLEName))
               + '] REORGANIZE '
               + 'COMMIT TRANSACTION;' AS SQLQuery
        FROM   cte
        WHERE  avg_fragmentation_in_percent < @tintFragPerc
        AND       (@txtIndexName IS NULL OR @txtIndexName = IndexName)
    )
    ,cte3 AS (
        SELECT ROW_NUMBER() OVER(ORDER BY OrderNo, SQLQuery) AS SequenceNo,
               SQLQuery
        FROM   cte2
    )
    SELECT * INTO #IndexOpt
    FROM   cte3;
-----------------------------------------------------------------------------   
--Exhicution Phase
-----------------------------------------------------------------------------   
    IF @tintBuildOnline = 1
    UPDATE #IndexOpt
    SET SQLQuery = REPLACE (SQLQuery, ',ONLINE = ON)', ',ONLINE = OFF)')
   
    IF @Debug = 1
    BEGIN
        SELECT * FROM   #IndexOpt;
        DROP TABLE #IndexOpt
    END
    ELSE
    BEGIN
        DECLARE @IntCount INT,
                @intMaxCount INT,
                @txtSQL VARCHAR(MAX);
       
        SET @IntCount = 1
       
        SELECT @intMaxCount = COUNT(*)
        FROM   #IndexOpt;
       
        WHILE (@IntCount <= @intMaxCount)
        BEGIN
            SELECT @txtSQL = SQLQuery
            FROM   #IndexOpt
            WHERE  SequenceNo = @IntCount;
           
            EXEC (@txtSQL)
            SET @IntCount = @IntCount + 1;
        END
        DROP TABLE #IndexOpt;
        SELECT @tintFragPerc,
               @TxtIndexName
    END
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_dbAdmin_IndexOptimizer] TO [FE_rohit.r-ext]
    AS [dbo];

