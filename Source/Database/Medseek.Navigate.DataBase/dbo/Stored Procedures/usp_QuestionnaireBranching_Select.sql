/*
-------------------------------------------------------------------------------------------------
Procedure Name: usp_QuestionnaireBranching_Select
Description	  : This procedure is used to get the branching detail for an answer
Created By    :	Pramod 
Created Date  : 22-Mar-2010
-------------------------------------------------------------------------------------------------
Log History   : 
DD-Mon-YYYY		BY			DESCRIPTION
-------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_QuestionnaireBranching_Select]
( @i_AppUserId KeyID,
  @i_QuestionnaireBranchingId KeyID
)
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
      BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
      END

------------ Selection from QuestionnaireBranching table table starts here ------------
      SELECT 
			 QuestionnaireBranching.QuestionnaireBranchingId,
			 QuestionnaireBranching.QuestionaireQuestionSetId,
			 QuestionnaireBranching.QuestionSetQuestionId,
			 QuestionnaireBranching.BranchingAnswerId,
			 QuestionnaireBranching.RecommendationId,
			 (SELECT QuestionaireID FROM QuestionaireQuestionSet
			   WHERE QuestionaireQuestionSetId = QuestionnaireBranching.BranchToQuestionaireQuestionSetId
			  ) AS BranchToQuestionaireID,
			 QuestionnaireBranching.BranchToQuestionaireQuestionSetId,
			 (SELECT QuestionSetID FROM QuestionSetQuestion
			   WHERE QuestionSetQuestionId = QuestionnaireBranching.BranchToQuestionSetQuestionsId
			 ) AS BranchToQuestionSetId,
			 QuestionnaireBranching.BranchToQuestionSetQuestionsId,
			 QuestionnaireBranching.QuestionSetBranchingOption,
             QuestionnaireBranching.Createdbyuserid,
             QuestionnaireBranching.CreatedDate,
             QuestionnaireBranching.LastModifiedByUserId,
		     QuestionnaireBranching.LastModifiedDate,
		     Question.QuestionText,
		     Answer.AnswerDescription
        FROM
             QuestionnaireBranching with (nolock) 
               INNER JOIN Answer with (nolock) 
                 ON QuestionnaireBranching.BranchingAnswerId = Answer.AnswerId
               INNER JOIN Question with (nolock) 
                 ON Answer.QuestionId = Question.QuestionId
        WHERE QuestionnaireBranching.QuestionnaireBranchingId = @i_QuestionnaireBranchingId 
    
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionnaireBranching_Select] TO [FE_rohit.r-ext]
    AS [dbo];

