CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_FindUserStateSizeAndCount]
(
 @Path NVARCHAR(256) ,
 @ApplicationName NVARCHAR(256) )
AS
BEGIN
      DECLARE @ApplicationId UNIQUEIDENTIFIER
      EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName , @ApplicationId OUTPUT
      IF ( @ApplicationId IS NULL )
         SELECT
             0 ,
             0
      ELSE
         SELECT
             SUM(DATALENGTH(PerUser.PageSettings)) ,
             COUNT(*)
         FROM
             aspnet_PersonalizationPerUser PerUser ,
             aspnet_Paths Paths
         WHERE
             Paths.ApplicationId = @ApplicationId AND PerUser.PathId = Paths.PathId AND Paths.LoweredPath LIKE LOWER(@Path)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_PersonalizationAdministration_FindUserStateSizeAndCount] TO [FE_rohit.r-ext]
    AS [dbo];

