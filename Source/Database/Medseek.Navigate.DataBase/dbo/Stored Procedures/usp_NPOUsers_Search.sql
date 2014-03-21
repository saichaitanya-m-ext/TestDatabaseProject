
/*    
----------------------------------------------------------------------------------    
Procedure Name: [usp_NPOUsers_Search]  23,1,50
Description   : This procedure is used to select Users based on the search criteria    
Created By    : Balla Kalyan    
Created Date  : 16-Jan-2010    
----------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
					
----------------------------------------------------------------------------------    
exec [usp_Users_Search ]@i_AppUserId=2,@b_IsPatient=0,@v_PreferedName='H'  @v_State='Ap',@i_StartIndex=0,@i_EndIndex=500
*/

CREATE PROCEDURE [dbo].[usp_NPOUsers_Search] 
	
	(	@i_AppUserId KEYID
	,@b_IsPatient BIT = 1
	,@i_UserID INT = NULL
	,@i_StartIndex INT = 1
	,@i_EndIndex INT = 500
	,@v_UserLoginName VARCHAR(256) = NULL
	,@v_LastName LASTNAME = NULL
	,@v_PreferedName LASTNAME = NULL
	,@v_City VARCHAR(50) = NULL
	,@v_State VARCHAR(50) = NULL
	,@v_ZipCode VARCHAR(10) = NULL
	,@v_MemberNum SOURCENAME = NULL
	,@v_UserStatusCode STATUSCODE = NULL
	,@v_FirstName FIRSTNAME = NULL
	,@v_PhoneNumberPrimary PHONE = NULL
	,@v_EmailIdPrimary EMAILID = NULL
	,@v_SSNNo SSN = NULL
	,@vc_Gender UNIT = NULL
	,@i_OperatorValue1 SOURCENAME = NULL
	,@i_AgeFrom1 INT = NULL
	,@i_AgeTo1 INT = NULL
	,@i_OperatorValue2 SOURCENAME = NULL
	,@i_AgeFrom2 INT = NULL
	,@i_AgeTo2 INT = NULL
	,@v_SecurityRoleName VARCHAR(50)
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	----- Check if valid Application User ID is passed--------------    
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

	--------- search user from the search criteria ----------------   
	CREATE TABLE #User (
		ID INT IDENTITY(1, 1)
		,UserID INT
		,SecurityName VARCHAR(50)
		)

	CREATE TABLE #UserCnt (Cnt INT)

	IF @b_IsPatient = 1
	BEGIN
		DECLARE @v_PatientSQL NVARCHAR(4000)
			,@v_PatientJoinClause VARCHAR(4000) = ''
			,@v_WhereClause VARCHAR(MAX) = ' WHERE 1=1 '
			,@v_CntSql VARCHAR(MAX) = ''

		IF @v_SecurityRoleName IN (
				'Physician'
				,'Administrator'
				)
		BEGIN
			SET @v_CntSql = 'INSERT INTO #UserCnt
											SELECT COUNT(Patients.PatientID)  FROM Patients WITH(NOLOCK) '
			SET @v_PatientSQL = 'INSERT INTO #User
											SELECT TOP ( ' + CONVERT(VARCHAR(10), @i_EndIndex) + ') Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) '

			IF @v_SecurityRoleName = 'Physician'
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And PCPID = ' + CONVERT(VARCHAR(10), @i_AppUserId)
			END
		END
		ELSE
			IF @v_SecurityRoleName = 'Clinic Administrator'
			BEGIN
				SET @v_CntSql = 'INSERT INTO #UserCnt
											SELECT COUNT(DISTINCT Patients.PatientID)  FROM Patients WITH(NOLOCK) 
											INNER JOIN ProviderHierarchyDetail phd
													ON Patients.PCPID = phd.childproviderid
											'
				SET @v_PatientSQL = 'INSERT INTO #User
											SELECT DISTINCT TOP ( ' + CONVERT(VARCHAR(10), @i_EndIndex) + ') Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) 
											INNER JOIN ProviderHierarchyDetail phd
													ON Patients.PCPID = phd.childproviderid
											'
				SET @v_WhereClause = @v_WhereClause + 'And phd.parentproviderid = ' + CONVERT(VARCHAR(10), @i_AppUserId)
			END
			ELSE
				IF @v_SecurityRoleName = 'Insurance Group Provider'
				BEGIN
					SET @v_CntSql = 'INSERT INTO #UserCnt
											SELECT COUNT(DISTINCT Patients.PatientID)  FROM Patients WITH(NOLOCK) 
											INNER JOIN PatientInsurance i WITH (NOLOCK)
														ON Patients.PatientID = i.PatientID
													INNER JOIN InsuranceGroupPlan igp WITH (NOLOCK)
														ON igp.InsuranceGroupPlanId = i.InsuranceGroupPlanId
													INNER JOIN Provider pr
														ON pr.InsuranceGroupID = igp.InsuranceGroupId
											'
					SET @v_PatientSQL = 'INSERT INTO #User
											SELECT DISTINCT TOP ( ' + CONVERT(VARCHAR(10), @i_EndIndex) + ') Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) 
											INNER JOIN PatientInsurance i WITH (NOLOCK)
														ON Patients.PatientID = i.PatientID
													INNER JOIN InsuranceGroupPlan igp WITH (NOLOCK)
														ON igp.InsuranceGroupPlanId = i.InsuranceGroupPlanId
													INNER JOIN Provider pr
														ON pr.InsuranceGroupID = igp.InsuranceGroupId
											'
					SET @v_WhereClause = @v_WhereClause + 'And pr.ProviderID = ' + CONVERT(VARCHAR(10), @i_AppUserId)
				END
				ELSE
					IF @v_SecurityRoleName IN (
							'Care Manager'
							,'Care Team Member'
							)
					BEGIN
						SET @v_CntSql = 'INSERT INTO #UserCnt
											SELECT COUNT(DISTINCT Patients.PatientID)  FROM Patients WITH(NOLOCK) 
											INNER JOIN PatientProgram pp WITH ( NOLOCK )
											   ON Patients.PatientID = pp.PatientID
										   INNER JOIN ProgramCareTeam ppc WITH ( NOLOCK )
											   ON ppc.ProgramID = pp.ProgramID
										   INNER JOIN CareTeamMembers ctm WITH ( NOLOCK )
											   ON ctm.CareTeamID = ppc.CareTeamID
											   AND pp.StatusCode = ''A''
												AND ctm.StatusCode = ''A''
											'
						SET @v_PatientSQL = 'INSERT INTO #User
											SELECT DISTINCT TOP ( ' + CONVERT(VARCHAR(10), @i_EndIndex) + ') Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) 
											INNER JOIN PatientProgram pp WITH ( NOLOCK )
											   ON Patients.PatientID = pp.PatientID
										   INNER JOIN ProgramCareTeam ppc WITH ( NOLOCK )
											   ON ppc.ProgramID = pp.ProgramID
										   INNER JOIN CareTeamMembers ctm WITH ( NOLOCK )
											   ON ctm.CareTeamID = ppc.CareTeamID
											   AND pp.StatusCode = ''A''
												AND ctm.StatusCode = ''A''
											'

						
						IF @v_SecurityRoleName = 'Care Manager'
							SET @v_WhereClause = @v_WhereClause + ' And ctm.ProviderID = ' + CONVERT(VARCHAR(10), @i_AppUserId)
						ELSE
							SET @v_WhereClause = @v_WhereClause + ' AND ctm.ProviderID = pp.ProviderID 
								And ctm.ProviderID = ' + CONVERT(VARCHAR(10), @i_AppUserId)
					END

		IF @i_UserID IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And PatientID = ' + CONVERT(VARCHAR(10), @i_UserID)
		END

		IF @v_LastName IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And LastName LIKE ' + '''%' + @v_LastName + '%'''
		END

		IF @v_PreferedName IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And PreferredName LIKE ' + '''%' + @v_PreferedName + '%'''
		END

		IF @v_FirstName IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And FirstName LIKE ' + '''%' + @v_FirstName + '%'''
		END

		IF @v_City IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And City LIKE ' + '''%' + @v_City + '%'''
		END

		IF @v_SSNNo IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And SSN = ' + '''' + @v_SSNNo + ''''
		END

		IF @v_State IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And StateCode LIKE ' + '''%' + @v_State + '%'''
		END

		IF @v_EmailIdPrimary IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And PrimaryEmailAddress = ' + '''' + @v_EmailIdPrimary + ''''
		END

		IF @v_PhoneNumberPrimary IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And PrimaryPhoneNumber = ' + '''' + @v_PhoneNumberPrimary + ''''
		END

		IF @v_ZipCode IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And ZipCode = ' + '''' + @v_ZipCode + ''''
		END

		IF @v_MemberNum IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And MemberNum = ' + '''' + @v_MemberNum + ''''
		END

		IF @v_UserStatusCode IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'And UserStatuscode = ' + '''' + @v_UserStatusCode + ''''
		END

		IF @vc_Gender IS NOT NULL
		BEGIN
			SET @v_WhereClause = @v_WhereClause + 'AND Gender = ' + '''' + @vc_Gender + ''''
		END

		IF @v_UserLoginName IS NOT NULL
		BEGIN
			SET @v_PatientJoinClause = ' Inner Join Users ON Users.UserID = Patients.Userid'
			SET @v_WhereClause = @v_WhereClause + 'AND UserLoginName  LIKE ' + '''%' + @v_UserLoginName + '%'''
		END

		IF @i_OperatorValue1 IS NOT NULL
		BEGIN
			IF @i_OperatorValue1 = 'BETWEEN'
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'AND Age ' + @i_OperatorValue1 + ' ' + CAST(@i_AgeFrom1 AS VARCHAR(4)) + ' AND ' + CAST(@i_AgeTo1 AS VARCHAR(4))
			END
			ELSE
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'AND Age ' + @i_OperatorValue1 + ' ' + CAST(@i_AgeFrom1 AS VARCHAR(4))
			END
		END

		IF @i_OperatorValue2 IS NOT NULL
		BEGIN
			IF @i_OperatorValue2 = 'BETWEEN'
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'AND Age ' + @i_OperatorValue2 + ' ' + CAST(@i_AgeFrom2 AS VARCHAR(4)) + ' AND ' + CAST(@i_AgeTo2 AS VARCHAR(4))
			END
			ELSE
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'AND Age ' + @i_OperatorValue2 + ' ' + CAST(@i_AgeFrom2 AS VARCHAR(4))
			END
		END

		PRINT @v_PatientSQL + @v_PatientJoinClause + @v_WhereClause + ' Order By 1'

		EXEC (@v_PatientSQL + @v_PatientJoinClause + @v_WhereClause + ' Order By 1')

		EXEC (@v_CntSql + @v_PatientJoinClause + @v_WhereClause)

		SELECT PatientId UserID
			,us.UserLoginName AS UserLoginName
			,FirstName
			,LastName
			,Gender
			,DateOfBirth
			,MemberNum AS MemberNum
			,PrimaryEmailAddress EmailIdPrimary
			,PrimaryPhoneNumber
			,PrimaryPhoneNumberExtension
			,AddressLine1
			,AddressLine2
			,City
			,ZipCode
			,UserStatuscode UserStatus
			,dbo.udf_TitleCase(FullName) AS FullName
			,@b_IsPatient IsPatient
			,LkUpAccountStatus.AccountStatusName Description
			,u.SecurityName
		FROM Patients WITH (NOLOCK)
		INNER JOIN #User u
			ON Patients.PatientID = u.UserID
		INNER JOIN LkUpAccountStatus WITH (NOLOCK)
			ON LkUpAccountStatus.AccountStatusCode = Patients.UserStatuscode
		LEFT OUTER JOIN Users us
			ON us.UserId = Patients.UserID
		WHERE ID BETWEEN @i_StartIndex
				AND @i_EndIndex

		SELECT Cnt
		FROM #UserCnt
	END
	ELSE
	BEGIN
		INSERT INTO #User
		SELECT DISTINCT TOP (@i_EndIndex) p.ProviderID
			,s.RoleName
		FROM Provider p WITH (NOLOCK)
		INNER JOIN UserGroup ug WITH (NOLOCK)
			ON p.ProviderID = ug.ProviderID
		INNER JOIN UsersSecurityRoles uss
			ON uss.ProviderID = p.ProviderID
		INNER JOIN SecurityRole s
			ON s.SecurityRoleId = uss.SecurityRoleId
		LEFT OUTER JOIN CodeSetProviderType cpt WITH (NOLOCK)
			ON cpt.ProviderTypeCodeID = p.ProviderTypeID
		LEFT OUTER JOIN Users u
			ON u.UserId = ug.UserID
		LEFT OUTER JOIN CodeSetState css
		    ON css.StateID = p.PrimaryAddressStateCodeId
		WHERE s.RoleName IN (
				'Care Team Member'
				,'Care Manager'
				,'Physician'
				,'Insurance Group Provider'
				,'Clinic Administrator'
				,'Administrator'
				)
			AND p.ProviderTypeID IS NOT NULL
			AND (
				p.ProviderID = @i_UserID
				OR @i_UserID IS NULL
				)
			AND (
				LastName = @v_LastName
				OR @v_LastName IS NULL
				)
			AND (
				FirstName = @v_FirstName
				OR @v_FirstName IS NULL
				)
			AND (
				PrimaryAddressCity = @v_City
				OR @v_City IS NULL
				)
			AND (
				PrimaryEmailAddress = @v_EmailIdPrimary
				OR @v_EmailIdPrimary IS NULL
				)
			AND (
				PrimaryPhoneNumber = @v_PhoneNumberPrimary
				OR @v_PhoneNumberPrimary IS NULL
				)
			AND (
				Gender = @vc_Gender
				OR @vc_Gender IS NULL
				)
			AND (
				NPINumber = @v_SSNNo
				OR @v_SSNNo IS NULL
				)
			AND (
				PrimaryAddressCity = @v_City
				OR @v_City IS NULL
				)
			AND (
				css.StateName = @v_State
				OR @v_State IS NULL
				)
			AND (
				PrimaryAddressPostalCode = @v_ZipCode
				OR @v_ZipCode IS NULL
				)
			AND (
				p.AccountStatusCode = @v_UserStatusCode
				OR @v_UserStatusCode IS NULL
				)
			AND (
				u.UserLoginName LIKE + '%' + @v_UserLoginName + '%'
				OR @v_UserLoginName IS NULL
				)
		ORDER BY 1

		SELECT p.ProviderID UserID
			,dbo.udf_TitleCase(Users.UserLoginName) AS UserLoginName
			,FirstName
			,LastName
			,Gender
			,'' DateOfBirth
			,'' AS MemberNum
			,PrimaryEmailAddress EmailIdPrimary
			,PrimaryPhoneNumber
			,PrimaryPhoneNumberExtension
			,PrimaryAddressLine1 AddressLine1
			,PrimaryAddressLine2 AddressLine2
			,PrimaryAddressCity City
			,PrimaryAddressPostalCode ZipCode
			,p.AccountStatusCode UserStatus
			,dbo.udf_TitleCase(COALESCE(ISNULL(p.LastName, '') + ', ' + ISNULL(p.FirstName, '') + '. ' + ISNULL(p.MiddleName, '') + ' ' + ISNULL(p.NameSuffix, ''), '')) AS FullName
			,@b_IsPatient IsPatient
			,LkUpAccountStatus.AccountStatusName Description
			,u.SecurityName
		FROM Provider p WITH (NOLOCK)
		INNER JOIN #User u
			ON p.ProviderID = u.UserID
		INNER JOIN LkUpAccountStatus WITH (NOLOCK)
			ON LkUpAccountStatus.AccountStatusCode = p.AccountStatusCode
		INNER JOIN Users WITH (NOLOCK)
			ON Users.UserId = p.UserID
		WHERE (
				ID BETWEEN @i_StartIndex
					AND @i_EndIndex
				)

		SELECT COUNT(DISTINCT P.ProviderID) Cnt
		FROM Provider p WITH (NOLOCK)
		INNER JOIN Users u WITH (NOLOCK)
			ON p.UserID = u.UserId
		INNER JOIN UsersSecurityRoles uss
			ON uss.ProviderID = p.ProviderID
		INNER JOIN SecurityRole s
			ON s.SecurityRoleId = uss.SecurityRoleId
		LEFT OUTER JOIN CodeSetProviderType cpt WITH (NOLOCK)
			ON cpt.ProviderTypeCodeID = p.ProviderTypeID
		LEFT OUTER JOIN CodeSetState css
		    ON css.StateID = p.PrimaryAddressStateCodeId	
		WHERE s.RoleName IN (
				'Care Team Member'
				,'Care Manager'
				,'Physician'
				,'Insurance Group Provider'
				,'Clinic Administrator'
				,'Administrator'
				)
			AND p.ProviderTypeID IS NOT NULL
			AND (
				P.ProviderID = @i_UserID
				OR @i_UserID IS NULL
				)
			AND (
				LastName = @v_LastName
				OR @v_LastName IS NULL
				)
			AND (
				FirstName = @v_FirstName
				OR @v_FirstName IS NULL
				)
			AND (
				PrimaryAddressCity = @v_City
				OR @v_City IS NULL
				)
			AND (
				PrimaryEmailAddress = @v_EmailIdPrimary
				OR @v_EmailIdPrimary IS NULL
				)
			AND (
				PrimaryPhoneNumber = @v_PhoneNumberPrimary
				OR @v_PhoneNumberPrimary IS NULL
				)
			AND (
				Gender = @vc_Gender
				OR @vc_Gender IS NULL
				)
			AND (
				NPINumber = @v_SSNNo
				OR @v_SSNNo IS NULL
				)
			AND (
				PrimaryAddressCity = @v_City
				OR @v_City IS NULL
				)
			AND (
				css.StateName = @v_State
				OR @v_State IS NULL
				)
			AND (
				PrimaryAddressPostalCode = @v_ZipCode
				OR @v_ZipCode IS NULL
				)
			AND (
				p.AccountStatusCode = @v_UserStatusCode
				OR @v_UserStatusCode IS NULL
				)
			AND (
				u.UserLoginName LIKE + '%' + @v_UserLoginName + '%'
				OR @v_UserLoginName IS NULL
				)
	END
END TRY

--------------------------------------------------------     
BEGIN CATCH
	-- Handle exception    
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_NPOUsers_Search] TO [FE_rohit.r-ext]
    AS [dbo];

