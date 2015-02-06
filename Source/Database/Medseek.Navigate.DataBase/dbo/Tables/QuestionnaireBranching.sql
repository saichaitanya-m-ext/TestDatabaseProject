CREATE TABLE [dbo].[QuestionnaireBranching] (
    [QuestionnaireBranchingId]          [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [QuestionaireQuestionSetId]         [dbo].[KeyID]    NOT NULL,
    [QuestionSetQuestionId]             [dbo].[KeyID]    NULL,
    [BranchingAnswerId]                 [dbo].[KeyID]    NOT NULL,
    [RecommendationId]                  [dbo].[KeyID]    NULL,
    [BranchToQuestionaireQuestionSetId] [dbo].[KeyID]    NULL,
    [BranchToQuestionSetQuestionsId]    [dbo].[KeyID]    NULL,
    [QuestionSetBranchingOption]        VARCHAR (4)      NULL,
    [CreatedByUserId]                   [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                       [dbo].[UserDate] CONSTRAINT [DF_QuestionnaireBranching_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]              [dbo].[KeyID]    NULL,
    [LastModifiedDate]                  [dbo].[UserDate] NULL,
    CONSTRAINT [PK_QuestionnaireBranching] PRIMARY KEY CLUSTERED ([QuestionnaireBranchingId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_QuestionnaireBranching_AnswerBranching] FOREIGN KEY ([BranchingAnswerId]) REFERENCES [dbo].[Answer] ([AnswerId]),
    CONSTRAINT [FK_QuestionnaireBranching_QuestionnaireQuestionSet] FOREIGN KEY ([QuestionaireQuestionSetId]) REFERENCES [dbo].[QuestionaireQuestionSet] ([QuestionaireQuestionSetId]),
    CONSTRAINT [FK_QuestionnaireBranching_QuestionnaireQuestionSet_Branch] FOREIGN KEY ([BranchToQuestionaireQuestionSetId]) REFERENCES [dbo].[QuestionaireQuestionSet] ([QuestionaireQuestionSetId]),
    CONSTRAINT [FK_QuestionnaireBranching_QuestionSetQuestion] FOREIGN KEY ([QuestionSetQuestionId]) REFERENCES [dbo].[QuestionSetQuestion] ([QuestionSetQuestionId]),
    CONSTRAINT [FK_QuestionnaireBranching_QuestionSetQuestion_Branch] FOREIGN KEY ([BranchToQuestionSetQuestionsId]) REFERENCES [dbo].[QuestionSetQuestion] ([QuestionSetQuestionId]),
    CONSTRAINT [FK_QuestionnaireBranching_Recommendation] FOREIGN KEY ([RecommendationId]) REFERENCES [dbo].[Recommendation] ([RecommendationId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table manages branching within a questionnaire. Specific answers to questions can cause the Questionnaire to branch to a question out of sequence', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the QuestionnaireBranching table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'QuestionnaireBranchingId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the QuestionaireQuestionSet', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'QuestionaireQuestionSetId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the QuestionSetQuestion Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'QuestionSetQuestionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Answer ID that triggers the branching action', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'BranchingAnswerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Recommendation Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'RecommendationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Branch to a Questionnaire Question Set', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'BranchToQuestionaireQuestionSetId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Branch to a question', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'BranchToQuestionSetQuestionsId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Values are {“All”,”Any”,”None”}  describe the specific branching option', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'QuestionSetBranchingOption';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireBranching', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

