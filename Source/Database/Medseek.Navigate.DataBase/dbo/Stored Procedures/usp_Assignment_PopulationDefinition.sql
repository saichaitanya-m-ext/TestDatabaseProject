
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Assignment_PopulationDefinition]1,10
Description   : This procedure is used to get the details of population definition
Created By    : Rathnam
Created Date  : 27.09.2012  
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
14-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID 
14-Mar-2013 P.V.P.Mohan  changed parameters and added PatientProgram table in place of UserProgram 
21-Jan-2014 P.V.P.Mohan  changed PatientProgam to PatientProgram
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Assignment_PopulationDefinition] (
	@i_AppUserId INT
	,@i_PopulationDefinitionID INT = NULL
	,@i_ProgramID INT = NULL
	)
AS
BEGIN
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

		IF @i_PopulationDefinitionID IS NOT NULL
			AND @i_ProgramID IS NOT NULL
		BEGIN
			DECLARE @l_TranStarted BIT = 0

			IF (@@TRANCOUNT = 0)
			BEGIN
				BEGIN TRANSACTION

				SET @l_TranStarted = 1 -- Indicator for start of transactions
			END
			ELSE
			BEGIN
				SET @l_TranStarted = 0
			END

			UPDATE Program
			SET LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
				,PopulationDefinitionID = @i_PopulationDefinitionID
			WHERE ProgramId = @i_ProgramId

			DECLARE @dt_date DATETIME = GETDATE()

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
				,clu.PatientID AS UserID
				,CASE
					WHEN pd.ADTType = 'A'  THEN  (SELECT MAX(EventAdmitdate) FROM PatientADT pa WHERE pa.PatientId = clu.Patientid AND pa.EventAdmitdate IS NOT NULL AND pa.EventDischargedate IS NULL)
					WHEN pd.ADTType = 'D'  THEN  (SELECT MAX(pa.EventDischargedate) FROM PatientADT pa WHERE pa.PatientId = clu.Patientid AND pa.EventDischargedate IS NOT NULL)
					WHEN pd.ADTType IS NULL and p.AllowAutoEnrollment = 1 THEN @dt_date
					ELSE NULL
					END
				,0
				,@i_AppUserId
				,'A'
				,@dt_date + 5
				,CASE 
					WHEN p.AllowAutoEnrollment = 1
						THEN 1
					ELSE 0
					END
				,clu.CreatedDate
			FROM PopulationDefinitionPatients clu
			INNER JOIN Program p
				ON clu.PopulationDefinitionID = P.PopulationDefinitionID
			INNER JOIN PopulationDefinition pd	
			     ON pd.PopulationDefinitionID = p.PopulationDefinitionID
			WHERE ProgramId = @i_ProgramId
				AND clu.StatusCode = 'A'
				AND NOT EXISTS (
					SELECT 1
					FROM PatientProgram ups
					WHERE ups.ProgramId = p.ProgramId
						AND ups.PatientID = clu.PatientID
						AND ups.EnrollmentEndDate IS NULL
					)
					
			DECLARE @b_IsADT bit, @v_ADTType VARCHAR(1)
			SELECT @b_IsADT = pd.IsADT, @v_ADTType = pd.ADTtype FROM PopulationDefinition pd WITH(NOLOCK)
			INNER JOIN Program p WITH(NOLOCK)
			ON PD.PopulationDefinitionID = P.PopulationDefinitionID
			WHERE p.ProgramId = @i_ProgramID		
			 
			IF @b_IsADT = 1
			    BEGIN
				   UPDATE PatientProgram
				   SET PatientProgram.PatientADTId = pa.PatientADTId
				   FROM PatientADT pa
				   WHERE pa.PatientId = PatientProgram.PatientID
				   AND PatientProgram.ProgramID = @i_ProgramID
				   AND PatientProgram.EnrollmentStartDate = CASE WHEN @v_ADTType = 'A' THEN pa.EventAdmitdate
													    WHEN @v_ADTType = 'D' THEN pa.EventDischargedate
												    END	    	  
				   AND PatientProgram.EnrollmentEndDate IS NULL
			    END
			
			 
			IF EXISTS (
					SELECT 1
					FROM ProgramCareTeam
					WHERE ProgramId = @i_ProgramID
					)
			BEGIN
				CREATE TABLE #Prov (UserID INT)

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

			IF (@l_TranStarted = 1) -- If transactions are there, then commit
			BEGIN
				SET @l_TranStarted = 0

				COMMIT TRANSACTION
			END
		END
		ELSE
		BEGIN
			IF @i_PopulationDefinitionID IS NULL
			BEGIN
				SELECT @i_PopulationDefinitionID = PopulationDefinitionID
				FROM Program
				WHERE ProgramId = @i_ProgramID
			END

			DECLARE @v_PopulationDefinitionCriteriaSQL VARCHAR(MAX)
				,@v_CohortCriteriaSQLTemp VARCHAR(MAX)

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

			SELECT PopulationDefinitionCriteriaID
				,PopulationDefinition.PopulationDefinitionID
				,PopulationDefinition.PopulationDefinitionName
				,XMLDefenition
				,ISNULL(@v_PopulationDefinitionCriteriaSQL, PopulationDefinitionCriteriaSQL) PopulationDefinitionCriteriaSQL
				,PopulationDefinitionCriteriaText
			FROM PopulationDefinitionCriteria
			INNER JOIN PopulationDefinition
				ON PopulationDefinition.PopulationDefinitionID = PopulationDefinitionCriteria.PopulationDefinitionID
			INNER JOIN PopulationDefPanelConfiguration
				ON PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID = PopulationDefinitionCriteria.PopulationDefPanelConfigurationID
			WHERE PanelorGroupName = 'Build Definition'
				AND PopulationDefinition.PopulationDefinitionID = @i_PopulationDefinitionID
		END
	END TRY

	BEGIN CATCH
		---------------------------------------------------------------------------------------------------------------------------  
		-- Handle exception  
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Assignment_PopulationDefinition] TO [FE_rohit.r-ext]
    AS [dbo];

