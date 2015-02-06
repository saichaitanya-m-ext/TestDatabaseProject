
/*  
select * from users order by 1 desc
SELECT * FROM usergroup where userid  =345  
select * from provider where providerid=143
select * from patient where pcpinternalproviderid=68
------------------------------------------------------------------------------      
Procedure Name: [usp_UIDefUserRoles_Select_ByUserId_Multiroles]10,'Care Manager' 
Description   : This procedure is used to get the list of roles and pages the       
                user has access. This is used for building the menu item in the sc UserId is passed to get the detail      
Created By    : Rathnam      
Created Date  : 20-OCT-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION   
13-Dec-2010 Rathnam Added one select at the end of sp for indicating that respecive healthrecord is existing, 
                   commented the exist clause for patient & added @i_PatientUserId IS NULL if else condition
                   for getting patientdashboard.
16-Dec-10 Pramod replaced the select ispatient query's null condition with AND ISNULL( @i_PatientUserId, 0) = 0 
				 For start of multiple role logic Commented IS NULL with ISNULL( @i_PatientUserId, 0) = 0
17-Dec-10 Pramod Case statement is changed to include conditions for update flag
				Included a extra insert to incorporate Admin, patient and Care manager, patient role combination
				Included care team member logic
22-Dec-10 Pramod Corrected the role names for communication content roles
23-Dec-10 Pramod Commented all the internal message text in the code
24-Dec-10 Rathnam Replaced PatientCommunication as Mass Communication for Dataspecialist
28-Dec-10 Rathnam added Reports tab for DataSpecialist
12-Jan-11 Rathnam added PQRI TAB for caremanager & caremember
08-Feb-11 Rathnam added PQRI TAB FOR Administrator
13-July-2011 NagaBabu Added TRIM functionality to MenuItemName field
09-Nov-2011 NagaBabu replaced 'PageOrder' by 'MenuItemName' in order by clause 
01-Dec-2011 NagaBabu Modified MenuItemNames for All security roles as Individually
23-Dec-2011 NagaBabu Changed Roles of 'Care Team Member' as 'Care Manager'
25-May-2012 NagaBabu Added 'Patient Dashboard' menu to 'Care Manager'
------------------------------------------------------------------------------      
usp_UIDefUserRoles_Select_ByUserId_Multiroles 2,null
usp_UIDefUserRoles_Select_ByUserId_Multiroles 2,0
*/
CREATE PROCEDURE [dbo].[usp_UIDefUserRoles_Select_ByUserId_Multiroles] -- 225,'Insurance Group Provider'
	(
	@i_AppUserId INT
	,@v_SecurityRoleName VARCHAR(500)
	)
AS
BEGIN TRY
	SET NOCOUNT ON

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

	DECLARE @t_Role TABLE (
		SecurityRoleId KEYID
		,SecurityRoleName NVARCHAR(512)
		)
	DECLARE @t_TotalMenuItems TABLE (
		UIDefId KEYID
		,PortalId KEYID
		,MenuItemName VARCHAR(100)
		,PageURL VARCHAR(500)
		,PageObject VARCHAR(500)
		,PageDescription VARCHAR(1000)
		,isDataAdminPage BIT
		,MenuItemOrder TINYINT
		,PageOrder TINYINT
		,PageURLNew VARCHAR(500)
		)

	IF @v_SecurityRoleName <> 'Patient'
	BEGIN
		DECLARE @t_MenuItemName TABLE (MenuName VARCHAR(100))

		IF @v_SecurityRoleName = 'Administrator'
		BEGIN
			INSERT INTO @t_MenuItemName
			VALUES ('Home')
				,('Population Reports')
				,('Standard Quality Reports')
				--(
				--  'Risk Management Reports'
				--),
				--(
				--  'Advanced Analytics'
				,(
				  'Search'
				)
				,(
				  'Communication'
				  
				),
				(
				 'Strategy Companion'
				)
				--(
				--  'System Admin'
				--)
		END
		ELSE
		BEGIN
			IF @v_SecurityRoleName = 'Data Specialist'
			BEGIN
				INSERT INTO @t_MenuItemName
				VALUES ('Admin Dashboard')
					,('Data Admin')
					,('Reports')
					,('Search')
					,('Mass Communication')
			END
			ELSE
			BEGIN
				IF @v_SecurityRoleName = 'Physician'
					OR @v_SecurityRoleName = 'Clinic Administrator'
					OR @v_SecurityRoleName = 'Insurance Group Provider'
				BEGIN
					INSERT INTO @t_MenuItemName
					VALUES
						--(
						--  'Home'
						--),
						('Population Reports')
						,('Standard Quality Reports'),
						--,('Care Management'),
						--(
						--  'Advanced Analytics'
						--),
						--(
						--  'Team Admin'
						--),
						--('Search'),
						('Patient Dashboard')
				END
				ELSE
				BEGIN
					IF @v_SecurityRoleName = 'Care Team Member' OR @v_SecurityRoleName = 'Care Manager'
					BEGIN
						INSERT INTO @t_MenuItemName
						VALUES
							--(
							--  'Home'
							--),
							('Population Reports')
							,('Standard Quality Reports')
							,('Care Management'),
							--(
							--  'Advanced Analytics'
							--),
								(
								'Team Admin'
								),
							--('Search'),
							('Patient Dashboard'),(
				 'Strategy Companion'
				)
					END
					ELSE
					BEGIN
						IF @v_SecurityRoleName = 'System Analyst'
						BEGIN
							INSERT INTO @t_MenuItemName
							VALUES ('Home')
								,('Population Reports')
								,('Standard Quality Reports')
								,('Advanced Analytics')
								,('Risk Management Reports')
						END
					END
				END
			END
		END

		INSERT @t_TotalMenuItems
		SELECT UIDef.uidefid
			,UIDef.PortalID
			,RTRIM(LTRIM(UIDef.MenuItemName))
			,UIDef.PageURL
			,UIDef.PageObject
			,UIDef.PageDescription
			,UIDef.isDataAdminPage
			,UIDef.MenuItemOrder
			,UIDef.PageOrder
			,UIDef.PageURLNew
		FROM UIDef
		INNER JOIN @t_MenuItemName MenuItemName
			ON MenuItemName.MenuName = UIDef.PageDescription
		WHERE UIDef.PageDescription IN (
				SELECT Menuname
				FROM @t_MenuItemName
				)
		
		UNION
		
		SELECT DISTINCT UIDefId
			,PortalId
			,RTRIM(LTRIM(MenuItemName))
			,PageURL
			,PageObject
			,PageDescription
			,isDataAdminPage
			,MenuItemOrder
			,PageOrder
			,UIDef.PageURLNew
		FROM UIDef
		WHERE MenuItemOrder IN (
				SELECT MenuItemOrder
				FROM UIDef
				WHERE PageDescription IN (
						SELECT Menuname
						FROM @t_MenuItemName
						)
				)
			AND PageOrder IS NOT NULL

		SELECT Submenu.UIDefId
			,Submenu.MenuItemName
			,Submenu.PortalId
			,Submenu.PageURL
			,Submenu.PageDescription
			,submenu.MenuItemOrder
			,submenu.PageOrder
			,CAST(CASE 
					WHEN SUM(CAST(UIDefUserRoles.UpdateYN AS INT)) > 0
						THEN 0
					ELSE 1
					END AS BIT) ReadYN
			,CAST(CASE 
					WHEN SUM(CAST(UIDefUserRoles.UpdateYN AS INT)) > 0
						THEN 1
					ELSE 0
					END AS BIT) UpdateYN
			,CAST(CASE 
					WHEN SUM(CAST(UIDefUserRoles.InsertYN AS INT)) > 0
						THEN 1
					ELSE 0
					END AS BIT) InsertYN
			,CAST(CASE 
					WHEN SUM(CAST(UIDefUserRoles.DeleteYN AS INT)) > 0
						THEN 1
					ELSE 0
					END AS BIT) DeleteYN
			,Submenu.PageObject
			,Submenu.isDataAdminPage
			,NULL AS SecurityRoleId
			,Submenu.PageURLNew
		FROM UIDefUserRoles
		INNER JOIN @t_TotalMenuItems Submenu
			ON UIDefUserRoles.UIDefId = Submenu.UIDefId
		INNER JOIN SecurityRole
			ON SecurityRole.SecurityRoleId = UIDefUserRoles.SecurityRoleId
		WHERE SecurityRole.RoleName = @v_SecurityRoleName
		GROUP BY Submenu.UIDefId
			,Submenu.MenuItemName
			,Submenu.PageURL
			,Submenu.PortalId
			,Submenu.PageURL
			,Submenu.PageObject
			,Submenu.PageDescription
			,Submenu.isDataAdminPage
			,submenu.MenuItemOrder
			,submenu.PageOrder
			,Submenu.PageURLNew
		ORDER BY submenu.MenuItemOrder
			,Submenu.PageOrder
	END
	ELSE
	BEGIN
		SELECT DISTINCT UIDef.PortalId
			,RTRIM(LTRIM(UIDef.MenuItemName)) AS MenuItemName
			,UIDef.PageURL
			,UIDef.PageObject
			,UIDef.PageDescription
			,UIDef.isDataAdminPage
			,UIDefUserRoles.UIDefUserRoleId
			,UIDefUserRoles.UIDefId
			,UIDefUserRoles.SecurityRoleId
			,UIDefUserRoles.ReadYN
			,UIDefUserRoles.UpdateYN
			,UIDefUserRoles.InsertYN
			,UIDefUserRoles.DeleteYN
			,UIDef.MenuItemOrder
			,UIDef.PageOrder
			,UIDef.PageURLNew
		FROM SecurityRole
		INNER JOIN UIDefUserRoles
			ON UIDefUserRoles.SecurityRoleId = SecurityRole.SecurityRoleId
		INNER JOIN UIDef
			ON UIDef.UIDefId = UIDefUserRoles.UIDefId
		WHERE SecurityRole.RoleName = 'Patient'
			AND uidef.PageDescription IN (
				'Patient Dashboard'
				,'Patient Homepage'
				)
		ORDER BY UIDef.MenuItemOrder
			,UIDef.PageOrder
	END
	DECLARE @i_Top INT = 1
	IF @v_SecurityRoleName IN (
			'Care Manager'
			,'Care Team Member'
			)
	BEGIN
		EXEC usp_CareProviderDashBoard_MyPatients_PatientViewPaging_PD @i_AppUserId = @i_AppUserId
	END
	ELSE
		IF @v_SecurityRoleName = 'Physician'
		BEGIN
			SELECT TOP (@i_Top) PatientID AS IsPatient
			FROM Patients
			WHERE PCPId = @i_AppUserId
		END
		ELSE
			IF (@v_SecurityRoleName = 'Clinic Administrator')
			BEGIN
				SELECT TOP (@i_Top) patientid
				FROM patients p
				INNER JOIN ProviderHierarchyDetail phd
					ON p.PCPID = phd.childproviderid
				WHERE phd.parentproviderid = @i_AppUserId
			END
			ELSE
				IF (@v_SecurityRoleName = 'Insurance Group Provider')
				BEGIN
					SELECT TOP (@i_Top) p.PatientID
					FROM Patients p WITH (NOLOCK)
					INNER JOIN PatientInsurance i WITH (NOLOCK)
						ON p.PatientID = i.PatientID
					INNER JOIN InsuranceGroupPlan igp WITH (NOLOCK)
						ON igp.InsuranceGroupPlanId = i.InsuranceGroupPlanId
					INNER JOIN Provider pr
						ON pr.InsuranceGroupID = igp.InsuranceGroupId
					WHERE pr.ProviderID = @i_AppUserId
					ORDER BY 1
				END
				ELSE
				BEGIN
					SELECT PatientID AS IsPatient
					FROM PatientS
					WHERE PatientID = @i_AppUserId
				END
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
    ON OBJECT::[dbo].[usp_UIDefUserRoles_Select_ByUserId_Multiroles] TO [FE_rohit.r-ext]
    AS [dbo];

