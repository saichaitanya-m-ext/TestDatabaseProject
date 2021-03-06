﻿CREATE PROCEDURE [dbo].[aspnet_Membership_FindUsersByName]
       @ApplicationName NVARCHAR(256) ,
       @UserNameToMatch NVARCHAR(256) ,
       @PageIndex INT ,
       @PageSize INT
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
         RETURN 0

    -- Set the page bounds
      DECLARE @PageLowerBound INT
      DECLARE @PageUpperBound INT
      DECLARE @TotalRecords INT
      SET @PageLowerBound = @PageSize * @PageIndex
      SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table TO store the select results
      CREATE TABLE #PageIndexForUsers
      (
        IndexId INT IDENTITY(0,1)
                    NOT NULL ,
        UserId UNIQUEIDENTIFIER )

    -- Insert into our temp table
      INSERT INTO
          #PageIndexForUsers
          (
            UserId )
          SELECT
              u.UserId
          FROM
              dbo.aspnet_Users u ,
              dbo.aspnet_Membership m
          WHERE
              u.ApplicationId = @ApplicationId AND m.UserId = u.UserId AND u.LoweredUserName LIKE LOWER(@UserNameToMatch)
          ORDER BY
              u.UserName


      SELECT
          u.UserName ,
          m.Email ,
          m.PasswordQuestion ,
          m.Comment ,
          m.IsApproved ,
          m.CreateDate ,
          m.LastLoginDate ,
          u.LastActivityDate ,
          m.LastPasswordChangedDate ,
          u.UserId ,
          m.IsLockedOut ,
          m.LastLockoutDate
      FROM
          dbo.aspnet_Membership m ,
          dbo.aspnet_Users u ,
          #PageIndexForUsers p
      WHERE
          u.UserId = p.UserId AND u.UserId = m.UserId AND p.IndexId >= @PageLowerBound AND p.IndexId <= @PageUpperBound
      ORDER BY
          u.UserName

      SELECT
          @TotalRecords = COUNT(*)
      FROM
          #PageIndexForUsers
      RETURN @TotalRecords
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Membership_FindUsersByName] TO [FE_rohit.r-ext]
    AS [dbo];

