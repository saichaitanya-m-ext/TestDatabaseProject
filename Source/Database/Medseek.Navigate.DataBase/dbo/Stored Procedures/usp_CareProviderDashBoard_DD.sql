  
  
/*    
---------------------------------------------------------------------------------    
Procedure Name: [dbo].[Usp_CareProviderDashBoard_DD] 10934    
Description   : This procedure is used to select active data for all dropdown.    
Created By    : NagaBabu    
Created Date  : 12-Jan-2013    
----------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
08/08/2013: Santosh added PCP and Clinic result sets
22-Jan-2014 NagaBabu Modified PCP dropdown querry by fetching data FROM PatientPCP table insteed of Patient table
----------------------------------------------------------------------------------    
*/  
	CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_DD] (@i_AppUserId KEYID)  
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

	---------------- All the Active CareTeam Data --------    
	SELECT CareTeam.CareTeamId AS ID  
	,CareTeam.CareTeamName AS NAME  
	FROM CareTeam  
	INNER JOIN CareTeamMembers  
	ON CareTeam.CareTeamID = CareTeamMembers.CareTeamID  
	WHERE CareTeamMembers.ProviderID = @i_AppUserId  
	AND CareTeamMembers.StatusCode = 'A'  
	AND CareTeam.StatusCode = 'A'  

	---------------- All the Active Operator Data --------    
	SELECT OperatorId AS ID  
	,OperatorValue AS NAME  
	FROM Operator  
	WHERE StatusCode = 'A'  
	ORDER BY SortOrder  
	,OperatorValue  

	---------------- All the Active InsuranceGroup Data --------    
	SELECT InsuranceGroupID AS ID  
	,GroupName AS NAME  
	FROM InsuranceGroup  
	WHERE StatusCode = 'A'  
	ORDER BY GroupName  

	---------------- All the Active Program Data --------    
	SELECT p.ProgramId AS ID  
	,p.ProgramName AS NAME  
	FROM Program p  
	INNER JOIN ProgramCareTeam pct  
	ON p.ProgramId = pct.ProgramId  
	INNER JOIN CareTeamMembers ctm  
	ON ctm.CareTeamId = pct.CareTeamId  
	WHERE p.StatusCode = 'A'  
	AND ctm.StatusCode = 'A'  
	AND ctm.ProviderID = @i_AppUserId  
	ORDER BY ProgramName  

	---------------- All the Active Disease Data --------    
	SELECT PopulationDefinitionID AS ID  
	,PopulationDefinitionName AS NAME  
	FROM PopulationDefinition pd  
	INNER JOIN CodeGrouping cg  
	ON pd.CodeGroupingID = cg.CodeGroupingID  
	INNER JOIN CodeTypeGroupers ctg  
	ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID     
	WHERE pd.StatusCode = 'A'  
	AND DefinitionType = 'C'  
	AND pd.ProductionStatus = 'F'  
	AND ctg.CodeTypeGroupersName = 'CCS Chronic Diagnosis Group'  
	ORDER BY NAME  

	---------------- All the Active [State] Data --------       
	SELECT StateCode AS ID  
	,StateName AS NAME  
	FROM CodeSetState  
	WHERE StatusCode = 'A'
	ORDER BY NAME  

	---------------- All the Active Measure Data --------      
	SELECT MeasureId AS ID  
	,NAME  
	FROM Measure  
	WHERE StatusCode = 'A'  
	AND IsVital = 0  
	AND IsSynonym = 0  
	ORDER BY NAME  

	SELECT DISTINCT ProductType  
	,CASE   
	WHEN ProductType = 'C'  
	THEN 'Commercial'  
	WHEN ProductType = 'M'  
	THEN 'Medicare'  
	WHEN ProductType = 'H'  
	THEN 'HMO'  
	WHEN ProductType = 'P'  
	THEN 'PPO'  
	END ProductName  
	FROM InsuranceGroupplan h  
	WHERE StatusCode = 'A'  
	AND ProductType IS NOT NULL  


	--SELECT DISTINCT ProviderID
	--	,OrganizationName
	--FROM provider p
	--INNER JOIN CodeSetProviderType ty
	--	ON p.ProviderTypeID = ty.ProviderTypeCodeID
	--INNER JOIN ProviderHierarchyDetail phd
	--	ON phd.ParentProviderID = p.ProviderID
	--INNER JOIN Patients ps
	--	ON ps.PCPId = phd.ChildProviderID
	--WHERE p.AccountStatusCode = 'A'
	--	AND ty.Description = 'Clinic'
	--	AND ProviderID = @i_AppUserId
		CREATE TABLE #User
		(
		PatientID INT
		)
	
		DECLARE @v_PatientSQL VARCHAR(MAX),
		@vc_SQL VARCHAR(MAX)

		SET @v_PatientSQL = 'INSERT INTO #User
		SELECT DISTINCT  Patients.PatientID FROM Patients WITH(NOLOCK) 
		INNER JOIN PatientProgram pp WITH ( NOLOCK )
		ON Patients.PatientID = pp.PatientID
		INNER JOIN ProgramCareTeam ppc WITH ( NOLOCK )
		ON ppc.ProgramID = pp.ProgramID
		INNER JOIN CareTeamMembers ctm WITH ( NOLOCK )
		ON ctm.CareTeamID = ppc.CareTeamID
		AND pp.StatusCode = ''A''
		AND ctm.StatusCode = ''A''
		And ctm.ProviderID = ' + CONVERT(VARCHAR(10), @i_AppUserId)

        PRINT(@v_PatientSQL)
		EXEC(@v_PatientSQL)


		SET @vc_SQL = 'SELECT ProviderID,OrganizationName from Provider where providerid in 
		(select ParentProviderID from ProviderHierarchyDetail where ChildProviderID in (
		select Patients.pcpid from #User
		INNER JOIN Patients 
		ON Patients.Patientid = #User.Patientid)) '
        
        PRINT(@vc_SQL)
		EXEC(@vc_SQL)

		SELECT DISTINCT pp.ProviderID AS ChildProviderID,
			Provider.LastName+', '+Provider.FirstName AS PCPName 
		FROM #User U
		INNER JOIN PatientPCP pp
		ON pp.PatientID = U.PatientID
		INNER JOIN Provider 
		ON Provider.ProviderID = pp.ProviderID
		WHERE pp.IslatestPCP = 1  
  
END TRY  
  
BEGIN CATCH  
 -- Handle exception    
 DECLARE @i_ReturnedErrorID INT  
  
 EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
 RETURN @i_ReturnedErrorID  
END CATCH  
   

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_DD] TO [FE_rohit.r-ext]
    AS [dbo];

