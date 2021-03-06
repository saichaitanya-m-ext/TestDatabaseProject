﻿CREATE PROCEDURE [dbo].[aspnet_Profile_GetNumberOfInactiveProfiles]
       @ApplicationName NVARCHAR(256) ,
       @ProfileAuthOptions INT ,
       @InactiveSinceDate DATETIME
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
         BEGIN
               SELECT
                   0
               RETURN
         END

      SELECT
          COUNT(*)
      FROM
          dbo.aspnet_Users u ,
          dbo.aspnet_Profile p
      WHERE
          ApplicationId = @ApplicationId AND u.UserId = p.UserId AND ( LastActivityDate <= @InactiveSinceDate ) AND ( ( @ProfileAuthOptions = 2 ) OR ( @ProfileAuthOptions = 0 AND IsAnonymous = 1 ) OR ( @ProfileAuthOptions = 1 AND IsAnonymous = 0 ) )
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Profile_GetNumberOfInactiveProfiles] TO [FE_rohit.r-ext]
    AS [dbo];

