
--select * from CohortListCriteria
/*PopulationDefinition
-----------------------------------------------------------------------------------
Procedure Name: [usp_PopulationDefPanelConfigurationByCohortID_Select] 64,137,17
Description   : This Procedure is used to get the Productivity report
Created By    : Kalyan	
Created Date  : 11-July-2012
-----------------------------------------------------------------------------------     
Log History   :
DD-MM-YYYY  BY   DESCRIPTION
14-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID

-----------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefPanelConfigurationByPopulationDefinitionID_Select] --64,64,2
	(
	@i_AppUserId KEYID
	,@i_PopulationDefinitionID KEYID
	,@i_PopulationDefPanelConfigurationID KEYID
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

	DECLARE @v_PanelorGroupName VARCHAR(100)
		,@v_CohortGeneralizedIdList VARCHAR(MAX)
		,@v_SQL VARCHAR(MAX)
		,@V_PopulationDefinitionCriteriaText VARCHAR(MAX)
		,@i_PopulationDefinitionCriteriaID INT

	IF EXISTS (
			SELECT 1
			FROM PopulationDefPanelConfiguration WITH (NOLOCK)
			INNER JOIN PopulationDefinitionCriteria WITH (NOLOCK) ON PopulationDefinitionCriteria.PopulationDefPanelConfigurationID = PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID
			WHERE PopulationDefinitionCriteria.PopulationDefinitionID = @i_PopulationDefinitionID
				AND PopulationDefinitionCriteria.PopulationDefPanelConfigurationID = @i_PopulationDefPanelConfigurationID
			)
	BEGIN
		SELECT --top 1
			@v_PanelorGroupName = PanelorGroupName
			,@v_CohortGeneralizedIdList = REPLACE(CohortGeneralizedIdList, ' ', '')
			,@V_PopulationDefinitionCriteriaText = PopulationDefinitionCriteriaText
			,@i_PopulationDefinitionCriteriaID = PopulationDefinitionCriteriaID
		FROM PopulationDefPanelConfiguration WITH (NOLOCK)
		INNER JOIN PopulationDefinitionCriteria WITH (NOLOCK) ON PopulationDefinitionCriteria.PopulationDefPanelConfigurationID = PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID
		WHERE PopulationDefinitionCriteria.PopulationDefinitionID = @i_PopulationDefinitionID
			AND PopulationDefinitionCriteria.PopulationDefPanelConfigurationID = @i_PopulationDefPanelConfigurationID

		IF @v_PanelorGroupName = 'Patient Information'
			OR @v_PanelorGroupName = 'Patient Demographics'
			OR @v_PanelorGroupName = 'Billing Encounter'
			OR @v_PanelorGroupName = 'Care Providers'
			OR @v_PanelorGroupName = 'Claims'
			OR @v_PanelorGroupName = 'Medical Codes'
			OR @v_PanelorGroupName = 'LOINC'
			OR @v_PanelorGroupName = 'Measures'
			OR @v_PanelorGroupName = 'Episode Groupers'
			OR @v_PanelorGroupName = 'Health Risk Scores'
			OR @v_PanelorGroupName = 'Insurance'
			OR @v_PanelorGroupName = 'Insurance Groups'
			OR @v_PanelorGroupName = 'Medical Encounters'
			OR @v_PanelorGroupName = 'Encounters'
			OR @v_PanelorGroupName = 'Questionnaire Scores and Answers'
			OR @v_PanelorGroupName = 'Risk Factors'
			OR @v_PanelorGroupName = 'Substance Abuse'
			OR @v_PanelorGroupName = 'Immunizations'
			OR @v_PanelorGroupName = 'Text'
			OR @v_PanelorGroupName = 'Allergies'
			OR @v_PanelorGroupName = 'Population Definitions Criteria'
			OR @v_PanelorGroupName = 'Accountability Criteria'
			OR @v_PanelorGroupName = 'Compound'
			AND @v_CohortGeneralizedIdList IS NULL
		BEGIN
			SELECT DISTINCT PopulationDefinitionCriteriaID
				,PopulationDefinitionCriteriaText
			FROM PopulationDefPanelConfiguration WITH (NOLOCK)
			INNER JOIN PopulationDefinitionCriteria WITH (NOLOCK) ON PopulationDefinitionCriteria.PopulationDefPanelConfigurationID = PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID
			WHERE PopulationDefinitionCriteria.PopulationDefinitionID = @i_PopulationDefinitionID
				AND PopulationDefinitionCriteria.PopulationDefPanelConfigurationID = @i_PopulationDefPanelConfigurationID
			ORDER BY PopulationDefinitionCriteriaID
		END
		ELSE
			IF @v_PanelorGroupName = 'Languages'
				AND @v_CohortGeneralizedIdList IS NOT NULL
			BEGIN
				SELECT @v_SQL = 'SELECT LanguageID,
								LanguageName
								FROM Language 
								WHERE LanguageID IN (' + @v_CohortGeneralizedIdList + ')'

				EXEC (@v_SQL)
			END
			ELSE
				IF @v_PanelorGroupName = 'Race'
					AND @v_CohortGeneralizedIdList IS NOT NULL
				BEGIN
					SELECT @v_SQL = 'SELECT RaceId,
									RaceName
									FROM Race 
									WHERE RaceId IN (' + @v_CohortGeneralizedIdList + ')'

					EXEC (@v_SQL)
				END
				ELSE
					IF @v_PanelorGroupName = 'Ethnicity'
						AND @v_CohortGeneralizedIdList IS NOT NULL
					BEGIN
						SELECT @v_SQL = 'SELECT EthnicityId,
									EthnicityName
									FROM Ethnicity 
									WHERE EthnicityId IN (' + @v_CohortGeneralizedIdList + ')'

						EXEC (@v_SQL)
					END
					ELSE
						IF @v_PanelorGroupName = 'City'
							AND @v_CohortGeneralizedIdList IS NOT NULL
						BEGIN
							SELECT @i_PopulationDefinitionCriteriaID PopulationDefinitionCriteriaID
								,KeyValue CityName
							FROM dbo.udf_SplitStringToTable(@v_CohortGeneralizedIdList, ',')
						END
						ELSE
							IF @v_PanelorGroupName = 'State'
								AND @v_CohortGeneralizedIdList IS NOT NULL
							BEGIN
								SELECT @v_SQL = 'SELECT StateCode,
											Name
											FROM State 
											WHERE StateCode IN (' + @v_CohortGeneralizedIdList + ')'

								EXEC (@v_SQL)
							END
							ELSE
								IF @v_PanelorGroupName = 'Zip Codes'
									AND @v_CohortGeneralizedIdList IS NOT NULL
								BEGIN
									SELECT @i_PopulationDefinitionCriteriaID PopulationDefinitionCriteriaID
										,KeyValue ZipCode
									FROM dbo.udf_SplitStringToTable(@v_CohortGeneralizedIdList, ',')
								END
								ELSE
									IF @v_PanelorGroupName = 'Care Teams'
										AND @v_CohortGeneralizedIdList IS NOT NULL
									BEGIN
										SELECT @v_SQL = 'SELECT 
													CareTeamId,
													CareTeamName
												FROM CareTeam
												WHERE CareTeamId IN (' + @v_CohortGeneralizedIdList + ')'

										EXEC (@v_SQL)
									END
									ELSE
										IF @v_PanelorGroupName = 'Clinics'
											AND @v_CohortGeneralizedIdList IS NOT NULL
										BEGIN
											SELECT @v_SQL = 'SELECT 
														OrganizationId,
														OrganizationName
													FROM Organization
													WHERE OrganizationId IN (' + @v_CohortGeneralizedIdList + ')'

											EXEC (@v_SQL)
										END
										ELSE
											IF @v_PanelorGroupName = 'Providers'
												AND @v_CohortGeneralizedIdList IS NOT NULL
											BEGIN
												SELECT @v_SQL = 'SELECT 
															UserID,
															COALESCE(ISNULL(Users.LastName , '''') + '', ''   
															+ ISNULL(Users.FirstName , '''') + ''. ''   
															+ ISNULL(Users.MiddleName , '''') + '' ''
															+ ISNULL(Users.UserNameSuffix ,'''')  
														  ,'''')
													   AS FullName
														FROM Users
														WHERE UserID IN (' + @v_CohortGeneralizedIdList + ')'

												EXEC (@v_SQL)
											END
											ELSE
												IF @v_PanelorGroupName = 'Programs'
													AND @v_CohortGeneralizedIdList IS NOT NULL
												BEGIN
													SELECT @v_SQL = 'SELECT 
															ProgramId,
															ProgramName
														FROM Program
														WHERE ProgramId IN (' + @v_CohortGeneralizedIdList + ')'

													EXEC (@v_SQL)
												END
												ELSE
													IF @v_PanelorGroupName = 'Medication'
														AND @v_CohortGeneralizedIdList IS NOT NULL
													BEGIN
														SELECT @v_SQL = 'SELECT 
																DrugCode,
																DrugName
															FROM CodeSetDrug
															WHERE DrugCodeId IN (' + @v_CohortGeneralizedIdList + ')'

														EXEC (@v_SQL)
													END
													ELSE
														IF @v_PanelorGroupName = 'Therapeutic Classes'
															AND @v_CohortGeneralizedIdList IS NOT NULL
														BEGIN
															SELECT @v_SQL = 'SELECT 
																	TherapeuticID,
																	Name
																FROM TherapeuticClass
																WHERE TherapeuticID IN (' + @v_CohortGeneralizedIdList + ')'

															EXEC (@v_SQL)
														END
														ELSE
															IF @v_PanelorGroupName = 'ICD Codes'
																AND @v_CohortGeneralizedIdList IS NOT NULL
															BEGIN
																SELECT @v_SQL = 'SELECT 
																		ICDCode,
																		ICDDescription
																	FROM CodeSetICD
																	WHERE ICDCodeId IN (' + @v_CohortGeneralizedIdList + ')'

																EXEC (@v_SQL)
															END
															ELSE
																IF @v_PanelorGroupName = 'CPT Codes'
																	AND @v_CohortGeneralizedIdList IS NOT NULL
																BEGIN
																	SELECT @v_SQL = 'SELECT 
																			ProcedureCode,
																			ProcedureName
																		FROM CodeSetProcedure
																		WHERE ProcedureId IN (' + @v_CohortGeneralizedIdList + ')'

																	EXEC (@v_SQL)
																END
																ELSE
																	IF @v_PanelorGroupName = 'Employer Groups'
																		AND @v_CohortGeneralizedIdList IS NOT NULL
																	BEGIN
																		SELECT @v_SQL = 'SELECT 
																			GroupNumber,
																			GroupName
																		FROM EmployerGroup
																		WHERE EmployerGroupID IN (' + @v_CohortGeneralizedIdList + ')'

																		EXEC (@v_SQL)
																	END
																	ELSE
																		IF @v_PanelorGroupName = 'Questionnaires'
																			AND @v_CohortGeneralizedIdList IS NOT NULL
																		BEGIN
																			SELECT @v_SQL = 'SELECT 
																				QuestionaireId,
																				QuestionaireName
																			FROM Questionaire
																			WHERE QuestionaireId IN (' + @v_CohortGeneralizedIdList + ')'

																			EXEC (@v_SQL)
																		END
																		ELSE
																			IF @v_PanelorGroupName = 'Medical History'
																				AND @v_CohortGeneralizedIdList IS NOT NULL
																			BEGIN
																				SELECT @v_SQL = 'SELECT Distinct
																		  MedicalConditionID,
																		  Disease.Name + '' ''+ ''(''+ISNULL(Condition,'''')+'')'' AS Condition
																	  FROM
																		  MedicalCondition WITH(NOLOCK)
																	  INNER JOIN Disease WITH(NOLOCK)
																		  ON Disease.DiseaseId = MedicalCondition.DiseaseId    
																	  WHERE
																		  MedicalCondition.StatusCode = ''A''
																	  AND Disease.StatusCode = ''A''
																	  and MedicalConditionID IN (' + @v_CohortGeneralizedIdList + ')    
																	  ORDER BY
																		  Condition'

																				--print @v_SQL
																				EXEC (@v_SQL)
																			END
																			ELSE
																				IF @v_PanelorGroupName = 'Obstetrical History'
																					AND @v_CohortGeneralizedIdList IS NOT NULL
																				BEGIN
																					SELECT @v_SQL = 'SELECT 
																						ObstetricalConditionsID,
																						ObstetricalName
																					FROM ObstetricalConditions
																					WHERE ObstetricalConditionsID IN (' + @v_CohortGeneralizedIdList + ')'

																					EXEC (@v_SQL)
																				END
																				ELSE
																					IF @v_PanelorGroupName = 'Previous Exams and Lab Findings'
																						AND @v_CohortGeneralizedIdList IS NOT NULL
																					BEGIN
																						SELECT @v_SQL = 'SELECT 
																						LabOrPhysicalExaminationID,
																						Name
																					FROM LabOrPhysicalExamination
																					WHERE LabOrPhysicalExaminationID IN (' + @v_CohortGeneralizedIdList + ')'

																						EXEC (@v_SQL)
																					END
																					ELSE
																						IF @v_PanelorGroupName = 'Family History'
																							AND @v_CohortGeneralizedIdList IS NOT NULL
																						BEGIN
																							SELECT @v_SQL = 'SELECT 
																							DiseaseId,
																							Name
																						FROM Disease
																						WHERE DiseaseId IN (' + @v_CohortGeneralizedIdList + ')'

																							EXEC (@v_SQL)
																						END
																						ELSE
																							IF @v_PanelorGroupName = 'Health Barriers'
																								OR @v_PanelorGroupName = 'Health Indicators'
																								AND @v_CohortGeneralizedIdList IS NOT NULL
																							BEGIN
																								SELECT @v_SQL = 'SELECT 
																								HealthIndicatorsAndBarriersId,
																								Name 
																							FROM HealthIndicatorsAndBarriers 
																							WHERE HealthIndicatorsAndBarriersId IN (' + @v_CohortGeneralizedIdList + ')'

																								EXEC (@v_SQL)
																							END

		SELECT --top 1
			DISTINCT PopulationDefinitionCriteriaID
		FROM PopulationDefPanelConfiguration WITH (NOLOCK)
		INNER JOIN PopulationDefinitionCriteria WITH (NOLOCK) ON PopulationDefinitionCriteria.PopulationDefPanelConfigurationID = PopulationDefPanelConfiguration.PopulationDefPanelConfigurationID
		WHERE PopulationDefinitionCriteria.PopulationDefinitionID = @i_PopulationDefinitionID
			AND PopulationDefinitionCriteria.PopulationDefPanelConfigurationID = @i_PopulationDefPanelConfigurationID
		ORDER BY PopulationDefinitionCriteriaID
	END
END TRY

BEGIN CATCH
	-- Handle exception        
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefPanelConfigurationByPopulationDefinitionID_Select] TO [FE_rohit.r-ext]
    AS [dbo];

