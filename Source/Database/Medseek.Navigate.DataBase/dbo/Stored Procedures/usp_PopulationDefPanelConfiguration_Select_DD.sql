
/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_PopulationDefPanelConfiguration_Select_DD] 1,'Code Grouping',229
Description   : This procedure is used to get data from PopulationDefPanelConfiguration
Created By    : Gurumoorthy V
Created Date  : June-30-2012
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
08-08-2012 Rathnam added if else select statements for differenct population types  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefPanelConfiguration_Select_DD] (
	@i_AppUserId INT
	,@v_PopulationType VARCHAR(20) = 'Population'
	,@i_ProgramID KEYID = NULL
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

	-------------------------------------------------------- 
	IF @v_PopulationType = 'Population'
	BEGIN
		SELECT PopulationDefPanelConfigurationID
			,PanelorGroupName
			,ParentPanelID
		FROM PopulationDefPanelConfiguration WITH (NOLOCK)
		WHERE IsShow = 1
			AND PopulationType = @v_PopulationType
			AND sortorder IS NOT NULL
		ORDER BY SortOrder
	END
	ELSE
		IF @v_PopulationType = 'Program'
		BEGIN
			DECLARE @i_ProgramCount INT

			SELECT @i_ProgramCount = COUNT(*)
			FROM PatientProgram
			WHERE ProgramId = @i_ProgramID

			SELECT PopulationDefPanelConfigurationID
				,CASE 
					WHEN PanelorGroupName = 'Total Patients'
						THEN 'Total Patients (' + CONVERT(VARCHAR, @i_ProgramCount) + ')'
					ELSE PanelorGroupName
					END PanelorGroupName
			FROM PopulationDefPanelConfiguration WITH (NOLOCK)
			WHERE IsShow = 1
				AND PopulationType = @v_PopulationType
		END
		ELSE
			IF @v_PopulationType = 'TaskBundle'
			BEGIN
				SELECT PopulationDefPanelConfigurationID TaskBundleLibraryTreeID
					,PanelorGroupName NAME
					,ParentPanelID ParentID
					,(
						CASE 
							WHEN IsShow = 1
								THEN 'A'
							ELSE 'I'
							END
						) StatusCode
				FROM PopulationDefPanelConfiguration WITH (NOLOCK)
				WHERE IsShow = 1
					AND PopulationType = @v_PopulationType
				ORDER BY SortOrder
			END
			ELSE
				IF @v_PopulationType = 'Metrics'
				BEGIN
					SELECT PopulationDefPanelConfigurationID TaskBundleLibraryTreeID
						,PanelorGroupName NAME
						,(
							CASE 
								WHEN IsShow = 1
									THEN 'A'
								ELSE 'I'
								END
							) StatusCode
					FROM PopulationDefPanelConfiguration WITH (NOLOCK)
					WHERE IsShow = 1
						AND PopulationType = @v_PopulationType
					ORDER BY SortOrder
				END
				ELSE
					IF @v_PopulationType = 'Code Grouping'
					BEGIN
						SELECT PopulationDefPanelConfigurationID CodeGroupingID
							,PanelorGroupName NAME
							,PopulationDefPanelConfiguration.ParentPanelID
						FROM PopulationDefPanelConfiguration WITH (NOLOCK)
						WHERE IsShow = 1
							AND PopulationType = @v_PopulationType
						ORDER BY SortOrder
					END
					ELSE
						IF @v_PopulationType = 'Numerator'
						BEGIN
								;

							WITH NrCte
							AS (
								SELECT PopulationDefPanelConfigurationID
									,PanelorGroupName NAME
									,ParentPanelID
									,SortOrder
								FROM PopulationDefPanelConfiguration WITH (NOLOCK)
								WHERE IsShow = 1
									AND PopulationType = @v_PopulationType
								
								UNION
								
								SELECT PopulationDefPanelConfigurationID
									,PanelorGroupName NAME
									,ParentPanelID
									,2
								FROM PopulationDefPanelConfiguration WITH (NOLOCK)
								WHERE IsShow = 1
									AND PopulationType = 'Population'
									AND PanelorGroupName = 'Build Definition'
								)
							SELECT *
							FROM NrCte
							ORDER BY SortOrder
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
    ON OBJECT::[dbo].[usp_PopulationDefPanelConfiguration_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

