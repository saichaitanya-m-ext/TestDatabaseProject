
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_EpisodeGroupersAndDisease_Select 12,1,NULL
Description   : This procedrue is used to get the Groupersystem,grouperdisease,grouperstage,userepisodicgroup Hirarichal population data   
Created By    : Gurumoorthy.V
Created Date  : 08-05-2012
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_EpisodeGroupersAndDisease_Select] (
	@i_AppUserId KEYID
	,@i_GrouperSystemId KeyID = NULL
	,@i_GrouperDiseaseId KeyID = NULL
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

	IF (
			@i_GrouperSystemId IS NULL
			AND @i_GrouperDiseaseId IS NULL
			)
	BEGIN
		SELECT GrouperSystemId
			,NAME
		FROM Groupersystem WITH (NOLOCK)
	END
	ELSE
		IF (
				@i_GrouperSystemId IS NOT NULL
				AND @i_GrouperDiseaseId IS NULL
				)
		BEGIN
			SELECT GrouperDiseaseId
				,NAME
			FROM grouperdisease WITH (NOLOCK)
			WHERE GrouperSystemId = @i_GrouperSystemId
		END
		ELSE
			IF (
					@i_GrouperSystemId IS NULL
					AND @i_GrouperDiseaseId IS NOT NULL
					)
			BEGIN
				SELECT GrouperStageId
					,StageID
				FROM grouperstage WITH (NOLOCK)
				WHERE GrouperDiseaseId = @i_GrouperDiseaseId

				SELECT DxCAT
				FROM grouperdisease WITH (NOLOCK)
				WHERE GrouperDiseaseId = @i_GrouperDiseaseId
			END
END TRY

------------------------------------------------------------------------------------------------------------
BEGIN CATCH
	-- Handle exception        
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_EpisodeGroupersAndDisease_Select] TO [FE_rohit.r-ext]
    AS [dbo];

