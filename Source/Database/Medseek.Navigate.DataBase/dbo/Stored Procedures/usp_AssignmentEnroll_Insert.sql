
/*          
------------------------------------------------------------------------------          
Procedure Name: usp_AssignmentEnroll_Insert          
Description   : This procedure is used to insert record into ProgramQuestionaire,ProgramCommunication table      
Created By    : Mohan        
Created Date  : 17-Oct-2012
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
          
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_AssignmentEnroll_Insert] (
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
			IF EXISTS (
					SELECT 1
					FROM ProgramQuestionaire
					WHERE QuestionaireId = @i_QuestionaireId
						AND ProgramId = @i_ProgramId
						AND StatusCode = 'I'
					)
			BEGIN
				UPDATE ProgramQuestionaire
				SET StatusCode = 'A'
				WHERE ProgramId = @i_ProgramId
					AND QuestionaireId = @i_QuestionaireId
			END
			ELSE
			BEGIN
				INSERT INTO ProgramQuestionaire (
					ProgramId
					,QuestionaireId
					,CreatedByUserId
					)
				VALUES (
					@i_ProgramId
					,@i_QuestionaireId
					,@i_AppUserId
					)
			END
		END

		IF @i_CommunicationTypeId IS NOT NULL
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM ProgramCommunication
					WHERE ProgramId = @i_ProgramId
						AND CommunicationTypeId = @i_CommunicationTypeId
						AND TemplateId = @i_TemplateId
						AND StatusCode = 'I'
					)
			BEGIN
				UPDATE ProgramCommunication
				SET StatusCode = 'A'
				WHERE ProgramId = @i_ProgramId
					AND CommunicationTypeId = @i_CommunicationTypeId
					AND TemplateId = @i_TemplateId
			END
			ELSE
			BEGIN
				INSERT INTO ProgramCommunication (
					ProgramId
					,CommunicationTypeId
					,TemplateId
					,StatusCode
					,CreatedByUserId
					,CreatedDate
					)
				VALUES (
					@i_ProgramId
					,@i_CommunicationTypeId
					,@i_TemplateId
					,'A'
					,@i_AppUserId
					,GETDATE()
					)
			END
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
    ON OBJECT::[dbo].[usp_AssignmentEnroll_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

