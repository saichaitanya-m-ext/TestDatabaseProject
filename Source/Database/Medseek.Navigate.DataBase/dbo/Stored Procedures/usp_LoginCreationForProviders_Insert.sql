
/*
----------------------------------------------------------------------------------
Procedure Name: [usp_LoginCreationForProviders_Insert]
Description   : This proc is used to create the logins for the providers or clinics where the
data coming from the files shared by client
Created By    :	Rathnam
Created Date  : 25-a-2013
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
----------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_LoginCreationForProviders_Insert] 
     @i_AppUserId KEYID
	,@i_UserID KEYID
	,@i_ProviderID KEYID = NULL
	,@i_SecurityRoleID KEYID = NULL
	,@v_EmailAddress VARCHAR(500)
	--,@i_InsuranceGroupID KEYID = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @i_numberOfRecordsUpdated INT

	-- Check if valid Application User ID is passed
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.'
				,17
				,1
				,@i_AppUserId
				)
	END

	BEGIN TRANSACTION

	IF NOT EXISTS (
			SELECT 1
			FROM UserGroup u
			WHERE ProviderID = @i_ProviderID
				AND UserID = @i_UserID
			)
	BEGIN
		INSERT INTO  UserGroup (
			ProviderID
			,UserID
			,CreatedByUserID
			,CreatedDate
			)
		VALUES (
			@i_ProviderID
			,@i_UserID
			,@i_AppUserId
			,getdate()
			)

		UPDATE Users
		SET IsProvider = 1
		WHERE UserId = @i_UserID
	END

	DECLARE @v_RoleName VARCHAR(150)

	SELECT @v_RoleName = RoleName
	FROM SecurityRole
	WHERE SecurityRoleId = @i_SecurityRoleID

	DECLARE @i_ASPUserId UNIQUEIDENTIFIER
		,@i_ASPRoleID UNIQUEIDENTIFIER

	SELECT @i_ASPUserId = a.UserId
	FROM Users U
	INNER JOIN aspnet_Users a
		ON u.UserLoginName = a.UserName
	WHERE U.UserId = @i_UserID

	SELECT @i_ASPRoleID = RoleId
	FROM aspnet_Roles
	WHERE RoleName = @v_RoleName

	INSERT INTO dbo.aspnet_UsersInRoles (
		UserId
		,RoleId
		)
	VALUES (
		@i_ASPUserId
		,@i_ASPRoleID
		)

	IF NOT EXISTS (
			SELECT 1
			FROM UsersSecurityRoles
			WHERE (ProviderID = @i_ProviderID)
			)
	BEGIN
		INSERT INTO UsersSecurityRoles (
			SecurityRoleId
			,ProviderID
			,CreatedByUserId
			,CreatedDate
			)
		SELECT @i_SecurityRoleID
			,@i_ProviderID
			,@i_AppUserId
			,GETDATE()
	END

	COMMIT TRANSACTION
END TRY

-------------------------------------------------------- 
BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LoginCreationForProviders_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

