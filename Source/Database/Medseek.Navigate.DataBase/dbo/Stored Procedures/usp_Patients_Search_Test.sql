


/*      
----------------------------------------------------------------------------------      
Procedure Name: [usp_Patients_Search]  83,@v_SecurityRoleName = 'Care Manager',@i_ProviderID = 83,@i_HealthPlanID = 1,@i_ProductID = 1,@v_LastName = 'Stephen'  
Description   : This procedure is used to select Users based on the search criteria      
Created By    : Santosh      
Created Date  : 24-Jul-2013  
----------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
08/06/2013:Santosh added the index   IX_#User on #User  
08/07/2013:Santosh added columns age and pcpname
05-Nov-2013 Rathnam As per bugid 2989 we have modified the join conditions from patients.pcp to patientpcp.pcp
----------------------------------------------------------------------------------      
exec [usp_Patients_Search ]@i_AppUserId=2,@b_IsPatient=0,@v_PreferedName='H'  @v_State='Ap',@i_StartIndex=0,@i_EndIndex=500  
		*/
CREATE PROCEDURE [dbo].[usp_Patients_Search_Test] @i_AppUserId KEYID
	,@i_UserID INT = NULL
	,@i_StartIndex INT = 1
	,@i_EndIndex INT = 500
	,@v_LastName LASTNAME = NULL
	,@v_City VARCHAR(50) = NULL
	,@v_State VARCHAR(50) = NULL
	,@v_ZipCode VARCHAR(10) = NULL
	,@v_MemberNum SOURCENAME = NULL
	,@v_FirstName FIRSTNAME = NULL
	,@v_PhoneNumberPrimary PHONE = NULL
	,@v_EmailIdPrimary EMAILID = NULL
	,@vc_Gender UNIT = NULL
	,@v_UserStatusCode CHAR(167) = NULL
	,@i_ProviderID KeyID = NULL
	,@i_ChildProviderID KeyID = NULL
	,@i_HealthPlanID KeyID = NULL
	,@i_ProductID KeyID = NULL
	,@i_OperatorValue1 SOURCENAME = NULL
	,@i_AgeFrom1 INT = NULL
	,@i_AgeTo1 INT = NULL
	,@i_OperatorValue2 SOURCENAME = NULL
	,@i_AgeFrom2 INT = NULL
	,@i_AgeTo2 INT = NULL
	,@v_SecurityRoleName VARCHAR(50)
AS
BEGIN
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

		CREATE NONCLUSTERED INDEX [IX_#User.UserId] ON #User (UserId)

		CREATE TABLE #UserCnt (Cnt INT)

		BEGIN
			DECLARE @v_PatientSQL NVARCHAR(4000)
				,@v_PatientJoinClause VARCHAR(4000) = ''
				,@v_WhereClause VARCHAR(MAX) = ' WHERE 1=1 '
				,@v_CntSql VARCHAR(MAX) = ''

			IF @v_SecurityRoleName = 'Administrator'
			BEGIN
				SET @v_CntSql = 'INSERT INTO #UserCnt  
		SELECT COUNT(DISTINCT Patients.PatientID)  FROM Patients WITH(NOLOCK) '
				SET @v_PatientSQL = 'INSERT INTO #User  
		SELECT TOP ( ' + CONVERT(VARCHAR(10), @i_EndIndex) + ') Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) '
					--IF @v_SecurityRoleName = 'Physician'
					--BEGIN
					--	SET @v_WhereClause = @v_WhereClause + 'And PCPID = ' + CONVERT(VARCHAR(10), @i_AppUserId)
					--END
			END
			ELSE
				IF @v_SecurityRoleName = 'Physician'
				BEGIN
					SET @v_CntSql = 'INSERT INTO #UserCnt  
		SELECT COUNT(DISTINCT Patients.PatientID)  FROM Patients WITH(NOLOCK)  
		INNER JOIN PatientPCP pp WITH(NOLOCK)
		ON pp.PatientID = Patients.PatientID
		INNER JOIN ProviderHierarchyDetail phd  
		ON pp.ProviderID = phd.childproviderid '
					SET @v_PatientSQL = 'INSERT INTO #User  
		SELECT DISTINCT TOP ( ' + CONVERT(VARCHAR(10), @i_EndIndex) + ') Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) 
		INNER JOIN PatientPCP pp WITH(NOLOCK)
		ON pp.PatientID = Patients.PatientID  
		INNER JOIN ProviderHierarchyDetail phd  
		ON pp.ProviderID = phd.childproviderid '
					SET @v_WhereClause = @v_WhereClause + 'And phd.childproviderid = ' + CONVERT(VARCHAR(10), @i_AppUserId)
				END
				ELSE
					IF @v_SecurityRoleName = 'Clinic Administrator'
					BEGIN
						SET @v_CntSql = 'INSERT INTO #UserCnt  
		SELECT COUNT(DISTINCT Patients.PatientID)  FROM Patients WITH(NOLOCK)  
		INNER JOIN PatientPCP pp1 WITH(NOLOCK)
		ON pp1.PatientID = Patients.PatientID
		INNER JOIN ProviderHierarchyDetail phd1  
		ON pp1.ProviderID = phd1.childproviderid '
						SET @v_PatientSQL = 'INSERT INTO #User  
		SELECT DISTINCT TOP ( ' + CONVERT(VARCHAR(10), @i_EndIndex) + ') Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) 
		INNER JOIN PatientPCP pp1 WITH(NOLOCK)
		ON pp1.PatientID = Patients.PatientID  
		INNER JOIN ProviderHierarchyDetail phd1 
		ON pp1.ProviderID = phd1.childproviderid '
						SET @v_WhereClause = @v_WhereClause + 'And phd1.parentproviderid = ' + CONVERT(VARCHAR(10), @i_AppUserId)
					END
					ELSE
						IF @v_SecurityRoleName = 'Insurance Group Provider'
						BEGIN
							SET @v_CntSql = 'INSERT INTO #UserCnt  
		SELECT COUNT(DISTINCT Patients.PatientID)  FROM Patients WITH(NOLOCK)   
		INNER JOIN PatientPCP pp WITH(NOLOCK)
		ON pp.PatientID = Patients.PatientID 
		INNER JOIN PatientInsurance i WITH (NOLOCK)  
		ON Patients.PatientID = i.PatientID  
		INNER JOIN InsuranceGroupPlan igp WITH (NOLOCK)  
		ON igp.InsuranceGroupPlanId = i.InsuranceGroupPlanId  
		INNER JOIN Provider pr  
		ON pr.InsuranceGroupID = igp.InsuranceGroupId  
		'
							SET @v_PatientSQL = 'INSERT INTO #User  
		SELECT DISTINCT TOP ( ' + CONVERT(VARCHAR(10), @i_EndIndex) + ') Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK)   
		INNER JOIN PatientPCP pp WITH(NOLOCK)
		ON pp.PatientID = Patients.PatientID 
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
		INNER JOIN PatientPCP pcp WITH(NOLOCK)
		ON pcp.PatientID = Patients.PatientID 
		INNER JOIN PatientProgram pp WITH ( NOLOCK )  
		ON Patients.PatientID = pp.PatientID  
		INNER JOIN ProgramCareTeam ppc WITH ( NOLOCK )  
		ON ppc.ProgramID = pp.ProgramID  
		INNER JOIN CareTeamMembers ctm WITH ( NOLOCK )  
		ON ctm.CareTeamID = ppc.CareTeamID  
		INNER JOIN Program
		ON Program.ProgramID = ppc.ProgramID 	   
		AND pp.StatusCode = ''A''
		AND ctm.StatusCode = ''A''
		AND Program.statusCode = ''A'' '
								SET @v_PatientSQL = 'INSERT INTO #User  
		SELECT DISTINCT TOP ( ' + CONVERT(VARCHAR(10), @i_EndIndex) + ') Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK)   
		INNER JOIN PatientPCP pcp WITH(NOLOCK)
		ON pcp.PatientID = Patients.PatientID 
		INNER JOIN PatientProgram pp WITH ( NOLOCK )  
		ON Patients.PatientID = pp.PatientID  
		INNER JOIN ProgramCareTeam ppc WITH ( NOLOCK )  
		ON ppc.ProgramID = pp.ProgramID  
		INNER JOIN CareTeamMembers ctm WITH ( NOLOCK )  
		ON ctm.CareTeamID = ppc.CareTeamID  
		INNER JOIN Program
		ON Program.ProgramID = ppc.ProgramID 	   
		AND pp.StatusCode = ''A''
		AND ctm.StatusCode = ''A''
		AND Program.statusCode = ''A'' '

								IF @v_SecurityRoleName = 'Care Manager'
									SET @v_WhereClause = @v_WhereClause + ' And ctm.ProviderID = ' + CONVERT(VARCHAR(10), @i_AppUserId)
								ELSE
									SET @v_WhereClause = @v_WhereClause + ' AND ctm.ProviderID = pp.ProviderID   
		And ctm.ProviderID = ' + CONVERT(VARCHAR(10), @i_AppUserId)
							END

			IF @i_UserID IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And Patients.PatientID = ' + CONVERT(VARCHAR(10), @i_UserID)
			END

			IF @v_LastName IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And Patients.LastName LIKE ' + '''%' + @v_LastName + '%'''
			END

			IF @v_FirstName IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And Patients.FirstName LIKE ' + '''%' + @v_FirstName + '%'''
			END

			IF @v_City IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And Patients.City LIKE ' + '''%' + @v_City + '%'''
			END

			IF @i_ProviderID IS NOT NULL
				AND @v_SecurityRoleName <> 'Clinic Administrator'
			BEGIN
				SET @v_PatientSQL = @v_PatientSQL + ' INNER JOIN PatientPCP pp2 WITH(NOLOCK)
														ON pp2.PatientID = Patients.PatientID  
														INNER JOIN ProviderHierarchyDetail phd2  
														ON pp2.ProviderID = phd2.childproviderid '
				SET @v_CntSql = @v_CntSql + ' INNER JOIN PatientPCP pp2 WITH(NOLOCK)
												ON pp2.PatientID = Patients.PatientID  
												INNER JOIN ProviderHierarchyDetail phd2  
												ON pp2.ProviderID = phd2.childproviderid '
				SET @v_WhereClause = @v_WhereClause + 'And phd2.ParentProviderid = ' + CONVERT(VARCHAR(10), @i_ProviderID)
			END

			IF @v_State IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And Patients.StateCode LIKE ' + '''%' + @v_State + '%'''
			END

			IF @v_EmailIdPrimary IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And Patients.PrimaryEmailAddress = ' + '''' + @v_EmailIdPrimary + ''''
			END

			IF @v_PhoneNumberPrimary IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And PrimaryPhoneNumber = ' + '''' + @v_PhoneNumberPrimary + ''''
			END

			IF @v_ZipCode IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And Patients.ZipCode = ' + '''' + @v_ZipCode + ''''
			END

			IF @v_MemberNum IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And MemberNum = ' + '''' + @v_MemberNum + ''''
			END

			IF @i_ChildProviderID IS NOT NULL
				AND @v_SecurityRoleName <> 'Physician'
			BEGIN
				SET @v_PatientSQL = @v_PatientSQL + ' INNER JOIN PatientPCP pp3 WITH(NOLOCK)
														ON pp3.PatientID = Patients.PatientID  
														AND pp3.IslatestPCP = 1
														INNER JOIN ProviderHierarchyDetail phd3  
														ON pp3.ProviderID = phd3.childproviderid '
				SET @v_CntSql = @v_CntSql + ' INNER JOIN PatientPCP pp3 WITH(NOLOCK)
												ON pp3.PatientID = Patients.PatientID  
												INNER JOIN ProviderHierarchyDetail phd3  
												ON pp3.ProviderID = phd3.childproviderid '
				SET @v_WhereClause = @v_WhereClause + 'And phd3.ChildProviderID = ' + CONVERT(VARCHAR(10), @i_ChildProviderID)
			END

			/*
			IF @i_ChildProviderID IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And PCPID = ' + CONVERT(VARCHAR(10), @i_ChildProviderID)
			END
			*/
			IF @v_UserStatusCode IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And UserStatuscode = ' + '''' + @v_UserStatusCode + ''''
			END
			ELSE
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And UserStatuscode = ''A'''
			END

			IF @vc_Gender IS NOT NULL
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'AND Patients.Gender = ' + '''' + @vc_Gender + ''''
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

			IF @i_HealthPlanID IS NOT NULL
				AND @v_SecurityRoleName <> 'Insurance Group Provider'
			BEGIN
				SET @v_PatientSQL = @v_PatientSQL + 'INNER JOIN PatientInsurance PS  
		ON Patients.PatientId = PS.PatientID  
		INNER JOIN InsuranceGroupPlan IP  
		ON PS.InsuranceGroupPlanId = IP.InsuranceGroupPlanId    
		INNER JOIN InsuranceGroup IG  
		ON IG.InsuranceGroupID = IP.InsuranceGroupId '
				SET @v_CntSql = @v_CntSql + 'INNER JOIN PatientInsurance PS  
		ON Patients.PatientId = PS.PatientID  
		INNER JOIN InsuranceGroupPlan IP  
		ON PS.InsuranceGroupPlanId = IP.InsuranceGroupPlanId    
		INNER JOIN InsuranceGroup IG  
		ON IG.InsuranceGroupID = IP.InsuranceGroupId'
				SET @v_WhereClause = @v_WhereClause + 'And IG.InsuranceGroupID = ' + CONVERT(VARCHAR(10), @i_HealthPlanID)
			END

			IF @i_ProductID IS NOT NULL
			BEGIN
				SET @v_PatientSQL = @v_PatientSQL + ' INNER JOIN PatientInsurance PIN  
		ON Patients.PatientId = PIN.PatientID  
		INNER JOIN InsuranceGroupPlan   
		ON PIN.InsuranceGroupPlanId = InsuranceGroupPlan.InsuranceGroupPlanId '
				SET @v_CntSql = @v_CntSql + ' INNER JOIN PatientInsurance PIN  
		ON Patients.PatientId = PIN.PatientID  
		INNER JOIN InsuranceGroupPlan   
		ON PIN.InsuranceGroupPlanId = InsuranceGroupPlan.InsuranceGroupPlanId'
				SET @v_WhereClause = @v_WhereClause + ' AND InsuranceGroupPlan.InsuranceGroupPlanId = ' + CONVERT(VARCHAR(10), @i_ProductID)
			END

			PRINT @v_PatientSQL + @v_PatientJoinClause + @v_WhereClause + ' Order By 1'

			EXEC (@v_PatientSQL + @v_PatientJoinClause + @v_WhereClause + ' Order By 1')

			PRINT @v_CntSql + @v_WhereClause

			EXEC (@v_CntSql + @v_PatientJoinClause + @v_WhereClause)

			--SELECT * FROM Patients
			SELECT DISTINCT PatientId UserID
				,us.UserLoginName AS UserLoginName
				,FirstName
				,LastName
				,CAST(Age AS VARCHAR) + '/' + Gender AS AgeGender
				,dbo.ufn_GetPCPName(PatientId) AS PCPName
				,DateOfBirth
				,MemberNum AS MemberNum
				,PrimaryEmailAddress EmailIdPrimary
				,PrimaryPhoneNumber
				,PrimaryPhoneNumberExtension
				,AddressLine1
				,AddressLine2
				,Patients.City
				,Patients.ZipCode
				,UserStatuscode UserStatus
				,dbo.udf_TitleCase(FullName) AS FullName
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
	END TRY

	--------------------------------------------------------       
	BEGIN CATCH
		-- Handle exception      
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Patients_Search_Test] TO [FE_rohit.r-ext]
    AS [dbo];

