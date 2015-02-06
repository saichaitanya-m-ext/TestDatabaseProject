﻿CREATE PROCEDURE [dbo].[aspnet_Membership_GetUserByEmail]
       @ApplicationName NVARCHAR(256) ,
       @Email NVARCHAR(256)
AS
BEGIN
      IF ( @Email IS NULL )
         SELECT
             u.UserName
         FROM
             dbo.aspnet_Applications a ,
             dbo.aspnet_Users u ,
             dbo.aspnet_Membership m
         WHERE
             LOWER(@ApplicationName) = a.LoweredApplicationName AND u.ApplicationId = a.ApplicationId AND u.UserId = m.UserId AND m.LoweredEmail IS NULL
      ELSE
         SELECT
             u.UserName
         FROM
             dbo.aspnet_Applications a ,
             dbo.aspnet_Users u ,
             dbo.aspnet_Membership m
         WHERE
             LOWER(@ApplicationName) = a.LoweredApplicationName AND u.ApplicationId = a.ApplicationId AND u.UserId = m.UserId AND LOWER(@Email) = m.LoweredEmail

      IF ( @@rowcount = 0 )
         RETURN ( 1 )
      RETURN ( 0 )
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Membership_GetUserByEmail] TO [FE_rohit.r-ext]
    AS [dbo];

