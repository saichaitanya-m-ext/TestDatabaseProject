CREATE PROCEDURE [dbo].[aspnet_Setup_RestorePermissions] @name SYSNAME
AS
BEGIN
      DECLARE @object SYSNAME
      DECLARE @protectType CHAR(10)
      DECLARE @action VARCHAR(20)
      DECLARE @grantee SYSNAME
      DECLARE @cmd NVARCHAR(500)
      DECLARE c1 CURSOR FORWARD_ONLY
              FOR SELECT
                      Object ,
                      ProtectType ,
                      [Action] ,
                      Grantee
                  FROM
                      #aspnet_Permissions
                  WHERE
                      Object = @name

      OPEN c1

      FETCH c1 INTO @object,@protectType,@action,@grantee
      WHILE ( @@fetch_status = 0 )
            BEGIN
                  SET @cmd = @protectType + ' ' + @action + ' on ' + @object + ' TO [' + @grantee + ']'
                  EXEC ( @cmd )
                  FETCH c1 INTO @object,@protectType,@action,@grantee
            END

      CLOSE c1
      DEALLOCATE c1
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Setup_RestorePermissions] TO [FE_rohit.r-ext]
    AS [dbo];

