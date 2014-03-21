/*                
------------------------------------------------------------------------------                
Function Name: ufn_QuestionEditStatus          
Description   : This Function is used to find if the question is editable or not
Created By    : Pramod                
Created Date  : 01-July-2010                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                

------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_QuestionEditStatus]
(
  @i_QuestionId KEYID
)
RETURNS BIT
AS
BEGIN
      DECLARE
          @i_QuestionUsageCount INT ,
          @i_ReturnValue BIT

      SELECT
          @i_QuestionUsageCount = COUNT(*)
      FROM
          QuestionSetQuestion
      WHERE
          QuestionId = @i_QuestionId

      SELECT
          @i_QuestionUsageCount = @i_QuestionUsageCount + COUNT(*)
      FROM
          QuestionnaireBranching
      WHERE
          EXISTS ( SELECT
                       1
                   FROM
                       QuestionSetQuestion
                   WHERE
                       QuestionSetQuestion.QuestionId = @i_QuestionId
                   AND QuestionSetQuestion.QuestionSetQuestionId = QuestionnaireBranching.BranchToQuestionSetQuestionsId
                 )

      IF @i_QuestionUsageCount > 1
          SET @i_ReturnValue = 0  -- Cannot edit
      ELSE
           SET @i_ReturnValue = 1 -- Can edit

      RETURN @i_ReturnValue
END
