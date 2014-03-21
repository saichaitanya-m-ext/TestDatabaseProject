
/*          
------------------------------------------------------------------------------          
Procedure Name: usp_AssignmentEnroll_Delete          
Description   : This procedure is used to retrive the record from programQuestionaire,programCommunication table      
Created By    : Rathnam        
Created Date  : 17-Oct-2012
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
          
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_AssignmentEnroll_Select] (
	@i_AppUserId KEYID
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

		SELECT pq.ProgramID
			,q.QuestionaireId
			,q.QuestionaireName
		FROM ProgramQuestionaire pq WITH (NOLOCK)
		INNER JOIN Questionaire q WITH (NOLOCK) ON q.QuestionaireId = pq.QuestionaireId
		WHERE pq.ProgramID = @i_ProgramId
			AND pq.StatusCode = 'A'

		SELECT pc.ProgramID
			,ct.CommunicationTypeId
			,ct.CommunicationType
			,cct.TemplateName
			,cct.CommunicationTemplateId
		FROM ProgramCommunication pc WITH (NOLOCK)
		INNER JOIN CommunicationType ct WITH (NOLOCK) ON pc.CommunicationTypeId = ct.CommunicationTypeId
		INNER JOIN CommunicationTemplate cct WITH (NOLOCK) ON cct.CommunicationTemplateId = pc.TemplateId
		WHERE pc.ProgramID = @i_ProgramId
			AND pc.StatusCode = 'A'
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
    ON OBJECT::[dbo].[usp_AssignmentEnroll_Select] TO [FE_rohit.r-ext]
    AS [dbo];

