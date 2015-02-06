CREATE PROCEDURE [dbo].[aspnet_Membership_UnlockUser]
       @ApplicationName NVARCHAR(256) ,
       @UserName NVARCHAR(256)
AS
BEGIN
      DECLARE @UserId UNIQUEIDENTIFIER
      SELECT
          @UserId = NULL
      SELECT
          @UserId = u.UserId
      FROM
          dbo.aspnet_Users u ,
          dbo.aspnet_Applications a ,
          dbo.aspnet_Membership m
      WHERE
          LoweredUserName = LOWER(@UserName) AND u.ApplicationId = a.ApplicationId AND LOWER(@ApplicationName) = a.LoweredApplicationName AND u.UserId = m.UserId

      IF ( @UserId IS NULL )
         RETURN 1

      UPDATE
          dbo.aspnet_Membership
      SET
          IsLockedOut = 0 ,
          FailedPasswordAttemptCount = 0 ,
          FailedPasswordAttemptWindowStart = CONVERT(DATETIME , '17540101' , 112) ,
          FailedPasswordAnswerAttemptCount = 0 ,
          FailedPasswordAnswerAttemptWindowStart = CONVERT(DATETIME , '17540101' , 112) ,
          LastLockoutDate = CONVERT(DATETIME , '17540101' , 112)
      WHERE
          @UserId = UserId

      RETURN 0
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Membership_UnlockUser] TO [FE_rohit.r-ext]
    AS [dbo];

