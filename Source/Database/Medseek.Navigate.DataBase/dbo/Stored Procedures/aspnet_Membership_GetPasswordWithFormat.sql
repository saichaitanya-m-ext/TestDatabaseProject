CREATE PROCEDURE [dbo].[aspnet_Membership_GetPasswordWithFormat]
       @ApplicationName NVARCHAR(256) ,
       @UserName NVARCHAR(256) ,
       @UpdateLastLoginActivityDate BIT ,
       @CurrentTimeUtc DATETIME
AS
BEGIN
      DECLARE @IsLockedOut BIT
      DECLARE @UserId UNIQUEIDENTIFIER
      DECLARE @Password NVARCHAR(128)
      DECLARE @PasswordSalt NVARCHAR(128)
      DECLARE @PasswordFormat INT
      DECLARE @FailedPasswordAttemptCount INT
      DECLARE @FailedPasswordAnswerAttemptCount INT
      DECLARE @IsApproved BIT
      DECLARE @LastActivityDate DATETIME
      DECLARE @LastLoginDate DATETIME

      SELECT
          @UserId = NULL

      SELECT
          @UserId = u.UserId ,
          @IsLockedOut = m.IsLockedOut ,
          @Password = Password ,
          @PasswordFormat = PasswordFormat ,
          @PasswordSalt = PasswordSalt ,
          @FailedPasswordAttemptCount = FailedPasswordAttemptCount ,
          @FailedPasswordAnswerAttemptCount = FailedPasswordAnswerAttemptCount ,
          @IsApproved = IsApproved ,
          @LastActivityDate = LastActivityDate ,
          @LastLoginDate = LastLoginDate
      FROM
          dbo.aspnet_Applications a ,
          dbo.aspnet_Users u ,
          dbo.aspnet_Membership m
      WHERE
          LOWER(@ApplicationName) = a.LoweredApplicationName AND u.ApplicationId = a.ApplicationId AND u.UserId = m.UserId AND LOWER(@UserName) = u.LoweredUserName

      IF ( @UserId IS NULL )
         RETURN 1

      IF ( @IsLockedOut = 1 )
         RETURN 99

      SELECT
          @Password ,
          @PasswordFormat ,
          @PasswordSalt ,
          @FailedPasswordAttemptCount ,
          @FailedPasswordAnswerAttemptCount ,
          @IsApproved ,
          @LastLoginDate ,
          @LastActivityDate

      IF ( @UpdateLastLoginActivityDate = 1 AND @IsApproved = 1 )
         BEGIN
               UPDATE
                   dbo.aspnet_Membership
               SET
                   LastLoginDate = @CurrentTimeUtc
               WHERE
                   UserId = @UserId

               UPDATE
                   dbo.aspnet_Users
               SET
                   LastActivityDate = @CurrentTimeUtc
               WHERE
                   @UserId = UserId
         END


      RETURN 0
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Membership_GetPasswordWithFormat] TO [FE_rohit.r-ext]
    AS [dbo];

