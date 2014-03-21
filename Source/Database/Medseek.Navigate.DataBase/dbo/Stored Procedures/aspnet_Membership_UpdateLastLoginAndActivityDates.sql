CREATE PROCEDURE [dbo].[aspnet_Membership_UpdateLastLoginAndActivityDates]
       @ApplicationName NVARCHAR(256) ,
       @UserName NVARCHAR(256) ,
       @TimeZoneAdjustment INT
AS
BEGIN
      DECLARE @UserId UNIQUEIDENTIFIER
      SELECT
          @UserId = NULL
      SELECT
          @UserId = u.UserId
      FROM
          dbo.aspnet_Membership m ,
          dbo.aspnet_Users u ,
          dbo.aspnet_Applications a
      WHERE
          LoweredUserName = LOWER(@UserName) AND u.ApplicationId = a.ApplicationId AND LOWER(@ApplicationName) = a.LoweredApplicationName AND u.UserId = m.UserId
      IF ( @UserId IS NULL )
         BEGIN
               RETURN
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

      DECLARE @DateTimeNowUTC DATETIME
      EXEC dbo.aspnet_GetUtcDate @TimeZoneAdjustment , @DateTimeNowUTC OUTPUT

      UPDATE
          dbo.aspnet_Membership
      SET
          LastLoginDate = @DateTimeNowUTC
      WHERE
          UserId = @UserId

      IF ( @@ERROR <> 0 )
         GOTO Cleanup

      UPDATE
          dbo.aspnet_Users
      SET
          LastActivityDate = @DateTimeNowUTC
      WHERE
          @UserId = UserId

      IF ( @@ERROR <> 0 )
         GOTO Cleanup

      IF ( @TranStarted = 1 )
         BEGIN
               SET @TranStarted = 0
               COMMIT TRANSACTION
         END

      RETURN

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
    ON OBJECT::[dbo].[aspnet_Membership_UpdateLastLoginAndActivityDates] TO [FE_rohit.r-ext]
    AS [dbo];

