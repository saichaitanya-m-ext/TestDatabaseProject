CREATE TYPE [dbo].[UserQuestionaireAnswersTbl] AS TABLE (
    [UserQuestionaireAnswersID] [dbo].[KeyID]               NULL,
    [UserQuestionaireID]        [dbo].[KeyID]               NULL,
    [QuestionSetQuestionId]     [dbo].[KeyID]               NULL,
    [AnswerID]                  [dbo].[KeyID]               NULL,
    [AnswerComments]            [dbo].[VeryLongDescription] NOT NULL,
    [AnswerString]              VARCHAR (50)                NULL);

