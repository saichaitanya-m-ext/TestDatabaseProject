CREATE TABLE [dbo].[UserQuestionaireAnswers] (
    [UserQuestionaireAnswersID] [dbo].[KeyID]               IDENTITY (1, 1) NOT NULL,
    [UserQuestionaireID]        [dbo].[KeyID]               NOT NULL,
    [QuestionSetQuestionId]     [dbo].[KeyID]               NOT NULL,
    [AnswerID]                  [dbo].[KeyID]               NULL,
    [AnswerComments]            [dbo].[VeryLongDescription] NULL,
    [AnswerString]              VARCHAR (50)                NULL,
    [CreatedByUserId]           [dbo].[KeyID]               NOT NULL,
    [CreatedDate]               [dbo].[UserDate]            CONSTRAINT [DF_UserQuestionaireAnswers_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_UserQuestionaireAnswers] PRIMARY KEY CLUSTERED ([UserQuestionaireAnswersID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_UserQuestionaireAnswers_Answer] FOREIGN KEY ([AnswerID]) REFERENCES [dbo].[Answer] ([AnswerId]),
    CONSTRAINT [FK_UserQuestionaireAnswers_QuestionSet] FOREIGN KEY ([QuestionSetQuestionId]) REFERENCES [dbo].[QuestionSetQuestion] ([QuestionSetQuestionId]),
    CONSTRAINT [FK_UserQuestionaireAnswers_UserQuestionaire] FOREIGN KEY ([UserQuestionaireID]) REFERENCES [dbo].[PatientQuestionaire] ([PatientQuestionaireId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The answers to a specific questionnaire taken by a patient.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserQuestionaireAnswers';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserQuestionaireAnswers table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserQuestionaireAnswers', @level2type = N'COLUMN', @level2name = N'UserQuestionaireAnswersID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the UserQuestionaire table  - Identified the instance of the questionnaire', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserQuestionaireAnswers', @level2type = N'COLUMN', @level2name = N'UserQuestionaireID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the QuestionSetQuestion table - identifies the Question and the question set', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserQuestionaireAnswers', @level2type = N'COLUMN', @level2name = N'QuestionSetQuestionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Answer table - Indicates the Patients answer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserQuestionaireAnswers', @level2type = N'COLUMN', @level2name = N'AnswerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Free Form Comments field', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserQuestionaireAnswers', @level2type = N'COLUMN', @level2name = N'AnswerComments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The answer to the question', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserQuestionaireAnswers', @level2type = N'COLUMN', @level2name = N'AnswerString';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserQuestionaireAnswers', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserQuestionaireAnswers', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserQuestionaireAnswers', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserQuestionaireAnswers', @level2type = N'COLUMN', @level2name = N'CreatedDate';

