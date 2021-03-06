﻿CREATE PROCEDURE [dbo].[aspnet_UsersInRoles_GetRolesForUser]
       @ApplicationName NVARCHAR(256) ,
       @UserName NVARCHAR(256)
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
         RETURN ( 1 )
      DECLARE @UserId UNIQUEIDENTIFIER
      SELECT
          @UserId = NULL

      SELECT
          @UserId = UserId
      FROM
          dbo.aspnet_Users
      WHERE
          LoweredUserName = LOWER(@UserName) AND ApplicationId = @ApplicationId

      IF ( @UserId IS NULL )
         RETURN ( 1 )

      SELECT
          r.RoleName
      FROM
          dbo.aspnet_Roles r ,
          dbo.aspnet_UsersInRoles ur
      WHERE
          r.RoleId = ur.RoleId AND r.ApplicationId = @ApplicationId AND ur.UserId = @UserId
      ORDER BY
          r.RoleName
      RETURN ( 0 )
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_UsersInRoles_GetRolesForUser] TO [FE_rohit.r-ext]
    AS [dbo];

