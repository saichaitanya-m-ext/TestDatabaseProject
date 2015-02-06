
/*    
---------------------------------------------------------------------------------------    
Procedure Name: usp_PopulationDefinition_Insert 
Description   : This procedure is used to Insert the PopulationDefinition data  
Created By    : NagaBabu  
Created Date  : 16-AUG-2011    
---------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
16-AUG-2011 Gurumoorthy.V Added Parameters(CareTeamID,CareTeamOption)in insert statement
16-Aug-2011 NagaBabu Added script for sending internal Messages to CareteamManagers in a specific careteam
18-Aug-2011	Gurumoorthy.V Removed script for sending internal Messages to CareteamManagers in a specific careteam
08-Aug-2012 Rathnam added @b_IsDiseaseDefinition,@i_DiseaseID
18-Aug-2012 Gurumoorthy Added @b_IsDiseaseDefinition and @i_DiseaseID paramenters,Removed the CareTeam and Careteamoptions
30-Aug-2012 Rathnam added IsForPopulationReport parameter
16-Oct-2012 Rathnam added @b_IsPrimary parameter
06-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added 
---------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinition_Insert] (
	@i_AppUserId KeyID
	,@vc_PopulationDefinitionName ShortDescription
	,@vc_PopulationDefinitionDescription LongDescription
	,@dt_LastDateListGenerated Userdate
	,@vc_StatusCode Statuscode
	,@b_RefreshPatientListDaily IsIndicator
	,@i_StandardsId KeyId = NULL
	,@b_NonModifiable ISINDICATOR = NULL
	,@b_Private ISINDICATOR = NULL
	,@i_StandardOrganizationId KeyId = NULL
	,@v_ProductionStatus VARCHAR(1) = NULL
	,@vc_DefinitionType VARCHAR(1) = NULL
	,@vc_NumeratorType VARCHAR(1) = NULL
	,@i_ConditionId KEYID = NULL
	,@o_PopulationDefinitionID KEYID OUTPUT
	,@i_IsDisplayInHomePage BIT = NULL 
	,@b_IsADT ISINDICATOR = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsInserted INT

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

	INSERT INTO PopulationDefinition (
		PopulationDefinitionName
		,PopulationDefinitionDescription
		,LastDateListGenerated
		,StatusCode
		,RefreshPatientListDaily
		,CreatedByUserId
		,NonModifiable
		,StandardsId
		,Private
		,StandardOrganizationId
		,ProductionStatus
		,DefinitionType
		,NumeratorType
		,ConditionId
		,IsDisplayInHomePage
		,IsADT
		)
	VALUES (
		@vc_PopulationDefinitionName
		,@vc_PopulationDefinitionDescription
		,@dt_LastDateListGenerated
		,@vc_StatusCode
		,@b_RefreshPatientListDaily
		,@i_AppUserId
		,@b_NonModifiable
		,CASE 
			WHEN @i_StandardsId = 0
				THEN NULL
			ELSE @i_StandardsId
			END
		,@b_Private
		,CASE 
			WHEN @i_StandardOrganizationId = 0
				THEN NULL
			ELSE @i_StandardOrganizationId
			END
		,@v_ProductionStatus
		,@vc_DefinitionType
		,@vc_NumeratorType
		,@i_ConditionId
		,@i_IsDisplayInHomePage
		,@b_IsADT
		)

	SELECT @o_PopulationDefinitionID = SCOPE_IDENTITY()
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
    ON OBJECT::[dbo].[usp_PopulationDefinition_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

