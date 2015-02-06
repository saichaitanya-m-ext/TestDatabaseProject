CREATE PROCEDURE [dbo].[aspnet_Membership_GetNumberOfUsersOnline]
       @ApplicationName NVARCHAR(256) ,
       @MinutesSinceLastInActive INT ,
       @CurrentTimeUtc DATETIME
AS
BEGIN
      DECLARE @DateActive DATETIME
      SELECT
          @DateActive = DATEADD(minute , -( @MinutesSinceLastInActive ) , @CurrentTimeUtc)

      DECLARE @NumOnline INT
      SELECT
          @NumOnline = COUNT(*)
      FROM
          dbo.aspnet_Users u ( NOLOCK ) ,
          dbo.aspnet_Applications a ( NOLOCK ) ,
          dbo.aspnet_Membership m ( NOLOCK )
      WHERE
          u.ApplicationId = a.ApplicationId AND LastActivityDate > @DateActive AND a.LoweredApplicationName = LOWER(@ApplicationName) AND u.UserId = m.UserId
      RETURN ( @NumOnline )
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Membership_GetNumberOfUsersOnline] TO [FE_rohit.r-ext]
    AS [dbo];

