/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_Users_Select_ByUserLoginName]  'Barbara'      
Description   : This procedure is used for getting the userid and portal detail    
    By LoginName. There is no appuserid checking for this SP as it is    
    going to be called from the     
Created By    : Pramod     
Created Date  : 19-Feb-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
31-May-10 Pramod Modified the SP to remove portal, uidef and uidefroles join    
07-June-10 NagaBabu added the field Users.MemberNum AS MemberNumber to this SP    
08-Oct-2010 NagaBabu Added UserName field in select Statement     
15-Oct-2020 NagaBabu Added UserStatusCode field in Where clause     
15-Feb-2011 Rathnam added UserByskin column in the select statement    
01-Mar-2011 NagaBabu Added UPPER Funtionality to UserName and added UserNameSuffix,'. ',', ' to the UserName field     
28-Feb-2012 NagaBabu Added EmailIdPrimary field    
14-March-2013 Rathnam added joins with Patient & Provider tables concept    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Users_Select_ByUserLoginName]
(@v_userLoginName NVARCHAR(256))
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @IsUserGeneratedPasswordTEST BIT
	DECLARE @expirydate DATETIME
	DECLARE @i_UserID INT
		,@b_IsPatient BIT
		,@b_IsProvider BIT
		,@v_Rolename VARCHAR(50)
		,@v_Status VARCHAR(10)
		
	SELECT @i_UserID = UserId
		,@b_IsPatient = IsPatient
		,@b_IsProvider = IsProvider
	FROM Users WITH (NOLOCK)
	WHERE UserLoginName = @v_userLoginName
	SET @v_Rolename = (SELECT sr.RoleName 
							FROM Users u 
								INNER JOIN UserGroup ug 
									ON u.UserId = ug.UserID
								INNER JOIN UsersSecurityRoles usr
									ON usr.ProviderID = ug.ProviderID
								INNER  JOIN SecurityRole sr
									ON sr.SecurityRoleId = usr.SecurityRoleId
							WHERE u.UserLoginName =@v_userLoginName)
	SET @v_Status = ('''A'',''I''')

	SET @IsUserGeneratedPasswordTEST = (
			SELECT am.IsUserGeneratedPassword
			FROM aspnet_Membership am
			INNER JOIN aspnet_Users au
				ON am.UserId = au.UserId
			WHERE UserName = @v_userLoginName
			)
			
	SET @expirydate = (
			SELECT am.PasswordExpireDate
			FROM aspnet_Membership am
			INNER JOIN aspnet_Users au
				ON am.UserId = au.UserId
			WHERE UserName = @v_userLoginName
			)

	IF @b_IsPatient = 1
	BEGIN
		SELECT p.PatientID AS UserID
			,u.UserId AS UserLoginID
			,u.AgreedToTermsAndConditions
			,1 AS PortalId
			,CONVERT(BIT, 0) IsPatient
			,CONVERT(BIT, 0) IsPhysician
			,CONVERT(BIT, 1) IsProvider
			,p.Gender
			,p.MedicalRecordNumber AS MemberNumber
			,UPPER(COALESCE(ISNULL(p.LastName, '') + ', ' + ISNULL(p.FirstName, '') + '. ' + ISNULL(p.MiddleName, '') + ' ' + ISNULL(p.NameSuffix, ''), '')) AS UserName
			     
			,u.UserBySkin
			,p.PrimaryEmailAddress EmailIdPrimary
			,(
				CASE 
					WHEN @IsUserGeneratedPasswordTEST IS NULL
						THEN 1
					ELSE @IsUserGeneratedPasswordTEST
					END
				) AS IsUserGeneratedPassword
			,(
				CASE 
					WHEN @expirydate IS NULL
						THEN 1
					ELSE @expirydate
					END
				) AS Expirydate
				,@v_Rolename SecurityRole
		FROM Users u WITH (NOLOCK)
		INNER JOIN Patient p WITH (NOLOCK)
			ON u.UserId = p.UserID
				AND u.AccountStatusCode = p.AccountStatusCode
		WHERE p.AccountStatusCode = 'A'
			AND u.UserId = @i_UserID
	END
	ELSE
		IF @b_IsProvider = 1
		BEGIN
			SELECT pr.ProviderID AS UserID
				,u.UserId AS UserLoginID
				,u.AgreedToTermsAndConditions
				,1 AS PortalId
				,CONVERT(BIT, 0) IsPatient
				,CONVERT(BIT, 0) IsPhysician
				,CONVERT(BIT, 1) IsProvider
				,pr.Gender
				,NULL AS MemberNumber
				,CASE 
					WHEN pr.IsIndividual = 1
						THEN UPPER(COALESCE(ISNULL(pr.LastName, '') + ', ' + ISNULL(pr.FirstName, '') + '. ' + ISNULL(pr.MiddleName, '') + ' ' + ISNULL(pr.NameSuffix, ''), ''))
					WHEN pr.IsIndividual = 0
						THEN OrganizationName
					END AS UserName
				,u.UserBySkin
				,pr.PrimaryEmailAddress EmailIdPrimary
				,(
					CASE 
						WHEN @IsUserGeneratedPasswordTEST IS NULL
							THEN 1
						ELSE @IsUserGeneratedPasswordTEST
						END
					) AS IsUserGeneratedPassword
				,(
					CASE 
						WHEN @expirydate IS NULL
							THEN 1
						ELSE @expirydate
						END
					) AS Expirydate
					,@v_Rolename SecurityRole
			FROM Users u WITH (NOLOCK)
			INNER JOIN UserGroup ug WITH (NOLOCK)
				ON u.UserId = ug.UserID
			INNER JOIN Provider pr
				ON ug.ProviderID = pr.ProviderID
					--AND u.AccountStatusCode = pr.AccountStatusCode
			WHERE ((pr.AccountStatusCode  = 'A' AND @v_Rolename <> 'Insurance Group Provider') OR (@v_Rolename = 'Insurance Group Provider' AND pr.AccountStatusCode  IN ('A','I')))
				AND u.UserId = @i_UserID
		END
END TRY

--------------------------------------------------------       
BEGIN CATCH
	-- Handle exception      
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Users_Select_ByUserLoginName] TO [FE_rohit.r-ext]
    AS [dbo];

