﻿CREATE PROCEDURE [dbo].[aspnet_Membership_UpdateUser]
       @ApplicationName NVARCHAR(256) ,
       @UserName NVARCHAR(256) ,
       @Email NVARCHAR(256) ,
       @Comment NTEXT ,
       @IsApproved BIT ,
       @LastLoginDate DATETIME ,
       @LastActivityDate DATETIME ,
       @UniqueEmail INT ,
       @CurrentTimeUtc DATETIME
AS
BEGIN
      DECLARE @UserId UNIQUEIDENTIFIER
      DECLARE @ApplicationId UNIQUEIDENTIFIER
      SELECT
          @UserId = NULL
      SELECT
          @UserId = u.UserId ,
          @ApplicationId = a.ApplicationId
      FROM
          dbo.aspnet_Users u ,
          dbo.aspnet_Applications a ,
          dbo.aspnet_Membership m
      WHERE
          LoweredUserName = LOWER(@UserName) AND u.ApplicationId = a.ApplicationId AND LOWER(@ApplicationName) = a.LoweredApplicationName AND u.UserId = m.UserId

      IF ( @UserId IS NULL )
         RETURN ( 1 )

      IF ( @UniqueEmail = 1 )
         BEGIN
               IF ( EXISTS ( SELECT
                                 *
                             FROM
                                 dbo.aspnet_Membership WITH ( UPDLOCK , HOLDLOCK )
                             WHERE
                                 ApplicationId = @ApplicationId AND @UserId <> UserId AND LoweredEmail = LOWER(@Email) ) )
                  BEGIN
                        RETURN ( 7 )
                  END
         END

      DECLARE @TranStarted BIT
      SET @TranStarted = 0

      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @TranStarted = 1
         END
      ELSE
         SET @TranStarted = 0

      UPDATE
          dbo.aspnet_Users WITH ( ROWLOCK )
      SET
          LastActivityDate = @LastActivityDate
      WHERE
          @UserId = UserId

      IF ( @@ERROR <> 0 )
         GOTO Cleanup

      UPDATE
          dbo.aspnet_Membership WITH ( ROWLOCK )
      SET
          Email = @Email ,
          LoweredEmail = LOWER(@Email) ,
          Comment = @Comment ,
          IsApproved = @IsApproved ,
          LastLoginDate = @LastLoginDate
      WHERE
          @UserId = UserId

      IF ( @@ERROR <> 0 )
         GOTO Cleanup

      IF ( @TranStarted = 1 )
         BEGIN
               SET @TranStarted = 0
               COMMIT TRANSACTION
         END

      RETURN 0

      Cleanup:

      IF ( @TranStarted = 1 )
         BEGIN
               SET @TranStarted = 0
               ROLLBACK TRANSACTION
         END

      RETURN -1
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Membership_UpdateUser] TO [FE_rohit.r-ext]
    AS [dbo];

