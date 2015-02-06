
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_ProviderName_Search]  1,'car',null
Description   : This procedure is used Search Provider Names Records
Created By    : Prathusha for inline search in UserActivityLog report
Created Date  : 04-Nov-2013  
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_ProviderName_Search] (
	@i_AppUserId INT
	, @vc_UserFirstorLastName VARCHAR(50)
	, @i_SecurityRoleID INT = NULL
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		-- Check if valid Application User ID is passed                    
		IF (@i_AppUserId IS NULL)
			OR (@i_AppUserId <= 0)
		BEGIN
			RAISERROR (
					N'Invalid Application User ID %d passed.'
					, 17
					, 1
					, @i_AppUserId
					)
		END

		SELECT DISTINCT ug.UserID As ProviderID
			, ISNULL(p.LastName, '') + ', ' + ISNULL(p.FirstName, '') AS FullName
		FROM Provider p WITH (NOLOCK)
		INNER JOIN UserGroup ug
			ON ug.ProviderID = p.ProviderID
		--INNER JOIN Users u
		--	ON u.UserId = ug.UserID
		INNER JOIN UsersSecurityRoles USR
			ON USR.ProviderID = P.ProviderID		
		WHERE (
				(p.FirstName LIKE @vc_UserFirstorLastName + '%')
				OR (p.LastName LIKE @vc_UserFirstorLastName + '%')
				)
			AND P.AccountStatusCode = 'A'
			AND (
				USR.SecurityRoleId = @i_SecurityRoleID
				OR @i_SecurityRoleID IS NULL
				OR @i_SecurityRoleID = 0
				)
		ORDER BY ug.UserID ASC
	END TRY

	--------------------------------------------------------     
	BEGIN CATCH
		-- Handle exception    
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ProviderName_Search] TO [FE_rohit.r-ext]
    AS [dbo];

