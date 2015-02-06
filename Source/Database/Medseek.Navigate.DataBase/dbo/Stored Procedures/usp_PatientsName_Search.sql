
/*            
---------------------------------------------------------------------------------            
Procedure Name: [dbo].usp_PatientsName_Search 233,'Hughes, william',0      
Description   : This procedure is used for Get the patients based on entering the text        
Created By    : uday         
Created Date  : 18-April-2013            
----------------------------------------------------------------------------------            
Log History   :             
DD-Mon-YYYY  BY  DESCRIPTION    
07-11-2013 Rathnam Patient.Pcpid replaced as PatientPCP.ProviderID        
----------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_PatientsName_Search] (
	@i_AppUserId KEYID
	,@vc_PatientSearchText VARCHAR(500) = NULL
	,@b_IsMemberNum Isindicator = 0
	)
AS
BEGIN TRY
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

	DECLARE @v_RoleName VARCHAR(100)

	SELECT @v_RoleName = s.RoleName
	FROM UsersSecurityRoles us
	INNER JOIN SecurityRole s
		ON us.SecurityRoleId = s.SecurityRoleId
	WHERE ProviderID = @i_AppUserId

	IF @v_RoleName IN (
			'Care Manager'
			,'Care Team Member'
			)
	BEGIN
		SELECT DISTINCT Patients.PatientID UserId
			,ISNULL(LastName, '') + ', ' + ISNULL(FirstName, '') + ' - ' + ISNULL(MemberNum, '') AS FullName
		FROM Patients WITH (NOLOCK)
		INNER JOIN PatientProgram pp WITH (NOLOCK)
			ON Patients.PatientID = pp.PatientID
		INNER JOIN ProgramCareTeam ppc WITH (NOLOCK)
			ON ppc.ProgramID = pp.ProgramID
		INNER JOIN CareTeamMembers ctm WITH (NOLOCK)
			ON ctm.CareTeamID = ppc.CareTeamID
				AND pp.StatusCode = 'A'
				AND ctm.StatusCode = 'A'
		WHERE (
				(
					LastName + ',' + ' ' + firstname LIKE @vc_PatientSearchText + '%'
					AND @b_IsMemberNum = 0
					)
				OR (
					MemberNum LIKE @vc_PatientSearchText + '%'
					AND @b_IsMemberNum = 1
					)
				)
			AND (
				(
					ctm.ProviderID = @i_AppUserId
					AND @v_RoleName = 'Care Manager'
					)
				OR (
					ctm.ProviderID = pp.ProviderID
					--AND ctm.ProviderID = @i_AppUserId    
					AND @v_RoleName = 'Care Team Member'
					)
				)
	END
	ELSE
		IF @v_RoleName = 'Physician'
		BEGIN
			SELECT DISTINCT p.PatientID UserId
					,ISNULL(LastName, '') + ', ' + ISNULL(FirstName, '') + ' - ' + ISNULL(MemberNum, '') AS FullName
				FROM patients p WITH(NOLOCK)
				INNER JOIN PatientPCP pp WITH(NOLOCK)
				    ON pp.PatientID = p.PatientID
				INNER JOIN ProviderHierarchyDetail phd WITH(NOLOCK)
					ON pp.ProviderID = phd.childproviderid
				WHERE phd.ChildProviderID = @i_AppUserId
					AND (
						LastName + ',' + ' ' + firstname LIKE @vc_PatientSearchText + '%'
						AND @b_IsMemberNum = 0
						)
					OR (
						MemberNum LIKE @vc_PatientSearchText + '%'
						AND @b_IsMemberNum = 1
						)
			
		END
		ELSE
			IF (@v_RoleName = 'Clinic Administrator')
			BEGIN
				SELECT DISTINCT p.PatientID UserId
					,ISNULL(LastName, '') + ', ' + ISNULL(FirstName, '') + ' - ' + ISNULL(MemberNum, '') AS FullName
				FROM patients p WITH(NOLOCK)
				INNER JOIN PatientPCP pp WITH(NOLOCK)
				    ON pp.PatientID = p.PatientID
				INNER JOIN ProviderHierarchyDetail phd WITH(NOLOCK)
					ON pp.ProviderID = phd.childproviderid
				WHERE phd.parentproviderid = @i_AppUserId
					AND (
						LastName + ',' + ' ' + firstname LIKE @vc_PatientSearchText + '%'
						AND @b_IsMemberNum = 0
						)
					OR (
						MemberNum LIKE @vc_PatientSearchText + '%'
						AND @b_IsMemberNum = 1
						)
			END
			ELSE
				IF (@v_RoleName = 'Insurance Group Provider')
				BEGIN
					SELECT DISTINCT p.PatientID UserId
						,ISNULL(p.LastName, '') + ', ' + ISNULL(p.FirstName, '') + ' - ' + ISNULL(p.MemberNum, '') AS FullName
					FROM Patients p WITH (NOLOCK)
					INNER JOIN PatientInsurance i WITH (NOLOCK)
						ON p.PatientID = i.PatientID
					INNER JOIN InsuranceGroupPlan igp WITH (NOLOCK)
						ON igp.InsuranceGroupPlanId = i.InsuranceGroupPlanId
					INNER JOIN Provider pr WITH(NOLOCK)
						ON pr.InsuranceGroupID = igp.InsuranceGroupId
					WHERE pr.ProviderID = @i_AppUserId
						AND (
							p.LastName + ',' + ' ' + p.firstname LIKE @vc_PatientSearchText + '%'
							AND @b_IsMemberNum = 0
							)
						OR (
							MemberNum LIKE @vc_PatientSearchText + '%'
							AND @b_IsMemberNum = 1
							)
				END
END TRY

------------------------------------------------------------------------------------------------------------        
BEGIN CATCH
	-- Handle exception            
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientsName_Search] TO [FE_rohit.r-ext]
    AS [dbo];

