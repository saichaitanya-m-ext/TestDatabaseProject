CREATE PROCEDURE [dbo].[aspnet_UsersInRoles_IsUserInRole]
       @ApplicationName NVARCHAR(256) ,
       @UserName NVARCHAR(256) ,
       @RoleName NVARCHAR(256)
AS
BEGIN
      DECLARE @ApplicationId UNIQUEIDENTIFIER
      SELECT
          @ApplicationId = NULL
      SELECT
          @ApplicationId = ApplicationId
      FROM
          aspnet_Applications
      WHERE
          LOWER(@ApplicationName) = LoweredApplicationName
      IF ( @ApplicationId IS NULL )
         RETURN ( 2 )
      DECLARE @UserId UNIQUEIDENTIFIER
      SELECT
          @UserId = NULL
      DECLARE @RoleId UNIQUEIDENTIFIER
      SELECT
          @RoleId = NULL

      SELECT
          @UserId = UserId
      FROM
          dbo.aspnet_Users
      WHERE
          LoweredUserName = LOWER(@UserName) AND ApplicationId = @ApplicationId

      IF ( @UserId IS NULL )
         RETURN ( 2 )

      SELECT
          @RoleId = RoleId
      FROM
          dbo.aspnet_Roles
      WHERE
          LoweredRoleName = LOWER(@RoleName) AND ApplicationId = @ApplicationId

      IF ( @RoleId IS NULL )
         RETURN ( 3 )

      IF ( EXISTS ( SELECT
                        *
                    FROM
                        dbo.aspnet_UsersInRoles
                    WHERE
                        UserId = @UserId AND RoleId = @RoleId ) )
         RETURN ( 1 )
      ELSE
         RETURN ( 0 )
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_UsersInRoles_IsUserInRole] TO [FE_rohit.r-ext]
    AS [dbo];

