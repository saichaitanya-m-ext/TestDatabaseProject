

-- =============================================
-- Author:		Gouri Shankar Aechoor
-- Create date: 14-MAY-2013
-- Description:	Recompiles all SP's in a DB.
-- =============================================
CREATE PROCEDURE [dbo].[usp_dbAdmin_RecompileSP]
AS
BEGIN
	DECLARE @i_Loop INT
		,@i_LoopCount INT = 1

	IF OBJECT_ID(N'tempdb..#RecompileSP') IS NOT NULL
		DROP TABLE #RecompileSP

	SELECT ROW_NUMBER() OVER (
			ORDER BY ROUTINE_NAME
			) AS id
		,'sp_recompile [' + ROUTINE_NAME + ']' AS SQLCode
	INTO #RecompileSP
	FROM INFORMATION_SCHEMA.ROUTINES
	WHERE ROUTINE_TYPE = 'PROCEDURE'

	SELECT @i_Loop = MAX(id)
	FROM #RecompileSP

	WHILE @i_LoopCount <= @i_Loop
	BEGIN
		DECLARE @v_SQL NVARCHAR(MAX)

		SELECT @v_SQL = SQLCode
		FROM #RecompileSP
		WHERE id = @i_LoopCount

		EXEC sp_executesql @v_SQL

		SET @i_LoopCount = @i_LoopCount + 1
	END
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_dbAdmin_RecompileSP] TO [FE_rohit.r-ext]
    AS [dbo];

