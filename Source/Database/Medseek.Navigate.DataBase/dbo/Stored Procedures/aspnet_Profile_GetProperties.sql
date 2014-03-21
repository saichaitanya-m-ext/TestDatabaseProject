CREATE PROCEDURE [dbo].[aspnet_Profile_GetProperties]
       @ApplicationName NVARCHAR(256) ,
       @UserName NVARCHAR(256) ,
       @CurrentTimeUtc DATETIME
AS
BEGIN
      DECLARE @ApplicationId UNIQUEIDENTIFIER
      SELECT
          @ApplicationId = NULL
      SELECT
          @ApplicationId = ApplicationId
      FROM
          dbo.aspnet_Applications
      WHERE
          LOWER(@ApplicationName) = LoweredApplicationName
      IF ( @ApplicationId IS NULL )
         RETURN

      DECLARE @UserId UNIQUEIDENTIFIER
      SELECT
          @UserId = NULL

      SELECT
          @UserId = UserId
      FROM
          dbo.aspnet_Users
      WHERE
          ApplicationId = @ApplicationId AND LoweredUserName = LOWER(@UserName)

      IF ( @UserId IS NULL )
         RETURN SELECT TOP 1
                    PropertyNames ,
                    PropertyValuesString ,
                    PropertyValuesBinary
                FROM
                    dbo.aspnet_Profile
                WHERE
                    UserId = @UserId

      IF ( @@ROWCOUNT > 0 )
         BEGIN
               UPDATE
                   dbo.aspnet_Users
               SET
                   LastActivityDate = @CurrentTimeUtc
               WHERE
                   UserId = @UserId
         END
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Profile_GetProperties] TO [FE_rohit.r-ext]
    AS [dbo];

