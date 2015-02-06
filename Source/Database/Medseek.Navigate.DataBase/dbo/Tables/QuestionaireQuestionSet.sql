CREATE TABLE [dbo].[QuestionaireQuestionSet] (
    [QuestionaireQuestionSetId] [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [QuestionaireId]            [dbo].[KeyID]       NOT NULL,
    [QuestionSetId]             [dbo].[KeyID]       NOT NULL,
    [SortOrder]                 [dbo].[STID]        CONSTRAINT [DF_QuestionaireQuestionSet_SortOrder] DEFAULT ((1)) NULL,
    [StatusCode]                [dbo].[StatusCode]  CONSTRAINT [DF_QuestionaireQuestionSet_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]           [dbo].[KeyID]       NOT NULL,
    [CreatedDate]               [dbo].[UserDate]    CONSTRAINT [DF_QuestionaireQuestionSet_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]      [dbo].[KeyID]       NULL,
    [LastModifiedDate]          [dbo].[UserDate]    NULL,
    [IsShowPanel]               [dbo].[IsIndicator] NULL,
    [IsShowQuestionSetName]     [dbo].[IsIndicator] NULL,
    CONSTRAINT [PK_QuestionaireQuestionSet] PRIMARY KEY CLUSTERED ([QuestionaireQuestionSetId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_QuestionaireQuestionSet_Questionaire] FOREIGN KEY ([QuestionaireId]) REFERENCES [dbo].[Questionaire] ([QuestionaireId]),
    CONSTRAINT [FK_QuestionaireQuestionSet_QuestionSet] FOREIGN KEY ([QuestionSetId]) REFERENCES [dbo].[QuestionSet] ([QuestionSetId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Question sets that are related to a specific Questionnaire', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the QuestionaireQuestionSet - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet', @level2type = N'COLUMN', @level2name = N'QuestionaireQuestionSetId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Questionnaire table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet', @level2type = N'COLUMN', @level2name = N'QuestionaireId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the QuestionSet Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet', @level2type = N'COLUMN', @level2name = N'QuestionSetId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alternate Sort order for QuestionaireQuestionSet table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet', @level2type = N'COLUMN', @level2name = N'SortOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag indicating if the QuestionSet panel should be visible in the interface', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet', @level2type = N'COLUMN', @level2name = N'IsShowPanel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag indicating if the Question Set Name should be shown', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionaireQuestionSet', @level2type = N'COLUMN', @level2name = N'IsShowQuestionSetName';

