CREATE PROCEDURE [dbo].[aspnet_Profile_DeleteProfiles]
       @ApplicationName NVARCHAR(256) ,
       @UserNames NVARCHAR(4000)
AS
BEGIN
      DECLARE @UserName NVARCHAR(256)
      DECLARE @CurrentPos INT
      DECLARE @NextPos INT
      DECLARE @NumDeleted INT
      DECLARE @DeletedUser INT
      DECLARE @TranStarted BIT
      DECLARE @ErrorCode INT

      SET @ErrorCode = 0
      SET @CurrentPos = 1
      SET @NumDeleted = 0
      SET @TranStarted = 0

      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @TranStarted = 1
         END
      ELSE
         SET @TranStarted = 0
      WHILE ( @CurrentPos <= LEN(@UserNames) )
            BEGIN
                  SELECT
                      @NextPos = CHARINDEX(N',' , @UserNames , @CurrentPos)
                  IF ( @NextPos = 0 OR @NextPos IS NULL )
                     SELECT
                         @NextPos = LEN(@UserNames) + 1

                  SELECT
                      @UserName = SUBSTRING(@UserNames , @CurrentPos , @NextPos - @CurrentPos)
                  SELECT
                      @CurrentPos = @NextPos + 1

                  IF ( LEN(@UserName) > 0 )
                     BEGIN
                           SELECT
                               @DeletedUser = 0
                           EXEC dbo.aspnet_Users_DeleteUser @ApplicationName , @UserName , 4 , @DeletedUser OUTPUT
                           IF ( @@ERROR <> 0 )
                              BEGIN
                                    SET @ErrorCode = -1
                                    GOTO Cleanup
                              END
                           IF ( @DeletedUser <> 0 )
                              SELECT
                                  @NumDeleted = @NumDeleted + 1
                     END
            END
      SELECT
          @NumDeleted
      IF ( @TranStarted = 1 )
         BEGIN
               SET @TranStarted = 0
               COMMIT TRANSACTION
         END
      SET @TranStarted = 0

      RETURN 0

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
    ON OBJECT::[dbo].[aspnet_Profile_DeleteProfiles] TO [FE_rohit.r-ext]
    AS [dbo];

