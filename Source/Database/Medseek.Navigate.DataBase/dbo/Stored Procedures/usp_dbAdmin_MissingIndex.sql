-- =============================================
-- Author:		Gouri Shankar
-- Create date: 16-MAY-2013
-- Description:	Check for Missing index
-- =============================================
/*
EXEC usp_dbAdmin_MissingIndex
*/
CREATE PROCEDURE usp_dbAdmin_MissingIndex 
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT --mid.database_id
		 mid.[statement] AS TableName
		,ROUND(migs.avg_total_user_cost *
			   migs.avg_user_impact
				* (migs.user_seeks + migs.user_scans),0)
						 AS [TotalCost]
		,'CREATE INDEX missing_index_' 
		+ CONVERT(VARCHAR, mig.index_group_handle) + '_' + CONVERT(VARCHAR, mid.index_handle) 
		+ ' ON ' + mid.statement + ' (' + ISNULL(mid.equality_columns, '') 
		+ CASE 
				WHEN mid.equality_columns IS NOT NULL
					AND mid.inequality_columns IS NOT NULL
					THEN ','
				ELSE ''
			END 
		+ ISNULL(mid.inequality_columns, '') + ')' 
		+ ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS CreateScript
		--,migs.*
		--,mig.index_group_handle
		--,mid.index_handle
	FROM sys.dm_db_missing_index_groups mig
	INNER JOIN sys.dm_db_missing_index_group_stats migs
		ON migs.group_handle = mig.index_group_handle
	INNER JOIN sys.dm_db_missing_index_details mid
		ON mig.index_handle = mid.index_handle
	WHERE CONVERT(DECIMAL(28, 1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) > 10
		AND database_id = DB_ID()
	ORDER BY [TotalCost] DESC
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_dbAdmin_MissingIndex] TO [FE_rohit.r-ext]
    AS [dbo];

