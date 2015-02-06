CREATE PROCEDURE [dbo].[aspnet_GetUtcDate]
       @TimeZoneAdjustment INT ,
       @DateNow DATETIME OUTPUT
AS
BEGIN
      SELECT
          @DateNow = GETUTCDATE()
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_GetUtcDate] TO [FE_rohit.r-ext]
    AS [dbo];

