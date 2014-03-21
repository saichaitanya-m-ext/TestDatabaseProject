CREATE FUNCTION [dbo].[GetMaxScoreByUserQuestionaireID]
(
  @i_UserQuestionaireId INT
)
RETURNS INT
AS
BEGIN
      DECLARE @i_return INT
      SELECT
          @i_return = SUM(Totaluq.score)
      FROM
          ( SELECT DISTINCT
                QuestionSetQuestionId
               ,uqa.AnswerID
               ,a.Score
            FROM
                UserQuestionaireAnswers uqa
            INNER JOIN Answer a
                ON a.AnswerId = uqa.AnswerID
            WHERE
                uqa.UserQuestionaireID = @i_UserQuestionaireId ) Totaluq

      RETURN @i_return
END
