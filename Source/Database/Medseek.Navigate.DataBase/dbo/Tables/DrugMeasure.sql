CREATE TABLE [dbo].[DrugMeasure] (
    [DrugMeasureId]        [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [MeasureId]            [dbo].[KeyID]    NULL,
    [DrugCodeId]           INT              NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]    NOT NULL,
    [CreatedDate]          [dbo].[UserDate] CONSTRAINT [DF_DrugMeasure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]    NULL,
    [LastModifiedDate]     [dbo].[UserDate] NULL,
    CONSTRAINT [PK_DrugMeasure] PRIMARY KEY CLUSTERED ([DrugMeasureId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_DrugMeasure_CodeSetDrug] FOREIGN KEY ([DrugCodeId]) REFERENCES [dbo].[CodeSetDrug] ([DrugCodeId]),
    CONSTRAINT [FK_DrugMeasure_Measure] FOREIGN KEY ([MeasureId]) REFERENCES [dbo].[Measure] ([MeasureId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_DrugMeasure_MeasureIdNDCCode]
    ON [dbo].[DrugMeasure]([MeasureId] ASC, [DrugCodeId] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not used was intended to relate Drugs to meassures', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the DrugMeasure Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure', @level2type = N'COLUMN', @level2name = N'DrugMeasureId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Measure table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure', @level2type = N'COLUMN', @level2name = N'MeasureId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CodeSetDrugs table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure', @level2type = N'COLUMN', @level2name = N'DrugCodeId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrugMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

