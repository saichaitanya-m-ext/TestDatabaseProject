-- =============================================
-- Author:        Gouri SHankar Aechoor
-- Create date: 03-May-2013
-- Description:   To get 
-- USP_GetDependencies 'usp_HealthCareQualityMeasure_Select' ,1
-- =============================================


CREATE PROCEDURE USP_GetDependencies
      @ObjectName VARCHAR(250)
      ,@KeepResult bit = 0
AS
BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      DECLARE @SPName VARCHAR(MAX) = QUOTENAME(@ObjectName, '''')
      DECLARE @loop INT = 100
      DECLARE @RNO INT = 1
      DECLARE @ReportDate DATE = GETDATE()

      
      --print @SPName

      IF object_id(N'tempdb..#MainData') IS NOT NULL
      DROP TABLE #MainData

      CREATE TABLE #MainData (
            ObjectName VARCHAR(250)
            ,SerialNumber VARCHAR(250)
            ,referencing_id BIGINT
            ,referencing_entity_name VARCHAR(250)
            ,referenced_entity_name VARCHAR(250)
            ,type_desc VARCHAR(250)
            )
      
      IF @KeepResult = 1 AND OBJECT_ID(N'Tempdb..##MainDataAll') IS NULL
      CREATE TABLE ##MainDataAll (
            ObjectName VARCHAR(250)
            ,SerialNumber VARCHAR(250)
            ,referencing_entity_name VARCHAR(250)
            ,referenced_entity_name VARCHAR(250)
            ,type_desc VARCHAR(250)
            ,ReportDate DATE
            )
            
      IF @KeepResult = 0 AND OBJECT_ID(N'tempdb..##MainDataAll') IS NOT NULL
      DROP TABLE ##MainDataAll
      
      INSERT INTO #MainData
      SELECT @ObjectName,'','','','',''

      WHILE @loop > 0
      BEGIN
            DECLARE @v_SQL NVARCHAR(MAX)
            DECLARE @v_Parameters NVARCHAR(MAX) = '@RNO int'
            
            SET @v_SQL = '
            INSERT INTO #MainData
            SELECT 
                   ''''
                  ,@RNO AS SerialNumber
                  ,referencing_id
                  ,CASE WHEN Row_Number() OVER (order by referencing_id) > 1 THEN ''''
                        ELSE OBJECT_NAME(referencing_id) 
                   END AS referencing_entity_name
                  ,sed.referenced_entity_name
                  ,o.type_desc
            FROM sys.sql_expression_dependencies AS sed
            INNER JOIN sys.objects AS o
                  ON sed.referenced_id = o.object_id
            WHERE OBJECT_NAME(referencing_id) IN ('+@SPName+')
                  AND referenced_class_desc != ''USER_TABLE'' '
                  
            --print @v_SQL
                  
            execute sp_executesql @v_SQL,@v_Parameters
                                          ,@RNO = @RNO

            SELECT @loop = COUNT(1)
            FROM #MainData
            WHERE 
            type_desc != 'USER_TABLE'
            AND SerialNumber = @RNO
            
            --print @loop
            
            SET @SPName = NULL

            SELECT @SPName = COALESCE(@SPName + ',', '') + quotename(referenced_entity_name,'''')
            FROM #MainData
            WHERE type_desc != 'USER_TABLE'
            and SerialNumber = @RNO
            
            --print @SPName
            
            SET @RNO = @RNO + 1
      END

      SELECT ObjectName,SerialNumber,referencing_entity_name,referenced_entity_name,type_desc
      FROM #MainData
      ORDER BY SerialNumber;
      
      IF @KeepResult = 1
      BEGIN
            DECLARE @DoesExists table (ObjectName VARCHAR(250))
            
            INSERT INTO @DoesExists
            SELECT @ObjectName

            IF NOT EXISTS (select 1 from ##MainDataAll m join @DoesExists t on m.ObjectName=t.ObjectName)
            BEGIN
                  INSERT INTO ##MainDataAll(ObjectName,SerialNumber,referencing_entity_name,referenced_entity_name,type_desc,ReportDate)
                  SELECT ObjectName,SerialNumber,referencing_entity_name,referenced_entity_name,type_desc,case when SerialNumber = '' then NULL else @ReportDate end
                  FROM #MainData
                  ORDER BY SerialNumber;
            END
            
            select * from ##MainDataAll
      END

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[USP_GetDependencies] TO [FE_rohit.r-ext]
    AS [dbo];

