CREATE TABLE [dbo].[ProgramQuestionaire] (
    [ProgramId]       [dbo].[KeyID]      NOT NULL,
    [QuestionaireId]  [dbo].[KeyID]      NOT NULL,
    [StatusCode]      [dbo].[StatusCode] CONSTRAINT [DF_ProgramQuestionaire_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId] [dbo].[KeyID]      NOT NULL,
    [CreatedDate]     [dbo].[UserDate]   CONSTRAINT [DF_ProgramQuestionaire_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ProgramQuestionaire] PRIMARY KEY CLUSTERED ([ProgramId] ASC, [QuestionaireId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_programQuestionaire_program] FOREIGN KEY ([ProgramId]) REFERENCES [dbo].[Program] ([ProgramId]),
    CONSTRAINT [FK_programQuestionaire_Questionaire] FOREIGN KEY ([QuestionaireId]) REFERENCES [dbo].[Questionaire] ([QuestionaireId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramQuestionaire', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramQuestionaire', @level2type = N'COLUMN', @level2name = N'CreatedDate';

