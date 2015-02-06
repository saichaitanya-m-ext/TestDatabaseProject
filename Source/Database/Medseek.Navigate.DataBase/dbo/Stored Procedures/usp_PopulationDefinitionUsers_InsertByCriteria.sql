
/*      
---------------------------------------------------------------------------------------      
Procedure Name: usp_CohortListUsers_InsertByCriteria  
Description   : This procedure is used to Insert the CohortListUsers data by using data  
    from chort and criteria  
Created By    : Pramod  
Created Date  : 07-Jun-2010      
---------------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
24-Jun-10 Pramod Update from Pending to Active is included  
03-Dec-10 Rathnam added if condition @nv_CriteriaSQL IS NOT NULL OR @nv_CriteriaSQL <> ''  
18-Aug-2011 Gurumoorthy.v Added parameters(@i_CareTeamID INT = NULL,@c_CareTeamOption CHAR(1)= NULL,  
   @v_SubjectText VARCHAR(200) = NULL, @v_CommunicationText NVARCHAR(MAX) = NULL)And   
   included If condition IF @i_CareTeamID IS NOT NULL AND @c_CareTeamOption = 'E' ---Means send mail  
09-Dec-2011 NagaBabu Added LastModifiedByUserId,LastModifiedDate For Update statements    
05-Sep-2012 Rathnam added while loop and getting the criteria records where PanelorGroupName = 'Build Definition' 
12-Oct-2012 Rathnam added insert statement for ProgramPatientTaskConflict, userprograms tables
15-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID
---------------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinitionUsers_InsertByCriteria] (
	@i_AppUserId KEYID
	,@i_PopulationDefinitionID KEYID
	,@i_CareTeamID INT = NULL
	,@c_CareTeamOption CHAR(1) = NULL
	,@v_SubjectText VARCHAR(200) = NULL
	,@v_CommunicationText NVARCHAR(MAX) = NULL
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

	CREATE TABLE #tmpUser (UserId INT)

	DECLARE @l_numberOfRecordsInserted INT
		,@nv_PrefixSQL NVARCHAR(200) = 'INSERT INTO #tmpUser (UserId) SELECT PatientID FROM Patients WHERE DateOfDeath IS NULL AND ISNULL(IsDeceased,0) = 0  AND UserStatusCode = ''A'''
		,@nv_CriteriaSQL NVARCHAR(MAX) = ''
		,@nv_FullSQL NVARCHAR(MAX) = ''
		,@v_PopulationDefinitionCriteriaSQL NVARCHAR(MAX) = ''
		,@v_CohortCriteriaSQLTemp NVARCHAR(MAX) = ''

	IF EXISTS (
			SELECT 1
			FROM PopulationDefinition
			WHERE PopulationDefinitionID = @i_PopulationDefinitionID
				AND ProductionStatus = 'F'
			)
	BEGIN
		SELECT TOP 1 @v_PopulationDefinitionCriteriaSQL = PopulationDefinitionCriteriaSQL
		FROM PopulationDefinitionCriteria
		INNER JOIN PopulationDefPanelConfiguration
			ON PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID = PopulationDefinitionCriteria.PopulationDefPanelConfigurationID
		WHERE PopulationDefinitionCriteria.PopulationDefinitionID = @i_PopulationDefinitionID
			AND PanelorGroupName = 'Build Definition'
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM PopulationDefinition
				WHERE PopulationDefinitionID = @i_PopulationDefinitionID
					AND ProductionStatus = 'D'
				)
		BEGIN
			SELECT TOP 1 @v_PopulationDefinitionCriteriaSQL = PopulationDefinitionCriteriaSQL
			FROM CohortListCriteriaHistory
			INNER JOIN PopulationDefPanelConfiguration
				ON PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID = CohortListCriteriaHistory.PopulationDefPanelConfigurationID
			WHERE CohortListCriteriaHistory.PopulationDefinitionID = @i_PopulationDefinitionID
				AND PanelorGroupName = 'Build Definition'
			ORDER BY DefinitionVersion DESC
		END

		IF @v_PopulationDefinitionCriteriaSQL = ''
		BEGIN
			SELECT TOP 1 @v_PopulationDefinitionCriteriaSQL = PopulationDefinitionCriteriaSQL
			FROM PopulationDefinitionCriteria
			INNER JOIN PopulationDefPanelConfiguration
				ON PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID = PopulationDefinitionCriteria.PopulationDefPanelConfigurationID
			INNER JOIN PopulationDefinition
				ON PopulationDefinition.PopulationDefinitionID = PopulationDefinitionCriteria.PopulationDefinitionID
			WHERE PopulationDefinitionCriteria.PopulationDefinitionID = @i_PopulationDefinitionID
				AND PanelorGroupName = 'Build Definition'
				AND ProductionStatus = 'D'
		END
	END

	WHILE CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1) > 0
	BEGIN
		IF ISNUMERIC(RTRIM(LTRIM(REPLACE(SUBSTRING(@v_PopulationDefinitionCriteriaSQL, CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1), CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, (CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL) + 1)) - CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1) + 1), '$', '')))) = 1
		BEGIN
			SELECT @v_CohortCriteriaSQLTemp = PopulationDefinitionCriteriaSQL
			FROM PopulationDefinitionCriteria
			INNER JOIN PopulationDefPanelConfiguration
				ON PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID = PopulationDefinitionCriteria.PopulationDefPanelConfigurationID
			WHERE PopulationDefinitionID = RTRIM(LTRIM(REPLACE(SUBSTRING(@v_PopulationDefinitionCriteriaSQL, CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1), CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, (CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL) + 1)) - CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1) + 1), '$', '')))
				AND PanelorGroupName = 'Build Definition'

			SET @v_PopulationDefinitionCriteriaSQL = REPLACE(@v_PopulationDefinitionCriteriaSQL, SUBSTRING(@v_PopulationDefinitionCriteriaSQL, CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1), CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, (charindex('$', @v_PopulationDefinitionCriteriaSQL) + 1)) - CHARINDEX('$', @v_PopulationDefinitionCriteriaSQL, 1) + 1), (
						CASE 
							WHEN ISNULL(@v_CohortCriteriaSQLTemp, '') = ''
								THEN '1=1'
							ELSE @v_CohortCriteriaSQLTemp
							END
						))
			SET @v_CohortCriteriaSQLTemp = ''
		END
	END

	SELECT @nv_CriteriaSQL = @nv_CriteriaSQL + ' AND ' + REPLACE(@v_PopulationDefinitionCriteriaSQL, 'IsDeceased', 'ISNULL(IsDeceased,0)') + ' '

	IF (
			@nv_CriteriaSQL IS NOT NULL
			OR @nv_CriteriaSQL <> ''
			)
		AND @v_PopulationDefinitionCriteriaSQL <> ''
	BEGIN
		SET @nv_FullSQL = @nv_PrefixSQL + ' ' + @nv_CriteriaSQL

		PRINT @nv_FullSQL

		EXEC (@nv_FullSQL)

		UPDATE PopulationDefinitionPatients
		SET StatusCode = 'I'
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		WHERE PopulationDefinitionID = @i_PopulationDefinitionID
			AND NOT EXISTS (
				SELECT 1
				FROM #tmpUser usr
				WHERE usr.UserId = PopulationDefinitionPatients.PatientID
				)
			AND StatusCode = 'A'
			
		UPDATE PopulationDefinitionPatients
		SET StatusCode = 'A'
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		WHERE PopulationDefinitionID = @i_PopulationDefinitionID
			AND EXISTS (
				SELECT 1
				FROM #tmpUser usr
				WHERE usr.UserId = PopulationDefinitionPatients.PatientID
				)
			AND StatusCode = 'I'

		INSERT INTO PopulationDefinitionPatients (
			PopulationDefinitionID
			,PatientID
			,StatusCode
			,LeaveInList
			,CreatedByUserId
			)
		SELECT @i_PopulationDefinitionID
			,usr.UserId
			,'A'
			,0
			,@i_AppUserId
		FROM #tmpUser usr
		WHERE NOT EXISTS (
				SELECT 1
				FROM PopulationDefinitionPatients
				WHERE PopulationDefinitionPatients.PopulationDefinitionID = @i_PopulationDefinitionID
					AND PopulationDefinitionPatients.PatientID = usr.UserId
				)

		DECLARE @dt_date DATETIME = GETDATE()
		  /* Do Update Enrollment EndDate  where the patients are out from population definition */
		UPDATE PatientProgram
		SET
		    EnrollmentEndDate = @dt_date,
		    LastModifiedByUserId = @i_AppUserId, 
		    LastModifiedDate = @dt_date 
		FROM PopulationDefinitionPatients clu
		INNER JOIN Program p
			ON clu.PopulationDefinitionID = P.PopulationDefinitionID
		WHERE PatientProgram.ProgramID = p.ProgramId
		AND PatientProgram.PatientID = clu.PatientID
		AND clu.StatusCode = 'I'	      
		AND PatientProgram.EnrollmentStartDate IS NOT NULL
		AND PatientProgram.EnrollmentEndDate IS NULL
		AND clu.PopulationDefinitionID = @i_PopulationDefinitionID
		    
		DECLARE @b_IsADT bit, @v_ADTType VARCHAR(1)
		SELECT @b_IsADT = pd.IsADT,@v_ADTType = pd.ADTtype  FROM PopulationDefinition pd WITH(NOLOCK)
		WHERE pd.PopulationDefinitionID = @i_PopulationDefinitionID		
		
		IF @v_ADTType = 'D'
		BEGIN
		/* For Discharge population we may get readmit discharge records means with out closing the existing discharge record (45 days duration)
		   we may receive another record with different enrollmentstartdate/EventdischargeDate.In this case we have to close the existing
		   record and create new record in managepopulation.
		
		*/
		    UPDATE PatientProgram
		    SET
			   EnrollmentEndDate = @dt_date,
			   LastModifiedByUserId = @i_AppUserId, 
			   LastModifiedDate = @dt_date 
		    FROM PopulationDefinitionPatients clu
		    INNER JOIN (SELECT PatientID, MAX(EventDischargedate) EventDischargedate FROM PatientADT WHERE PatientADT.EventDischargedate IS NOT NULL GROUP BY PatientID) t
		    ON t.PatientID = clu.PatientID
		    INNER JOIN Program p
			    ON clu.PopulationDefinitionID = P.PopulationDefinitionID
		    WHERE PatientProgram.ProgramID = p.ProgramId
		    AND t.PatientID = PatientProgram.PatientID
		    AND clu.StatusCode = 'A'	      
		    AND PatientProgram.EnrollmentStartDate IS NOT NULL
		    AND PatientProgram.EnrollmentEndDate IS NULL
		    AND CONVERT(DATE,PatientProgram.EnrollmentStartDate) <> CONVERT(DATE,t.EventDischargedate)
		    AND p.PopulationDefinitionID = @i_PopulationDefinitionID
		END
		
		INSERT INTO PatientProgram (
			ProgramId
			,PatientID
			,EnrollmentStartDate
			,IsPatientDeclinedEnrollment
			,CreatedByUserId
			,StatusCode
			,DueDate
			,IsAutoEnrollment
			,IdentificationDate
			)
		SELECT DISTINCT p.ProgramId
			,clu.PatientID
			,CASE
			    WHEN @v_ADTType = 'A'  THEN  (SELECT MAX(pa.EventAdmitdate) FROM PatientADT pa WHERE pa.PatientId = clu.Patientid AND pa.EventAdmitdate IS NOT NULL AND pa.EventDischargedate IS NULL)
			    WHEN @v_ADTType = 'D'  THEN  (SELECT MAX(pa.EventDischargedate) FROM PatientADT pa WHERE pa.PatientId = clu.Patientid AND pa.EventDischargedate IS NOT NULL)
			    WHEN @v_ADTType IS NULL and p.AllowAutoEnrollment = 1 THEN @dt_date
			    ELSE NULL
			    END
			,0
			,@i_AppUserId
			,'A'
			,@dt_date + 5
			,1
			,clu.CreatedDate
		FROM PopulationDefinitionPatients clu
		INNER JOIN Program p
			ON clu.PopulationDefinitionID = P.PopulationDefinitionID
		WHERE p.PopulationDefinitionID = @i_PopulationDefinitionID
			AND clu.StatusCode = 'A'
			AND p.StatusCode = 'A'
			AND NOT EXISTS (
				SELECT 1
				FROM PatientProgram
				WHERE PatientProgram.PatientID = clu.PatientID
					AND PatientProgram.ProgramId = p.ProgramId
					AND PatientProgram.EnrollmentEndDate IS NULL
				)
				
		 ------------------------------------------------------------------------------------
		 CREATE TABLE #PatientPro
		 (
			ID int identity(1,1) ,
			ProgramId INT
		 ) 
		
		 INSERT INTO #PatientPro
		 (
			ProgramId
		 )
		 SELECT DISTINCT 
			p.ProgramId
		 FROM Program p
		 WHERE p.StatusCode = 'A'
		 AND P.PopulationDefinitionID = @i_PopulationDefinitionID
			
		 
		 DECLARE @i_MaxId INT = (SELECT MAX(ID) FROM #PatientPro),
				 @i_MinId INT = 1 ,
				 @i_ProgramID INT 
		 CREATE TABLE #Prov (UserID INT)
		 WHILE @i_MinId <= @i_MaxId
			BEGIN
				SELECT @i_ProgramID = ProgramID 
				FROM #PatientPro pp
				WHERE PP.ID = @i_MinId
				
				IF EXISTS (
							SELECT 1
							FROM ProgramCareTeam
							WHERE ProgramId = @i_ProgramID
							)
					BEGIN
						

						INSERT INTO #Prov
						SELECT DISTINCT ProviderID AS UserId
						FROM CareTeamMembers ctm
						INNER JOIN CareTeam ct
							ON ctm.CareTeamId = ct.CareTeamId
						INNER JOIN ProgramCareTeam pct
							ON pct.CareTeamId = ct.CareTeamId
						WHERE pct.ProgramId = @i_ProgramID
							AND ctm.StatusCode = 'A'
							AND ct.StatusCode = 'A'

						DECLARE @i_ProgramCnt INT
							,@i_ProviderCnt INT

						SELECT @i_ProgramCnt = COUNT(1)
						FROM PatientProgram
						WHERE ProgramId = @i_ProgramID
							AND ProviderID IS NULL

						SELECT @i_ProviderCnt = COUNT(*)
						FROM #Prov

						DECLARE @i_min INT

						SELECT @i_min = ISNULL(MIN(UserId), 0)
						FROM #Prov

						IF @i_ProviderCnt > 0
						BEGIN
							DECLARE @i_cnt INT

							SELECT @i_cnt = CEILING(CONVERT(DECIMAL(10, 2), @i_ProgramCnt) / CONVERT(DECIMAL(10, 2), @i_ProviderCnt))

							WHILE (@i_min) > 0
							BEGIN
								UPDATE PatientProgram
								SET ProviderID = @i_min
								FROM (
									SELECT TOP (@i_cnt) PatientProgramID UserProgramId
									FROM PatientProgram
									WHERE ProviderID IS NULL
										AND ProgramId = @i_ProgramID
									) x
								WHERE x.UserProgramId = PatientProgram.PatientProgramID
									AND ProviderID IS NULL

								DELETE
								FROM #Prov
								WHERE UserId = @i_min

								SELECT @i_min = isnull(MIN(UserId), 0)
								FROM #Prov
							END
						END
					END
					
				SET @i_MinId = @i_MinId + 1	
			END	
		 ------------------------------------------------------------------------------------   
			 
		IF @b_IsADT = 1
		    BEGIN
			   UPDATE u
			   SET u.PatientADTId = pa.PatientADTId
			   FROM PatientADT pa
			   INNER JOIN PatientProgram u
			   ON pa.PatientId = u.PatientID
			   INNER JOIN (SELECT p.ProgramId FROM Program p WHERE p.PopulationDefinitionID = @i_PopulationDefinitionID) p
			   ON p.ProgramId = u.ProgramID
			   WHERE 
			   u.EnrollmentStartDate = CASE WHEN @v_ADTType = 'A' THEN pa.EventAdmitdate
								       WHEN @v_ADTType = 'D' THEN pa.EventDischargedate
								  END	    	  
			   AND u.EnrollmentEndDate IS NULL
		    END		

		INSERT INTO ProgramPatientTaskConflict (
			ProgramTaskBundleId
			,PatientUserID
			,CreatedByUserId
			)
		SELECT DISTINCT ProgramTaskBundle.ProgramTaskBundleID
			,PatientProgram.PatientID
			,@i_AppUserId
		FROM PatientProgram
		INNER JOIN ProgramTaskBundle
			ON ProgramTaskBundle.ProgramID = PatientProgram.ProgramId
		INNER JOIN Program
			ON Program.ProgramId = PatientProgram.ProgramId
		WHERE Program.PopulationDefinitionID = @i_PopulationDefinitionID
			AND program.StatusCode = 'A'
			AND PatientProgram.StatusCode = 'A'
			AND ProgramTaskBundle.StatusCode = 'A'
			AND PatientProgram.PatientID IS NOT NULL
			AND ProgramTaskBundle.ProgramTaskBundleID IS NOT NULL
			AND PatientProgram.EnrollmentEndDate IS NULL
			AND NOT EXISTS (
				SELECT 1
				FROM ProgramPatientTaskConflict pptc
				WHERE pptc.ProgramTaskBundleId = ProgramTaskBundle.ProgramTaskBundleID
					AND pptc.PatientUserID = PatientProgram.PatientID
				)
	END
	/*
	ELSE
	BEGIN
		UPDATE PopulationDefinitionPatients
		SET StatusCode = 'P'
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		WHERE PopulationDefinitionID = @i_PopulationDefinitionID
			AND LeaveInList <> 1
	END
    */
	RETURN 0
END TRY

----------------------------------------------------------------------------       
BEGIN CATCH
	-- Handle exception      
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException

	--@i_UserId = @i_AppUserId    
	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinitionUsers_InsertByCriteria] TO [FE_rohit.r-ext]
    AS [dbo];

