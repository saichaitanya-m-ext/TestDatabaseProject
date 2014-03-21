﻿CREATE PROCEDURE [dbo].[aspnet_Membership_GetUserByUserId]
       @UserId UNIQUEIDENTIFIER ,
       @CurrentTimeUtc DATETIME ,
       @UpdateLastActivity BIT = 0
AS
BEGIN
      IF ( @UpdateLastActivity = 1 )
         BEGIN
               UPDATE
                   dbo.aspnet_Users
               SET
                   LastActivityDate = @CurrentTimeUtc
               FROM
                   dbo.aspnet_Users
               WHERE
                   @UserId = UserId

               IF ( @@ROWCOUNT = 0 ) -- User ID not found
                  RETURN -1
         END

      SELECT
          m.Email ,
          m.PasswordQuestion ,
          m.Comment ,
          m.IsApproved ,
          m.CreateDate ,
          m.LastLoginDate ,
          u.LastActivityDate ,
          m.LastPasswordChangedDate ,
          u.UserName ,
          m.IsLockedOut ,
          m.LastLockoutDate
      FROM
          dbo.aspnet_Users u ,
          dbo.aspnet_Membership m
      WHERE
          @UserId = u.UserId AND u.UserId = m.UserId

      IF ( @@ROWCOUNT = 0 ) -- User ID not found
         RETURN -1

      RETURN 0
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Membership_GetUserByUserId] TO [FE_rohit.r-ext]
    AS [dbo];
