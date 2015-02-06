
/*    
--------------------------------------------------------------------------------------------------------------    
Procedure Name: [usp_QuestionsAndAnswers_ByQuestionaire]    
Description   : This Proc is used to get the Questions & Answers for a particular question by questionaireID
Created By    : Rathnam
Created Date  : 10-Oct-2011  
---------------------------------------------------------------------------------------------------------------    
Log History   :     
DD-Mon-YYYY  BY  DESCRIPTION  
---------------------------------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_QuestionsAndAnswers_ByQuestionaire] --1,41,27
	(
	@i_AppUserId KEYID
	,@i_QuestionaireID KEYID
	,@i_QuestionID KEYID = NULL
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

	IF @i_QuestionID IS NULL
	BEGIN
		SELECT DISTINCT q.QuestionId
			,q.Description
		FROM QuestionaireQuestionSet qqa
		INNER JOIN QuestionSetQuestion qsq ON qqa.QuestionSetId = qsq.QuestionSetId
			AND qsq.StatusCode = 'A'
			AND qqa.StatusCode = 'A'
		INNER JOIN Question q ON q.QuestionId = qsq.QuestionId
			AND q.StatusCode = 'A'
		WHERE qqa.QuestionaireId = @i_QuestionaireID

		SELECT QuestionnaireScoringID
			,CONVERT(VARCHAR, RangeStartScore) + ' - ' + CONVERT(VARCHAR, RangeEndScore) + '  ' + RangeName AS RangeName
			,RangeDescription
		FROM QuestionnaireScoring
		WHERE (
				QuestionaireId = @i_QuestionaireID
				OR @i_QuestionaireID IS NULL
				)
	END
	ELSE
	BEGIN
		SELECT AnswerID
			,AnswerDescription
		FROM Answer
		WHERE QuestionId = @i_QuestionID
			AND Answer.StatusCode = 'A'
	END
END TRY

BEGIN CATCH
	----------------------------------------------------------------------------------------------------------   
	-- Handle exception    
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionsAndAnswers_ByQuestionaire] TO [FE_rohit.r-ext]
    AS [dbo];

