CREATE TABLE [dbo].[LoinCodeMeasure] (
    [LoinCodeMeasureID]    [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [MeasureId]            [dbo].[KeyID]      NOT NULL,
    [LoinCodeId]           [dbo].[KeyID]      NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_LoinCodeMeasure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_LoinCodeMeasure_StatusCode] DEFAULT ('A') NOT NULL,
    CONSTRAINT [PK_LoinCodeMeasure] PRIMARY KEY CLUSTERED ([LoinCodeMeasureID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_LoinCodeMeasure_CodeSetLoincCode] FOREIGN KEY ([LoinCodeId]) REFERENCES [dbo].[CodeSetLoinc] ([LoincCodeId]),
    CONSTRAINT [FK_LoinCodeMeasure_Measure] FOREIGN KEY ([MeasureId]) REFERENCES [dbo].[Measure] ([MeasureId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LoinCodeMeasure', @level2type = N'COLUMN', @level2name = N'LoinCodeMeasureID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Link to Measure table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LoinCodeMeasure', @level2type = N'COLUMN', @level2name = N'MeasureId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Link to CodeSetLoincCode table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LoinCodeMeasure', @level2type = N'COLUMN', @level2name = N'LoinCodeId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LoinCodeMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Link to Users table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LoinCodeMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LoinCodeMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LoinCodeMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LoinCodeMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

