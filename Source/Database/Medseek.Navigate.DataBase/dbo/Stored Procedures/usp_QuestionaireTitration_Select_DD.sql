
/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_QuestionaireTitration_Select_DD]
Description   : This procedure is used to get the list of all TitrationQuestionaire Names.
Created By    : NagaBabu
Created Date  : 25-Jan-2012 
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_QuestionaireTitration_Select_DD] (@i_AppUserId INT)
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
	WHERE QuestionaireType.QuestionaireTypeName = 'Medication Titration'
		AND Questionaire.StatusCode = 'A'
		AND QuestionaireType.StatusCode = 'A'
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
    ON OBJECT::[dbo].[usp_QuestionaireTitration_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

