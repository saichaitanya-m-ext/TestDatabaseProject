
-- =================================================================
-- Author:		Gouri Shankar Aechoor
-- Create date: 23-July-2013
-- Description:	Check Newly loaded data inside X number of days
-- Usage	  : usp_dbAdmin_CheckNewDatainXDays
--				usp_dbAdmin_CheckNewDatainXDays 30,'CCMV2NPODEV', 'CCMV2DEV'
--				usp_dbAdmin_CheckNewDatainXDays 30,'CCMV2DEV'
--				usp_dbAdmin_CheckNewDatainXDays NULL,'CCMV2NPODEV',NULL,'2013-06-22','2013-06-22'
-- =================================================================
CREATE PROCEDURE [dbo].[usp_dbAdmin_CheckNewDatainXDays]
	@v_NumberOfDays VARCHAR(5) = NULL,
	@v_SourceDB VARCHAR(250) = NULL,
	@v_TargetDB VARCHAR(250) = NULL,
	@d_StartDate Date = NULL,
	@d_EndDate DAte = NULL
AS
BEGIN
	SET ROWCOUNT 0
	
	DECLARE @DBList TABLE (TID INT IDENTITY(1 ,1) ,DBName VARCHAR(500)) 
	
	DECLARE @StartLoop INT = 1
	DECLARE @Maxloop INT
	DECLARE @v_StartDate VARCHAR(10)
	DECLARE @v_EndDate VARCHAR(10)
	
	SET @v_NumberOfDays = COALESCE(@v_NumberOfDays,'0')
	
	IF (@d_StartDate IS NOT NULL AND @v_EndDate IS NOT NULL)
	BEGIN
		SET @v_StartDate	= CAST(CONVERT(date ,@d_StartDate ,114) AS VARCHAR(10))
		SET @v_EndDate		= CAST(CONVERT(date ,@d_EndDate ,114) AS VARCHAR(10))
	END
	
	SET @StartLoop = 1
	
	SELECT @v_SourceDB = COALESCE(@v_SourceDB ,DB_NAME())
	
	INSERT INTO @DBList
	  (
	    DBName
	  )
	SELECT *
	FROM   (
	           SELECT @v_SourceDB AS TableName
	           UNION  
	           SELECT @v_TargetDB
	       ) a
	WHERE  LEN(COALESCE(a.TableName ,'')) > 1
	
	SELECT @Maxloop = MAX(TID)
	FROM   @DBList
	
	--CREATE PROCEDURE dbAdmin_Data
	WHILE @StartLoop <= @Maxloop
	BEGIN
	    DECLARE @Result TABLE (TableNames VARCHAR(500))
	    DECLARE @SQL NVARCHAR(MAX) = NULL
	    
	    SELECT @Maxloop
	          ,@v_SourceDB
	    
	    SELECT @SQL = COALESCE(@SQL ,'') + CHAR(13) + 'SELECT ''' + t.TABLE_NAME + ''' AS TableNames' + CHAR(13)
	           + 'FROM ' + t.TABLE_CATALOG + '.' + t.TABLE_SCHEMA + '.' + t.TABLE_NAME + CHAR(13) 
	           + CASE 
	                  WHEN @d_StartDate IS NULL OR @v_EndDate IS NULL 
						   THEN 'WHERE CreatedDate >= GETDATE()-' + @v_NumberOfDays + CHAR(13)
	                  ELSE 'WHERE CreatedDate BETWEEN ''' + @v_StartDate + ''' AND ''' + @v_EndDate +''''+ CHAR(13)
	             END
	           + CHAR(13) 
	           + 'UNION ALL'
	    FROM   INFORMATION_SCHEMA.TABLES t
	    JOIN INFORMATION_SCHEMA.COLUMNS c
	           ON  OBJECT_ID(t.TABLE_NAME) = OBJECT_ID(c.TABLE_NAME)
	    WHERE  TABLE_TYPE = 'BASE TABLE'
	    AND    c.COLUMN_NAME = 'CreatedDate'
	    AND    c.TABLE_CATALOG = @v_SourceDB
	    
	    PRINT @SQL 
	    SET @SQL = 'USE [' + @v_SourceDB + ']' + CHAR(13) 
	        + ';WITH CTE AS (' + SUBSTRING(@SQL ,1 ,LEN(@SQL) -9) + ')' + CHAR(13) 
	        + 'SELECT DISTINCT TableNames AS ''TablesWithNewData''  FROM CTE' + CHAR(13) 
	        + 'ORDER BY 1'
	    
	    INSERT INTO @Result
	    EXEC sp_executesql @SQL
	    
	    PRINT @SQL
	    
	    SET @SQL = NULL
	    
	    SELECT @SQL = COALESCE(
	               @SQL + 'UNION ALL' + CHAR(13)
	              ,'USE [' + @v_SourceDB + ']' + CHAR(13) + ';WITH CTE AS (' + CHAR(13)
	           ) 
	           + 'SELECT ''' + TableNames + ''' as ' + 'TableName, COUNT(1) as TCount ' + CHAR(13)
	           + 'FROM ' + TableNames + CHAR(13)
	    FROM   @Result
	    
	    SET @SQL = @SQL + ')' + CHAR(13) + 'SELECT * FROM CTE'
	    
	    --SELECT TableNames  AS TablesWithChagedData
	    --FROM   @Result
	    PRINT 'here'
	    EXEC sp_executesql @SQL
	    
	    SET @StartLoop = @StartLoop + 1
	    SET @v_SourceDB = @v_TargetDB
	END
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_dbAdmin_CheckNewDatainXDays] TO [FE_rohit.r-ext]
    AS [dbo];

