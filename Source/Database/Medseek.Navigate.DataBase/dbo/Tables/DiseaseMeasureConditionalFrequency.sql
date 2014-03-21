CREATE TABLE [dbo].[DiseaseMeasureConditionalFrequency] (
    [DiseaseMeasureConditionlFrequencyID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [DiseaseMeasureId]                    [dbo].[KeyID]      NOT NULL,
    [OperatorforMeasure]                  VARCHAR (5)        NULL,
    [ValueforMeasure]                     DECIMAL (10, 2)    NULL,
    [MeasureTextValue]                    [dbo].[SourceName] NULL,
    [FrequencyUOM]                        VARCHAR (1)        NOT NULL,
    [Frequency]                           SMALLINT           NOT NULL,
    [OutComeType]                         CHAR (1)           NULL,
    [CreatedByUserId]                     [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                         [dbo].[UserDate]   CONSTRAINT [DF_DiseaseMeasureConditionalFrequency_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]                [dbo].[KeyID]      NULL,
    [LastModifiedDate]                    [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_DiseaseMeasureConditionalFrequency] PRIMARY KEY CLUSTERED ([DiseaseMeasureConditionlFrequencyID] ASC),
    CONSTRAINT [FK_DiseaseMeasureConditionalFrequency_DiseaseMeasure] FOREIGN KEY ([DiseaseMeasureId]) REFERENCES [dbo].[DiseaseMeasure] ([DiseaseMeasureId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

