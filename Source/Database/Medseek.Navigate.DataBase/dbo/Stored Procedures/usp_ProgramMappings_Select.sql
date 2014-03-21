
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_ProgramMappings_Select]1,41
Description   : This Procedure is used to get data from Program
Created By    : P.V.P.MOhan
Created Date  : 13-Aug-2012
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
16-Aug-2012 Rathnam Corrected all the selectstatements
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers
19-Nov-2012 P.V.P.Mohan changed parameters and added PatientID in 
            the place of UserID 
------------------------------------------------------------------------------    
usp_ProgramMappings_Select 2,224
*/
CREATE PROCEDURE [dbo].[usp_ProgramMappings_Select] --64,229
	(
	@i_AppUserId KEYID
	,@i_ProgramId KEYID
	)
AS
BEGIN TRY
	SET NOCOUNT ON

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

	EXEC usp_PopulationDefPanelConfiguration_Select_DD @i_AppUserId
		,'program'
		,@i_ProgramId

	DECLARE @i_PopulationPanelID INT
		,@i_TaskBundlePanelID INT
		,@i_DiseasePanelID INT
		,@i_MeasurePanelID INT
		,@i_PatientPanelID INT

	SELECT @i_PopulationPanelID = PopulationDefPanelConfigurationID
	FROM PopulationDefPanelConfiguration
	WHERE PopulationType = 'program'
		AND PanelorGroupName = 'Population Definitation'

	SELECT @i_TaskBundlePanelID = PopulationDefPanelConfigurationID
	FROM PopulationDefPanelConfiguration
	WHERE PopulationType = 'program'
		AND PanelorGroupName = 'Task bundle'

	SELECT @i_DiseasePanelID = PopulationDefPanelConfigurationID
	FROM PopulationDefPanelConfiguration
	WHERE PopulationType = 'program'
		AND PanelorGroupName = 'Program Disease'

	SELECT @i_MeasurePanelID = PopulationDefPanelConfigurationID
	FROM PopulationDefPanelConfiguration
	WHERE PopulationType = 'program'
		AND PanelorGroupName = 'Measure Ranges'

	SELECT @i_PatientPanelID = PopulationDefPanelConfigurationID
	FROM PopulationDefPanelConfiguration
	WHERE PopulationType = 'program'
		AND PanelorGroupName = 'Total Patients'

	SELECT DISTINCT pd.ProgramId
		,d.DiseaseId ID
		,d.NAME NAME
		,@i_DiseasePanelID PanelID
	FROM ProgramDisease pd WITH (NOLOCK)
	INNER JOIN Disease d WITH (NOLOCK) ON d.DiseaseId = pd.DiseaseID
	WHERE pD.ProgramId = @i_ProgramId

	SELECT DISTINCT lm.ProgramId
		,m.MeasureId ID
		,m.NAME NAME
		,@i_MeasurePanelID PanelID
	FROM LabMeasure lm WITH (NOLOCK)
	INNER JOIN Measure m WITH (NOLOCK) ON lm.MeasureId = m.MeasureId
	WHERE lm.ProgramId = @i_ProgramId

	SELECT ptb.ProgramId
		,ptb.TaskBundleID ID
		,tb.TaskBundleName NAME
		,@i_TaskBundlePanelID PanelID
	FROM ProgramTaskBundle ptb WITH (NOLOCK)
	INNER JOIN TaskBundle tb WITH (NOLOCK) ON ptb.TaskBundleID = tb.TaskBundleId
	WHERE ptb.ProgramID = @i_ProgramId

	SELECT pcl.ProgramId
		,cl.PopulationDefinitionId ID
		,cl.PopulationDefinitionName NAME
		,@i_PopulationPanelID PanelID
	FROM ProgramCohortList pcl WITH (NOLOCK)
	INNER JOIN PopulationDefinition cl WITH (NOLOCK) ON pcl.PopulationDefinitionID = cl.PopulationDefinitionId
	WHERE pcl.ProgramId = @i_ProgramId

	SELECT up.ProgramId
		,p.PatientID ID
		,p.FullName NAME
		,@i_PatientPanelID PanelID
	FROM Patients p WITH (NOLOCK)
	INNER JOIN PatientProgram up WITH (NOLOCK) ON P.PatientID = up.PatientID
	WHERE up.ProgramId = @i_ProgramId
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
    ON OBJECT::[dbo].[usp_ProgramMappings_Select] TO [FE_rohit.r-ext]
    AS [dbo];

