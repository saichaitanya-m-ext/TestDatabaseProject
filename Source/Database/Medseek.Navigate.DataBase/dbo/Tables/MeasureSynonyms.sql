CREATE TABLE [dbo].[MeasureSynonyms] (
    [SynonymMasterMeasureID] [dbo].[KeyID]    NOT NULL,
    [SynonymMeasureID]       [dbo].[KeyID]    NOT NULL,
    [CreatedByUserId]        [dbo].[KeyID]    NOT NULL,
    [CreatedDate]            [dbo].[UserDate] CONSTRAINT [DF_MeasureSynonyms_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]    NULL,
    [LastModifiedDate]       [dbo].[UserDate] NULL,
    CONSTRAINT [PK_MeasureSynonyms] PRIMARY KEY CLUSTERED ([SynonymMasterMeasureID] ASC, [SynonymMeasureID] ASC),
    CONSTRAINT [FK_MeasureSynonyms_SynonymMasterMeasureID] FOREIGN KEY ([SynonymMasterMeasureID]) REFERENCES [dbo].[Measure] ([MeasureId]),
    CONSTRAINT [FK_MeasureSynonyms_SynonymMeasureID] FOREIGN KEY ([SynonymMeasureID]) REFERENCES [dbo].[Measure] ([MeasureId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MeasureSynonyms', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MeasureSynonyms', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MeasureSynonyms', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MeasureSynonyms', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

