CREATE TABLE [dbo].[Question] (
    [QuestionId]           [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [QuestionTypeID]       [dbo].[KeyID]           NULL,
    [Description]          [dbo].[LongDescription] NULL,
    [QuestionText]         [dbo].[LongDescription] NULL,
    [AnswerTypeId]         [dbo].[KeyID]           NULL,
    [ImageNameAndPath]     VARCHAR (200)           NULL,
    [ImageContentType]     VARCHAR (20)            NULL,
    [UsercontrolName]      VARCHAR (200)           NULL,
    [CreatedByUserId]      [dbo].[KeyID]           NOT NULL,
    [CreatedDate]          [dbo].[UserDate]        CONSTRAINT [DF_Question_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]           NULL,
    [LastModifiedDate]     [dbo].[UserDate]        NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_Question_StatusCode] DEFAULT ('A') NOT NULL,
    [DataSource]           VARCHAR (200)           NULL,
    CONSTRAINT [PK_Question] PRIMARY KEY CLUSTERED ([QuestionId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_Question_AnswerType] FOREIGN KEY ([AnswerTypeId]) REFERENCES [dbo].[AnswerType] ([AnswerTypeId]),
    CONSTRAINT [FK_Question_QuestionType] FOREIGN KEY ([QuestionTypeID]) REFERENCES [dbo].[QuestionType] ([QuestionTypeId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Question]
    ON [dbo].[Question]([Description] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A specific question in a question set', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the Question Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'QuestionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the QuestionType table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'QuestionTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for Question table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The question text', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'QuestionText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Answer type: String, Numeric, date , integer,…', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'AnswerTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Full Path to a image that will be displayed in a panel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'ImageNameAndPath';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The user control name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'UsercontrolName';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The data source for the question', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Question', @level2type = N'COLUMN', @level2name = N'DataSource';

