
/*  
-----------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_PopulationDefinition_Update]  
Description   : This procedure is used to update the data into PopulationDefinition  
Created By    : NagaBabu  
Created Date  : 27-May-2010  
------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
25-Sep-10 Pramod Modified the SP to correct @i_numberOfRecordsUpdated > 0 to <> 1
16-AUG-2011 Gurumoorthy.V Added Parameters(CareTeamID,CareTeamOption)in Update statement
16-Aug-2011 NagaBabu Added script for sending internal Mess	ages to CareteamManagers in a specific careteam
18-Aug-2011 Gurumoorthy V included If condition(@i_CareTeamID IS NOT NULL AND @c_CareTeamOption = 'A') in update statement 
19-Dec-2011 Rathnam added DELETE FROM CohortListUsers WHERE CohortListId = @i_CohortListId for inactive users
09-Apr-2012	Gurumoorthy.V Commented CohortListName = @vc_CohortListName in Update Statement
18-Aug-2012 Gurumoorthy Added @b_IsDiseaseDefinition and @i_DiseaseID paramenters,Removed the CareTeam and Careteamoptions
30-Aug-2012 Rathnam added IsForPopulationReport parameter
16-Oct-2012 Rathnam added @b_IsPrimary parameter
06-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added 
------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinition_Update] (
	@i_AppUserId KeyID
	,@vc_PopulationDefinitionName ShortDescription
	,@vc_PopulationDefinitionDescription LongDescription
	,@dt_LastDateListGenerated Userdate
	,@vc_StatusCode Statuscode
	,@b_RefreshPatientListDaily IsIndicator
	,@b_NonModifiable ISINDICATOR = NULL
	,@i_StandardsId KeyId = NULL
	,@b_Private ISINDICATOR = NULL
	,@i_StandardOrganizationId KeyId = NULL
	,@v_ProductionStatus VARCHAR(1) = NULL
	,@vc_DefinitionType VARCHAR(1) = NULL
	,@vc_NumeratorType VARCHAR(1) = NULL
	,@i_ConditionId KEYID = NULL
	,@i_PopulationDefinitionID KEYID
	,@i_IsDisplayInHomePage BIT = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	-- Check if valid Application User ID is passed  
	DECLARE @i_numberOfRecordsUpdated INT

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

	------------    Updation operation takes place   --------------------------  
	UPDATE PopulationDefinition
	SET PopulationDefinitionName = @vc_PopulationDefinitionName
		,PopulationDefinitionDescription = @vc_PopulationDefinitionDescription
		,LastDateListGenerated = @dt_LastDateListGenerated
		,StatusCode = @vc_StatusCode
		,RefreshPatientListDaily = @b_RefreshPatientListDaily
		,LastModifiedByUserId = @i_AppUserId
		,LastModifiedDate = GETDATE()
		,NonModifiable = @b_NonModifiable
		,StandardsId = @i_StandardsId
		,Private = @b_Private
		,StandardOrganizationId = @i_StandardOrganizationId
		,ProductionStatus = @v_ProductionStatus
		,NumeratorType = @vc_NumeratorType
		,ConditionId = @i_ConditionId
		,DefinitionType = @vc_DefinitionType
		,IsDisplayInHomePage = @i_IsDisplayInHomePage
	WHERE PopulationDefinitionID = @i_PopulationDefinitionID
END TRY

------------ Exception Handling --------------------------------  
BEGIN CATCH
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinition_Update] TO [FE_rohit.r-ext]
    AS [dbo];

