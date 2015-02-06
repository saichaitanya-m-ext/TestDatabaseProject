/*      
----------------------------------------------------------------------------------      
Procedure Name: [usp_ClinicPCPHealthPlanProduct_DD_PatientSearch]  
Description   : This procedure is used to select Users based on the search criteria      
Created By    : Santosh      
Created Date  : 24-Jul-2013  
----------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
05-Nov-2013 Rathnam As per bugid 2989 we have modified the join conditions from patients.pcp to patientpcp.pcp
11/08/2013 Santosh modified the function dbo.ufn_getProvidername to ufn_getPCPname as per the PatientPCP schema change
----------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_ClinicPCPHealthPlanProduct_DD_PatientSearch] (
	@i_AppUserId INT
	,@v_SecurityRoleName VARCHAR(50)
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

	CREATE TABLE #Temp (
		ID INT
		,NAME VARCHAR(50)
		)

	CREATE TABLE #User (
		ID INT IDENTITY(1, 1)
		,PatientID INT
		,SecurityName VARCHAR(50)
		)

	CREATE NONCLUSTERED INDEX [IX_#User.UserId] ON #User (PatientID)

	BEGIN
		DECLARE @v_PatientSQL NVARCHAR(4000)
			,@v_WhereClause VARCHAR(MAX) = ' WHERE 1=1 '

		IF @v_SecurityRoleName = 'Administrator'
		BEGIN
			SET @v_PatientSQL = 'INSERT INTO #User  
		SELECT Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) '
		END
		ELSE
			IF @v_SecurityRoleName = 'Physician'
			BEGIN
				SET @v_PatientSQL = 'INSERT INTO #User  
		SELECT DISTINCT Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) 
		INNER JOIN PatientPCP pp WITH(NOLOCK)
		ON pp.PatientId = Patients.PatientID  
		INNER JOIN ProviderHierarchyDetail phd  
		ON pp.ProviderID = phd.childproviderid '
				SET @v_WhereClause = @v_WhereClause + 'And phd.childproviderid = ' + CONVERT(VARCHAR(10), @i_AppUserId)
			END
			ELSE
				IF @v_SecurityRoleName = 'Clinic Administrator'
				BEGIN
					SET @v_PatientSQL = 'INSERT INTO #User  
		SELECT DISTINCT Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) 
		INNER JOIN PatientPCP pp1 WITH(NOLOCK)
		ON pp1.PatientID = Patients.PatientID  
		INNER JOIN ProviderHierarchyDetail phd1 
		ON pp1.ProviderID = phd1.childproviderid '
					SET @v_WhereClause = @v_WhereClause + 'And phd1.parentproviderid = ' + CONVERT(VARCHAR(10), @i_AppUserId)
				END
				ELSE
					IF @v_SecurityRoleName = 'Insurance Group Provider'
					BEGIN
						SET @v_PatientSQL = 'INSERT INTO #User  
		SELECT DISTINCT Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK)   
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
							SET @v_PatientSQL = 'INSERT INTO #User  
		SELECT DISTINCT Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK)   
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
	END

	PRINT (@v_PatientSQL)

	INSERT INTO #Temp
	EXEC (@v_PatientSQL + @v_WhereClause)

	IF @v_SecurityRoleName = 'Clinic Administrator'
	BEGIN
		SELECT @i_AppUserId ID
			,dbo.ufn_GetProviderName(@i_AppUserId) NAME
	END
	ELSE
	BEGIN
		SELECT DISTINCT phd.ParentProviderID ID
			,dbo.ufn_GetProviderName(phd.ParentProviderID) NAME
		FROM PatientPCP pp WITH (NOLOCK)
		INNER JOIN #User u
			ON pp.PatientId = u.PatientID
		INNER JOIN ProviderHierarchyDetail phd WITH (NOLOCK)
			ON phd.ChildProviderID = pp.ProviderID
	END

	-----------------PCP-----------------
	IF @v_SecurityRoleName = 'Physician'
	BEGIN
		SELECT @i_AppUserId PCPId
			,dbo.ufn_GetProviderName(@i_AppUserId) PCPName
	END
	ELSE
	BEGIN
		SELECT DISTINCT phd.ChildProviderID PCPId
			,dbo.ufn_GetPCPName(u.PatientID) PCPName
		FROM PatientPCP pp WITH (NOLOCK)
		INNER JOIN #User u
			ON pp.PatientId = u.PatientID
		INNER JOIN ProviderHierarchyDetail phd WITH (NOLOCK)
			ON phd.ChildProviderID = pp.ProviderID
	END

	------------------Insurance Group----------------- 
	IF @v_SecurityRoleName = 'Insurance Group Provider'
	BEGIN
		SELECT @i_AppUserId HealthPlanID
			,dbo.ufn_GetProviderName(@i_AppUserId) HealthPlan
	END
	ELSE
	BEGIN
		SELECT DISTINCT I.InsuranceGroupId AS HealthPlanID
			,IG.GroupName AS HealthPlan
		FROM #User u
		INNER JOIN PatientInsurance PS WITH (NOLOCK)
			ON u.PatientId = PS.PatientID
		INNER JOIN InsuranceGroupPlan I WITH (NOLOCK)
			ON PS.InsuranceGroupPlanId = I.InsuranceGroupPlanId
		INNER JOIN InsuranceGroup IG WITH (NOLOCK)
			ON IG.InsuranceGroupID = I.InsuranceGroupId
	END

	-----------------Product-------------------------
	SELECT DISTINCT I.InsuranceGroupPlanId AS ProductID
		,I.PlanName AS Product
	FROM #User U
	INNER JOIN PatientInsurance PS WITH (NOLOCK)
		ON u.PatientId = PS.PatientID
	INNER JOIN InsuranceGroupPlan I WITH (NOLOCK)
		ON PS.InsuranceGroupPlanId = I.InsuranceGroupPlanId
	ORDER BY I.InsuranceGroupPlanId
		,I.PlanName
		
END TRY

----------------------------------------------------------   
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ClinicPCPHealthPlanProduct_DD_PatientSearch] TO [FE_rohit.r-ext]
    AS [dbo];

