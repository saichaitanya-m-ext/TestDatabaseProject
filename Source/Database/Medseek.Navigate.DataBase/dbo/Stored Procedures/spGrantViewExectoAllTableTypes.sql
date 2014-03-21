CREATE PROCEDURE [dbo].[spGrantViewExectoAllTableTypes] @user SYSNAME 
AS
SET NOCOUNT ON

-- 1 - Variable declarations
DECLARE @CMD1 VARCHAR(8000)
DECLARE @MAXOID INT
DECLARE @ObjectName VARCHAR(128)

-- 2 - Create temporary table
CREATE TABLE #TableTypes
(
  OID INT IDENTITY(1,1) ,
  TableTypeName VARCHAR(128) NOT NULL )

-- 3 - Populate temporary table
INSERT INTO
    #TableTypes
    (
      TableTypeName 
      )
    SELECT
       
        NAME
    FROM
        sys.table_types
    WHERE
        is_user_defined = 1

-- 4 - Capture the @MAXOID value
SELECT
    @MAXOID = MAX(OID)
FROM
    #TableTypes

-- 5 - WHILE loop
WHILE @MAXOID > 0
      BEGIN 

-- 6 - Initialize the variables
            SELECT
                @ObjectName = TableTypeName 
            FROM
                #TableTypes
            WHERE
                OID = @MAXOID

-- 7 - Build the string
            SELECT
                @CMD1 = 'GRANT EXECUTE , view definition ON TYPE::' + '[' + @ObjectName + ']' + ' TO [' + @user + ']'

-- 8 - Execute the string
-- SELECT @CMD1
            EXEC ( @CMD1 )

-- 9 - Decrement @MAXOID
            SET @MAXOID = @MAXOID - 1
      END

-- 10 - Drop the temporary table
DROP TABLE #TableTypes

SET NOCOUNT OFF

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[spGrantViewExectoAllTableTypes] TO [FE_rohit.r-ext]
    AS [dbo];

