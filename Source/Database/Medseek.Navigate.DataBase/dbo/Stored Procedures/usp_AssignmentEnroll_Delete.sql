
/*          
------------------------------------------------------------------------------          
Procedure Name: usp_AssignmentEnroll_Delete          
Description   : This procedure is used to delete the record from programQuestionaire,programCommunication table      
Created By    : Rathnam        
Created Date  : 17-Oct-2012
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
          
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_AssignmentEnroll_Delete] (
	@i_AppUserId KEYID
	,@i_QuestionaireId KEYID = NULL
	,@i_CommunicationTypeId KEYID = NULL
	,@i_TemplateId KEYID = NULL
	,@i_ProgramId KEYID
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

		IF @i_QuestionaireId IS NOT NULL
		BEGIN
			UPDATE ProgramQuestionaire
			SET StatusCode = 'I'
			WHERE ProgramID = @i_ProgramId
				AND QuestionaireId = @i_QuestionaireId
		END

		IF @i_CommunicationTypeId IS NOT NULL
		BEGIN
			UPDATE ProgramCommunication
			SET StatusCode = 'I'
			WHERE ProgramID = @i_ProgramId
				AND CommunicationTypeId = @i_CommunicationTypeId
				AND TemplateId = @i_TemplateId
		END
	END TRY

	--------------------------------------------------------           
	BEGIN CATCH
		-- Handle exception          
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_AssignmentEnroll_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

