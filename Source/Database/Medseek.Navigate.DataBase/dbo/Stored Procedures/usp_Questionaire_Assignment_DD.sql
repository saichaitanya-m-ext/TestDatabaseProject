
/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_Questionaire_Assignment_DD]  
Description   : This procedure is used to get the list of all active Questionaire Names.
Created By    : Rathnam
Created Date  : 17-Oct-2012
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Questionaire_Assignment_DD] (
	@i_AppUserId INT
	,@i_ProgramID INT
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

	--------------- Select all active Questionaire Names -------------
	SELECT QuestionaireId
		,QuestionaireName
	FROM Questionaire WITH (NOLOCK)
	INNER JOIN QuestionaireType WITH (NOLOCK) ON Questionaire.QuestionaireTypeId = QuestionaireType.QuestionaireTypeId
	WHERE Questionaire.StatusCode = 'A'
		AND QuestionaireType.StatusCode = 'A'
		AND NOT EXISTS (
			SELECT 1
			FROM ProgramTaskBundle ptb
			WHERE ptb.GeneralizedID = Questionaire.QuestionaireId
				AND ptb.TaskType = 'Q'
				AND ptb.ProgramID = @i_ProgramID
			)
	ORDER BY QuestionaireName
END TRY

----------------------------------------------------------   
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Questionaire_Assignment_DD] TO [FE_rohit.r-ext]
    AS [dbo];

