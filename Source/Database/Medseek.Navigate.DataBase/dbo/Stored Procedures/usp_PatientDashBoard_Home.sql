

/*  
--------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_PatientDashBoard_Home]23,4016 
Description   : This proc is used to show the patient demographic information in to the PatientHomepage  
Created By    : Rathnam  
Created Date  : 12-Dec-2012 
---------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY				DESCRIPTION  
03-APR-2013 Mohan			Modified UserFamilyMedicalHistory to PatientFamilyMedicalHistory,
							UserAllergies to PatientAllergies,PopulationDefinitionUsers to PopulationDefinitionPatients
06-11-2013	Gourishankar    Added PlanName to ResultSet 
16-07-2013  Mohan added CareTeam columns and Joins
06/08/2013 Santosh added Columns LastER Visit and LastHospitalVisit            
---------------------------------------------------------------------------------  
*/


CREATE PROCEDURE [dbo].[usp_PatientDashBoard_Home] (
	@i_AppUserId KEYID
	,@i_PatientUserID KEYID
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

	DECLARE @todaydate DATE
		,@LastYearDate DATE
		,@LastERDateadt DATE
		,@LastERDateclaim DATE
		,@LastInpatientadt DATE
		,@LastInpatientclaim DATE

	SET @todaydate = GETDATE()
	SET @LastYearDate = DATEADD(YY, - 1, @todaydate)
	
	SELECT @LastERDateadt = MAX(COALESCE(Eventadmitdate,VisitAdmitdate,MessageAdmitdate))
	    FROM PatientADT WHERE PatientID = @i_PatientUserID AND AdmitType = 'E'

	SELECT @LastERDateclaim = MAX(DateOfService) FROM PatientProcedureCode ppc WITH(NOLOCK)
			INNER JOIN PatientProcedureCodeGroup ppcg WITH(NOLOCK)
			  ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
			INNER JOIN CodeGrouping CG WITH(NOLOCK)
			  ON CG.CodeGroupingID = ppcg.CodeGroupingID
			WHERE ppc.PatientID = @i_PatientUserID   
			AND ppc.DateOfService > DATEADD(YEAR,-1,DateOfService)   
			AND CG.CodeGroupingName = 'ED'
	
	
	SELECT @LastInpatientadt = MAX(COALESCE(Eventadmitdate,VisitAdmitdate,MessageAdmitdate)) 
	FROM PatientADT WHERE PatientId = @i_PatientUserID AND AdmitType = 'I'
	
		
	SELECT @LastInpatientclaim = MAX(DateOfService) FROM PatientProcedureCode ppc WITH(NOLOCK)
			INNER JOIN PatientProcedureCodeGroup ppcg WITH(NOLOCK)
			  ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
			INNER JOIN CodeGrouping CG WITH(NOLOCK)
			  ON CG.CodeGroupingID = ppcg.CodeGroupingID
			WHERE ppc.PatientID = @i_PatientUserID   
			AND ppc.DateOfService > DATEADD(YEAR,-1,DateOfService)
			AND CG.CodeGroupingName = 'Acute InPatient'		

			
	SELECT p.PatientID AS UserId
		,MemberNum
		,UPPER(p.FullName) AS FullName
		,ISNULL(p.PrimaryPhoneNumber, '') AS Phone
		,ISNULL(ctp.Description, '') AS Preference
		,ISNULL(CONVERT(VARCHAR, p.Age), '') Age
		,ISNULL(p.Gender, '') Gender
		,p.PrimaryEmailAddress AS EmailIdPrimary
		,[dbo].[ufn_GetPCPName](p.PatientID) PCPName
		,ct.CommunicationType
		,(
			SELECT COUNT(*)
			FROM PatientFamilyMedicalHistory WITH (NOLOCK)
			WHERE PatientID = P.PatientID
				AND PatientFamilyMedicalHistory.StatusCode = 'A'
			) AS UserDependentCount
		,(
			SELECT COUNT(1)
			FROM UserSubstanceAbuse WITH (NOLOCK)
			WHERE PatientId = p.PatientID
				AND StatusCode = 'A'
			) AS SubStanceAbuseCount
		,e.EthnicityName
		,CASE WHEN @LastERDateadt > @LastERDateclaim THEN @LastERDateadt ELSE @LastERDateclaim END
			 AS LastERVisit
		,CASE WHEN @LastInpatientadt > ISNULL(@LastInpatientclaim,'1900-01-01') THEN @LastInpatientadt ELSE @LastInpatientclaim END 
			 AS LastHospitalVisit
		--,CASE		
		--	WHEN LEN(p.MemberNum) > 10
		--		THEN SUBSTRING(p.MemberNum, 1, 10) + '...'
		--	ELSE p.MemberNum
		--	END 
		,p.MemberNum AS ShortMemberNum
		,CASE 
			WHEN LEN(p.PrimaryEmailAddress) > 10
				THEN SUBSTRING(p.PrimaryEmailAddress, 1, 10) + '...'
			ELSE p.PrimaryEmailAddress
			END AS ShortEmailIdPrimary
		,p.DateOfBirth AS DateOfBirth
		,igp.PlanName /*06-11-2013*/
		,[dbo].[ufn_PatientDashBoardADTstatus](p.PatientID) AS PatientADTstatus
	FROM Patients p WITH (NOLOCK)
	LEFT OUTER JOIN CallTimePreference ctp WITH (NOLOCK)
		ON ctp.CallTimeName = p.CallTimeName
	LEFT OUTER JOIN CommunicationType ct WITH (NOLOCK)
		ON ct.CommunicationType = p.CommunicationType
	LEFT OUTER JOIN CodeSetEthnicity e WITH (NOLOCK)
		ON e.EthnicityId = p.EthnicityID
	LEFT OUTER JOIN PatientInsurance pin WITH (NOLOCK) /*06-11-2013*/
		ON p.PatientID = pin.PatientID
	LEFT OUTER JOIN InsuranceGroupPlan igp WITH (NOLOCK) /*06-11-2013*/
		ON igp.InsuranceGroupPlanId = pin.InsuranceGroupPlanId
	WHERE p.PatientID = @i_PatientUserID
		AND P.UserStatusCode = 'A'

	SELECT PatientAllergiesID UserAllergiesID
		,A.NAME Substance
		,CASE 
			WHEN LEN(A.NAME) > 10
				THEN SUBSTRING(A.NAME, 1, 10) + '...'
			ELSE A.NAME
			END ShortSubstance
	FROM PatientAllergies UA WITH (NOLOCK)
	INNER JOIN Allergies A WITH (NOLOCK)
		ON A.AllergiesID = UA.AllergiesID
	WHERE PatientID = @i_PatientUserID
		AND UA.StatusCode = 'A'
		AND A.StatusCode = 'A';

	
		
;WITH CTE
AS
(
SELECT p.PopulationDefinitionID AS DiseaseId
			,p.PopulationDefinitionName AS NAME
			--,u.StartDate AS DiagnosedDate
			,(
					SELECT MIN(pdpa.OutPutAnchorDate)
					FROM PopulationDefinitionPatientAnchorDate pdpa
					WHERE pdpa.PopulationDefinitionPatientID = u.PopulationDefinitionPatientID
								
					) DiagnosedDate
		--,CONVERT(VARCHAR(10),u.StartDate,101) DiagnosedDate
		FROM PopulationDefinition p WITH (NOLOCK)
		INNER JOIN PopulationDefinitionPatients u WITH (NOLOCK)
			ON u.PopulationDefinitionID = p.PopulationDefinitionID
		INNER JOIN CodeGrouping cg
		   ON cg.CodeGroupingID = p.CodeGroupingID
		INNER JOIN CodeTypeGroupers ct
		   ON ct.CodeTypeGroupersID = cg.CodeTypeGroupersID
		INNER JOIN [Standard] S
			ON S.StandardId = P.StandardsId	
		WHERE PatientID = @i_PatientUserID
			AND S.Name = 'CCS'
			AND p.DefinitionType = 'C'
			AND u.StatusCode = 'A'
			AND p.StatusCode = 'A'
			AND p.ProductionStatus = 'F'
			AND ISNULL(p.IsDisplayInHomePage, 0) = 1
			AND p.IsDisplayInHomePage = 1
			AND ct.CodeTypeGroupersName = 'CCS Chronic Diagnosis Group'
	)
	SELECT * FROM CTE --WHERE DiagnosedDate IS NOT NULL
	
			
	SELECT cl.PopulationDefinitionId
		,cl.PopulationDefinitionName AS CohortListName
		, (
					SELECT MIN(pdpa.OutPutAnchorDate)
					FROM PopulationDefinitionPatientAnchorDate pdpa
					WHERE pdpa.PopulationDefinitionPatientID = clu.PopulationDefinitionPatientID
					) AS AutomatedConditionDate
	FROM PopulationDefinitionPatients clu WITH (NOLOCK)
	INNER JOIN PopulationDefinition cl WITH (NOLOCK)
		ON cl.PopulationDefinitionId = clu.PopulationDefinitionId
	WHERE PatientID = @i_PatientUserID
		AND cl.StatusCode = 'A'
		AND clu.StatusCode = 'A'
		AND cl.DefinitionType = 'P'
		AND cl.ProductionStatus = 'F'
		AND ISNULL(cl.IsDisplayInHomePage, 0) = 1
		AND cl.IsDisplayInHomePage = 1
	ORDER BY PopulationDefinitionName

	/*
	SELECT DISTINCT
	p.ProgramId
	,p.ProgramName
	,ups.EnrollmentStartDate
	,ups.EnrollmentEndDate
	,ups.UserProgramId
	FROM
	UserPrograms ups WITH(NOLOCK)
	INNER JOIN Program p WITH(NOLOCK)
	ON ups.ProgramId = p.ProgramId
	WHERE
	UserId = @i_PatientUserID
	AND ups.StatusCode = 'A'
	AND p.StatusCode = 'A'
	AND ups.EnrollmentStartDate IS NOT NULL
	ORDER BY
	ups.UserProgramId DESC
	*/
SELECT DISTINCT p.ProgramId
		,p.ProgramName AS ProgramName
		,CONVERT(DATE, ups.EnrollmentStartDate) AS EnrollmentStartDate
		,'' AS EnrollmentEndDate
		,'' AS UserProgramId
		,CT.CareTeamId
		,CT.CareTeamName
		,CASE 
			WHEN ups.EnrollmentStartDate IS NULL
				AND ISNULL(IsPatientDeclinedEnrollment, 0) = 0
				THEN 'Enrollment Pending'
			WHEN ups.EnrollmentStartDate IS NOT NULL
				AND ISNULL(IsPatientDeclinedEnrollment, 0) = 0
				THEN 'Enrolled'
			WHEN ISNULL(IsPatientDeclinedEnrollment, 0) = 1
				THEN 'Dis-Enrolled'
			END AS EnrollmentStatus
		,(
			SELECT COUNT(1)
			FROM Task t1 WITH (NOLOCK)
			INNER JOIN TaskStatus ts1 WITH (NOLOCK)
				ON t1.TaskStatusId = ts1.TaskStatusId
			WHERE t1.ProgramID = p.ProgramID
				AND t1.PatientId = ups.PatientID
				AND ts1.TaskStatusText = 'Closed Incomplete'
			) AS MissedOpportunityNo
		,CASE 
			WHEN LEN(p.ProgramName) > 10
				THEN SUBSTRING(p.ProgramName, 1, 28) + '...'
			ELSE p.ProgramName
			END AS ShortProgramName

	FROM PatientProgram ups WITH (NOLOCK)
	LEFT JOIN ProgramCareTeam CTM WITH (NOLOCK)
	    ON ups.ProgramID = CTM.ProgramId
	LEFT JOIN CareTeam CT WITH (NOLOCK)
	    ON CTM.CareTeamId = CT.CareTeamId
	INNER JOIN Program p WITH (NOLOCK)
		ON ups.ProgramId = p.ProgramId
	WHERE ups.PatientID = @i_PatientUserID
		AND ups.StatusCode = 'A'
		AND p.StatusCode = 'A'
		AND ups.EnrollmentEndDate IS NULL

	SELECT DISTINCT ClaimProvider.ProviderID AS ProviderUserId
		,ClaimInfo.PatientID AS PatientUserId
		,CodeSetCMSProviderSpecialty.ProviderSpecialtyName AS SpecialityName
		,dbo.ufn_GetProviderName(ClaimProvider.ProviderID) AS ProviderName
	FROM ProviderSpecialty WITH (NOLOCK)
	RIGHT JOIN ClaimProvider WITH (NOLOCK)
		ON ClaimProvider.ProviderID = ProviderSpecialty.ProviderID
	INNER JOIN ClaimInfo WITH (NOLOCK)
		ON ClaimInfo.ClaimInfoId = ClaimProvider.ClaimInfoID
	LEFT JOIN CodeSetCMSProviderSpecialty WITH (NOLOCK)
		ON CodeSetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID
		AND CodeSetCMSProviderSpecialty.StatusCode = 'A'
	WHERE ClaimInfo.PatientID = @i_PatientUserID
		AND DateOfAdmit > DATEADD(YEAR, - 1, GETDATE())
		ORDER BY 4

	--AND DateOfDischarge < @LastYearDate
	SELECT PatientHealthStatusScore.PatientHealthStatusId AS UserHealthStatusId
		,ISNULL(CAST(PatientHealthStatusScore.Score AS VARCHAR(200)), '') + ISNULL(PatientHealthStatusScore.ScoreText, '') AS Score
		,HealthStatusScoreType.NAME AS TYPE
		,PatientHealthStatusScore.DateDetermined
	FROM PatientHealthStatusScore WITH (NOLOCK)
	INNER JOIN HealthStatusScoreType WITH (NOLOCK)
		ON HealthStatusScoreType.HealthStatusScoreId = PatientHealthStatusScore.HealthStatusScoreId
	INNER JOIN HealthStatusScoreOrganization WITH (NOLOCK)
		ON HealthStatusScoreOrganization.HealthStatusScoreOrgId = HealthStatusScoreType.HealthStatusScoreOrgId
	WHERE (PatientHealthStatusScore.PatientID = @i_PatientUserID)
		AND (PatientHealthStatusScore.StatusCode = 'A')
	ORDER BY PatientHealthStatusScore.DateDue DESC
		,PatientHealthStatusScore.DateDetermined DESC
END TRY

BEGIN CATCH
	---------------------------------------------------------------------------------------------------------------------------------
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientDashBoard_Home] TO [FE_rohit.r-ext]
    AS [dbo];

