/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_ClinicPCPHealthPlanProduct_DD_PatientSearch]  10937,'Care Manager'
                [usp_ClinicPCPHealthPlanProduct_DD_PatientSearch]  1,'Administrator'
                [usp_ClinicPCPHealthPlanProduct_DD_PatientSearch] 2,'Clinic Administrator' 
Description   : This procedure is used to get the list of all Clinics from Provider table based on appuserid
Created By    : Santosh
Created Date  : 24-july-2013
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION 
06-Aug-2013 NagaBabu Added Nonclustered index [IX_#User.UserId] while resolving performence problem  
------------------------------------------------------------------------------  
*/


CREATE PROCEDURE [dbo].[usp_ClinicPCPHealthPlanProduct_DD_PatientSearch_OLD]  
 (
 @i_AppUserId INT,
 @v_SecurityRoleName VARCHAR(50)
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
 

	--SELECT p.ProviderID,OrganizationName AS ClinicName FROM Provider p
	--INNER JOIN CodeSetProviderType cs
	--ON cs.ProviderTypeCodeID = p.ProviderTypeID
	--WHERE p.ProviderID = @i_AppUserId 
	--AND cs.Description = 'clinic'

	

	--SELECT ChildProviderID,PP.FirstName+PP.LastName AS PCPName FROM ProviderHierarchyDetail PD
	--INNER JOIN Provider P
	--ON PD.ParentProviderID = P.ProviderID
	--INNER JOIN Provider PP
	--ON PD.ChildProviderID = PP.ProviderID 
	--WHERE PD.ParentProviderID =  @i_AppUserId	
 
	
	--SELECT DISTINCT I.InsuranceGroupId AS HealthPlanID,IG.GroupName AS HealthPlan FROM PatientPCP PP
	--INNER JOIN PatientInsurance PS
	--ON PP.PatientId = PS.PatientID
	--INNER JOIN InsuranceGroupPlan I
	--ON PS.InsuranceGroupPlanId = I.InsuranceGroupPlanId  
	--INNER JOIN InsuranceGroup IG
	--ON IG.InsuranceGroupID = I.InsuranceGroupId  
	--WHERE PP.ProviderID = @i_AppUserId
	--ORDER BY I.InsuranceGroupId,IG.GroupName 

	--SELECT DISTINCT I.InsuranceGroupPlanId AS ProductID,I.PlanName AS Product FROM PatientPCP PP
	--INNER JOIN PatientInsurance PS
	--ON PP.PatientId = PS.PatientID
	--INNER JOIN InsuranceGroupPlan I
	--ON PS.InsuranceGroupPlanId = I.InsuranceGroupPlanId  
	--WHERE PP.ProviderID = @i_AppUserId
	--ORDER BY I.InsuranceGroupPlanId,I.PlanName 
	CREATE TABLE #Temp
	(
	ID INT,
	Name VARCHAR(50)
	) 
	
	CREATE TABLE #User (
		ID INT IDENTITY(1, 1)
		,UserID INT
		,SecurityName VARCHAR(50)
		)
		
	CREATE NONCLUSTERED INDEX [IX_#User.UserId] ON #User
	(
		UserId
	)	
	
	DECLARE @v_PatientSQL NVARCHAR(4000)
			,@v_PatientJoinClause VARCHAR(4000) = ''
			,@v_WhereClause VARCHAR(MAX) = ' WHERE 1=1 '
			,@v_CntSql VARCHAR(MAX) = ''
			,@vc_SQL VARCHAR(MAX) = ''
	
	IF @v_SecurityRoleName IN (
				'Physician'
				,'Administrator'
				)
				
		BEGIN
		
					SET @v_PatientSQL = 'INSERT INTO #User
											SELECT DISTINCT Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) '
		
		
		
		           IF @v_SecurityRoleName = 'Physician'
			BEGIN
				SET @v_WhereClause = @v_WhereClause + 'And PCPID = ' + CONVERT(VARCHAR(10), @i_AppUserId)
			END
		END		
	  ELSE
	     IF @v_SecurityRoleName = 'Clinic Administrator'
			BEGIN
	      SET @v_PatientSQL = 'INSERT INTO #User
											SELECT DISTINCT  Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) 
											INNER JOIN ProviderHierarchyDetail phd
													ON Patients.PCPID = phd.childproviderid
											'
				SET @v_WhereClause = @v_WhereClause + 'And phd.parentproviderid = ' + CONVERT(VARCHAR(10), @i_AppUserId)
	    
	    END
	  ELSE
	    IF @v_SecurityRoleName = 'Insurance Group Provider'
				BEGIN 
	
	    
	SET @v_PatientSQL = 'INSERT INTO #User
											SELECT DISTINCT  Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) 
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
											SELECT DISTINCT  Patients.PatientID,''Patient''  FROM Patients WITH(NOLOCK) 
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
	        
	        
	        PRINT @v_PatientSQL + @v_PatientJoinClause + @v_WhereClause + ' Order By 1'

			EXEC (@v_PatientSQL + @v_PatientJoinClause + @v_WhereClause + ' Order By 1')
			
			
   --   IF NOT EXISTS (
			--SELECT DISTINCT  p.ProviderID,OrganizationName AS ClinicName FROM Provider p
			--INNER JOIN Patients
			-- ON Patients.PCPId = p.ProviderID
			--INNER JOIN #User U
			-- ON U.UserID = Patients.PatientID
			--INNER JOIN ProviderHierarchyDetail PD
			-- ON PD.ChildProviderID = Patients.PCPId 
			--WHERE p.ProviderID = PD.ParentProviderID)
			
			--BEGIN
			
			IF @v_SecurityRoleName IN (
							'Care Manager'
							,'Care Team Member','Insurance Group Provider')
							
				BEGIN			
			SET @vc_SQL = @vc_SQL+'select ProviderID,OrganizationName from Provider where providerid in 
			(select ParentProviderID from ProviderHierarchyDetail where ChildProviderID in (
			select Patients.pcpid from #User
			 INNER JOIN Patients 
			  ON Patients.Patientid = #User.userid)) '
			  END	  
			  
						
			
			 IF @v_SecurityRoleName IN ('Clinic Administrator')	
			 BEGIN		
			SET @vc_SQL = @vc_SQL+ 'SELECT DISTINCT  p.ProviderID,OrganizationName AS ClinicName FROM Provider p
			LEFT JOIN Patients
			 ON Patients.PCPId = p.ProviderID
			INNER JOIN #User U
			 ON U.UserID = Patients.PatientID
			INNER JOIN ProviderHierarchyDetail PD
			 ON PD.ChildProviderID = Patients.PCPId 
			WHERE 
			    PD.ParentProviderID = ' + CONVERT(VARCHAR(10), @i_AppUserId)
			
			SET @vc_SQL = @vc_SQL+'SELECT ProviderID,OrganizationName FROM Provider WHERE Providerid = '+ CONVERT(VARCHAR(10), @i_AppUserId)
			END
			
			
			 --IF @v_SecurityRoleName = 'Insurance Group Provider'	
			 --BEGIN
			 -- SET @vc_SQL = @vc_SQL+ 'SELECT DISTINCT Providerid,Organizationname FROM Provider WHERE ProviderID = @i_AppUserId'
			 --END
			 
		   IF @v_SecurityRoleName IN 	('Physician')
			 BEGIN
			   SET @vc_SQL = @vc_SQL+'SELECT Providerid,ORGANIZATIONNAME FROM PROVIDER 
			   INNER JOIN ProviderHierarchyDetail 
			    ON ProviderHierarchyDetail.ParentProviderID = PROVIDER.ProviderID
			    WHERE ProviderHierarchyDetail.ChildProviderID = '+ CONVERT(VARCHAR(10), @i_AppUserId)
			  
			 END
			
			PRINT (@vc_SQL)
			INSERT INTO #Temp
			EXEC (@vc_SQL)
			SELECT * FROM #Temp ORDER BY 1 ASC
			--END
			
		
			
			-----------------PCP-----------------
             
			SELECT DISTINCT Patients.PCPId,Provider.LastName+', '+Provider.FirstName AS PCPName FROM #User U
			INNER JOIN Patients
			ON Patients.PatientID = U.UserID
			INNER JOIN Provider 
			ON Provider.ProviderID = Patients.PCPId  
	        
	       ------------------Insurance Group----------------- 

			SELECT DISTINCT I.InsuranceGroupId AS HealthPlanID,IG.GroupName AS HealthPlan FROM PatientPCP PP
			INNER JOIN #User U
			 ON U.UserID = PP.PatientId
			INNER JOIN PatientInsurance PS
			ON PP.PatientId = PS.PatientID
			INNER JOIN InsuranceGroupPlan I
			ON PS.InsuranceGroupPlanId = I.InsuranceGroupPlanId  
			INNER JOIN InsuranceGroup IG
			ON IG.InsuranceGroupID = I.InsuranceGroupId  
			--ORDER BY I.InsuranceGroupId,IG.GroupName
			-----------------Product-------------------------

			SELECT DISTINCT I.InsuranceGroupPlanId AS ProductID,I.PlanName AS Product FROM PatientPCP PP
			INNER JOIN #User U
			 ON U.UserID = PP.PatientId
			INNER JOIN PatientInsurance PS
			ON PP.PatientId = PS.PatientID
			INNER JOIN InsuranceGroupPlan I
			ON PS.InsuranceGroupPlanId = I.InsuranceGroupPlanId  
			ORDER BY I.InsuranceGroupPlanId,I.PlanName 

	      
	        
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
    ON OBJECT::[dbo].[usp_ClinicPCPHealthPlanProduct_DD_PatientSearch_OLD] TO [FE_rohit.r-ext]
    AS [dbo];

