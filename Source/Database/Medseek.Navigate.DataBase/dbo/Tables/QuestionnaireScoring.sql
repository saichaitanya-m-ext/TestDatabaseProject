CREATE TABLE [dbo].[QuestionnaireScoring] (
    [QuestionnaireScoringID] INT           IDENTITY (1, 1) NOT NULL,
    [QuestionaireId]         [dbo].[KeyID] NOT NULL,
    [RangeStartScore]        SMALLINT      NULL,
    [RangeEndScore]          SMALLINT      NULL,
    [RangeName]              VARCHAR (100) NULL,
    [RangeDescription]       VARCHAR (MAX) NULL,
    [StatusCode]             VARCHAR (1)   CONSTRAINT [DF_QuestionnaireScoring_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUSerID]        [dbo].[KeyID] NOT NULL,
    [CreatedDate]            DATETIME      CONSTRAINT [DF_QuestionnaireScoring_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]   INT           NULL,
    [LastModifiedDate]       DATETIME      NULL,
    CONSTRAINT [PK_QuestionnaireScoring] PRIMARY KEY CLUSTERED ([QuestionnaireScoringID] ASC),
    CONSTRAINT [FK_QuestionnaireScoring_QuestionaireId] FOREIGN KEY ([QuestionaireId]) REFERENCES [dbo].[Questionaire] ([QuestionaireId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireScoring', @level2type = N'COLUMN', @level2name = N'CreatedByUSerID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireScoring', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireScoring', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QuestionnaireScoring', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

