CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_DeleteAllState]
(
 @AllUsersScope BIT ,
 @ApplicationName NVARCHAR(256) ,
 @Count INT OUT )
AS
BEGIN
      DECLARE @ApplicationId UNIQUEIDENTIFIER
      EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName , @ApplicationId OUTPUT
      IF ( @ApplicationId IS NULL )
         SELECT
             @Count = 0
      ELSE
         BEGIN
               IF ( @AllUsersScope = 1 )
                  DELETE  FROM
                          aspnet_PersonalizationAllUsers
                  WHERE
                          PathId IN ( SELECT
                                          Paths.PathId
                                      FROM
                                          dbo.aspnet_Paths Paths
                                      WHERE
                                          Paths.ApplicationId = @ApplicationId )
               ELSE
                  DELETE  FROM
                          aspnet_PersonalizationPerUser
                  WHERE
                          PathId IN ( SELECT
                                          Paths.PathId
                                      FROM
                                          dbo.aspnet_Paths Paths
                                      WHERE
                                          Paths.ApplicationId = @ApplicationId )

               SELECT
                   @Count = @@ROWCOUNT
         END
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_PersonalizationAdministration_DeleteAllState] TO [FE_rohit.r-ext]
    AS [dbo];

