--sp_helptext aspnet_Membership_GetUserByName
--sp_helptext aspnet_Membership_SetPassword
--sp_helptext aspnet_Membership_ResetPassword

CREATE PROCEDURE [dbo].[aspnet_Membership_ResetPassword]  
       @ApplicationName NVARCHAR(256) ,  
       @UserName NVARCHAR(256) ,  
       @NewPassword NVARCHAR(128) ,  
       @MaxInvalidPasswordAttempts INT ,  
       @PasswordAttemptWindow INT ,  
       @PasswordSalt NVARCHAR(128) ,  
       @CurrentTimeUtc DATETIME ,  
       @PasswordFormat INT = 0 ,  
       @PasswordAnswer NVARCHAR(128) = NULL  
AS  
BEGIN  
      DECLARE @IsLockedOut BIT  
      DECLARE @LastLockoutDate DATETIME  
      DECLARE @FailedPasswordAttemptCount INT  
      DECLARE @FailedPasswordAttemptWindowStart DATETIME  
      DECLARE @FailedPasswordAnswerAttemptCount INT  
      DECLARE @FailedPasswordAnswerAttemptWindowStart DATETIME  
  
      DECLARE @UserId UNIQUEIDENTIFIER  
      SET @UserId = NULL  
  
      DECLARE @ErrorCode INT  
      SET @ErrorCode = 0  
  
      DECLARE @TranStarted BIT  
      SET @TranStarted = 0  
  
      IF ( @@TRANCOUNT = 0 )  
         BEGIN  
               BEGIN TRANSACTION  
               SET @TranStarted = 1  
         END  
      ELSE  
         SET @TranStarted = 0  
  
      SELECT  
          @UserId = u.UserId  
      FROM  
          dbo.aspnet_Users u ,  
          dbo.aspnet_Applications a ,  
          dbo.aspnet_Membership m  
      WHERE  
          LoweredUserName = LOWER(@UserName) AND u.ApplicationId = a.ApplicationId AND LOWER(@ApplicationName) = a.LoweredApplicationName AND u.UserId = m.UserId  
  
      IF ( @UserId IS NULL )  
         BEGIN  
               SET @ErrorCode = 1  
               GOTO Cleanup  
         END  
  
      SELECT  
          @IsLockedOut = IsLockedOut ,  
          @LastLockoutDate = LastLockoutDate ,  
          @FailedPasswordAttemptCount = FailedPasswordAttemptCount ,  
          @FailedPasswordAttemptWindowStart = FailedPasswordAttemptWindowStart ,  
          @FailedPasswordAnswerAttemptCount = FailedPasswordAnswerAttemptCount ,  
          @FailedPasswordAnswerAttemptWindowStart = FailedPasswordAnswerAttemptWindowStart  
      FROM  
          dbo.aspnet_Membership WITH ( UPDLOCK )  
      WHERE  
          @UserId = UserId  
  
      IF ( @IsLockedOut = 1 )  
         BEGIN  
               SET @ErrorCode = 99  
               GOTO Cleanup  
         END  
  
      UPDATE  
          dbo.aspnet_Membership  
      SET  
          Password = @NewPassword ,  
          LastPasswordChangedDate = @CurrentTimeUtc ,  
          PasswordFormat = @PasswordFormat ,  
          PasswordSalt = @PasswordSalt ,
          IsUserGeneratedPassword = 0
           
      WHERE  
          @UserId = UserId AND ( ( @PasswordAnswer IS NULL ) OR ( LOWER(PasswordAnswer) = LOWER(@PasswordAnswer) ) )  
  
      IF ( @@ROWCOUNT = 0 )  
         BEGIN  
               IF ( @CurrentTimeUtc > DATEADD(minute , @PasswordAttemptWindow , @FailedPasswordAnswerAttemptWindowStart) )  
                  BEGIN  
                        SET @FailedPasswordAnswerAttemptWindowStart = @CurrentTimeUtc  
                        SET @FailedPasswordAnswerAttemptCount = 1  
                  END  
               ELSE  
                  BEGIN  
                        SET @FailedPasswordAnswerAttemptWindowStart = @CurrentTimeUtc  
                        SET @FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount + 1  
                  END  
  
               BEGIN  
                     IF ( @FailedPasswordAnswerAttemptCount >= @MaxInvalidPasswordAttempts )  
                        BEGIN  
                              SET @IsLockedOut = 1  
                              SET @LastLockoutDate = @CurrentTimeUtc  
                        END  
               END  
  
               SET @ErrorCode = 3  
         END  
      ELSE  
         BEGIN  
               IF ( @FailedPasswordAnswerAttemptCount > 0 )  
                  BEGIN  
                        SET @FailedPasswordAnswerAttemptCount = 0  
                        SET @FailedPasswordAnswerAttemptWindowStart = CONVERT(DATETIME , '17540101' , 112)  
                  END  
         END  
  
      IF ( NOT ( @PasswordAnswer IS NULL ) )  
         BEGIN  
               UPDATE  
  dbo.aspnet_Membership  
               SET  
                   IsLockedOut = @IsLockedOut ,  
                   LastLockoutDate = @LastLockoutDate ,  
                   FailedPasswordAttemptCount = @FailedPasswordAttemptCount ,  
                   FailedPasswordAttemptWindowStart = @FailedPasswordAttemptWindowStart ,  
                   FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount ,  
                   FailedPasswordAnswerAttemptWindowStart = @FailedPasswordAnswerAttemptWindowStart  
               WHERE  
                   @UserId = UserId  
  
               IF ( @@ERROR <> 0 )  
                  BEGIN  
                        SET @ErrorCode = -1  
                        GOTO Cleanup  
                  END  
         END  
  
      IF ( @TranStarted = 1 )  
         BEGIN  
               SET @TranStarted = 0  
               COMMIT TRANSACTION  
         END  
  
      RETURN @ErrorCode  
  
      Cleanup:  
  
      IF ( @TranStarted = 1 )  
         BEGIN  
               SET @TranStarted = 0  
               ROLLBACK TRANSACTION  
         END  
  
      RETURN @ErrorCode  
  
END  

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Membership_ResetPassword] TO [FE_rohit.r-ext]
    AS [dbo];

