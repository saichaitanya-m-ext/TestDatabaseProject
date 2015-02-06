CREATE TABLE [dbo].[QuestionSetQuestion] (
    [QuestionSetQuestionId] [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [QuestionSetId]         [dbo].[KeyID]       NOT NULL,
    [QuestionId]            [dbo].[KeyID]       NOT NULL,
    [StatusCode]            [dbo].[StatusCode]  CONSTRAINT [DF_QuestionSetQuestion_StatusCode] DEFAULT ('A') NOT NULL,
    [IsRequiredQuestion]    [dbo].[IsIndicator] NOT NULL,
    [IsPrerequisite]        [dbo].[IsIndicator] NOT NULL,
    [CreatedByUserId]       [dbo].[KeyID]       NOT NULL,
    [CreatedDate]           [dbo].[UserDate]    CONSTRAINT [DF_QuestionSetQuestion_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]  [dbo].[KeyID]       NULL,
    [LastModifiedDate]      [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_QuestionSetQuestion] PRIMARY KEY CLUSTERED ([QuestionSetQuestionId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_QuestionSetQuestion_Question] FOREIGN KEY ([QuestionId]) REFERENCES [dbo].[Question] ([QuestionId]),
    CONSTRAINT [FK_QuestionSetQuestion_QuestionSet] FOREIGN KEY ([QuestionSetId]) REFERENCES [dbo].[QuestionSet] ([QuestionSetId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The table that relates questions to a question set', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the QuestionSetQuestion table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'QuestionSetQuestionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the QuestionSet Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'QuestionSetId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Question Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'QuestionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag indicating if the question is required', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'IsRequiredQuestion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag indication if the question is a prerequisite to another question', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'IsPrerequisite';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionSetQuestion', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

