CREATE PROCEDURE [dbo].[spGrantExectoAllStoredProcs] @user SYSNAME
AS
SET NOCOUNT ON

-- 1 - Variable declarations
DECLARE @CMD1 VARCHAR(8000)
DECLARE @MAXOID INT
DECLARE @OwnerName VARCHAR(128)
DECLARE @ObjectName VARCHAR(128)

-- 2 - Create temporary table
CREATE TABLE #StoredProcedures
(
  OID INT IDENTITY(1,1) ,
  StoredProcOwner VARCHAR(128) NOT NULL ,
  StoredProcName VARCHAR(128) NOT NULL )

-- 3 - Populate temporary table
INSERT INTO
    #StoredProcedures
    (
      StoredProcOwner ,
      StoredProcName )
    SELECT
        ROUTINE_SCHEMA ,
        ROUTINE_NAME
    FROM
        INFORMATION_SCHEMA.ROUTINES
    WHERE
        ROUTINE_NAME NOT LIKE 'dt_%' AND ROUTINE_TYPE = 'PROCEDURE'

-- 4 - Capture the @MAXOID value
SELECT
    @MAXOID = MAX(OID)
FROM
    #StoredProcedures

-- 5 - WHILE loop
WHILE @MAXOID > 0
      BEGIN 

-- 6 - Initialize the variables
            SELECT
                @OwnerName = StoredProcOwner ,
                @ObjectName = StoredProcName
            FROM
                #StoredProcedures
            WHERE
                OID = @MAXOID

-- 7 - Build the string
            SELECT
                @CMD1 = 'GRANT EXEC ON ' + '[' + @OwnerName + ']' + '.' + '[' + @ObjectName + ']' + ' TO [' + @user + ']'

-- 8 - Execute the string
-- SELECT @CMD1
            EXEC ( @CMD1 )

-- 9 - Decrement @MAXOID
            SET @MAXOID = @MAXOID - 1
      END

-- 10 - Drop the temporary table
DROP TABLE #StoredProcedures

SET NOCOUNT OFF

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[spGrantExectoAllStoredProcs] TO [FE_rohit.r-ext]
    AS [dbo];

