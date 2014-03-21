CREATE TABLE [dbo].[DiseaseMeasure] (
    [DiseaseMeasureId]     [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [DiseaseId]            [dbo].[KeyID]       NULL,
    [MeasureId]            [dbo].[KeyID]       NOT NULL,
    [Prioritization]       [dbo].[KeyID]       NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_DiseaseMeasure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    [StatusCode]           [dbo].[StatusCode]  CONSTRAINT [DF_DiseaseMeasure_StatusCode] DEFAULT ('A') NOT NULL,
    [IsPrimaryMeasure]     [dbo].[IsIndicator] CONSTRAINT [DF_DiseaseMeasure_IsPrimaryMeasure] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_DiseaseMeasure] PRIMARY KEY CLUSTERED ([DiseaseMeasureId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_DiseaseMeasure_Disease] FOREIGN KEY ([DiseaseId]) REFERENCES [dbo].[Disease] ([DiseaseId]),
    CONSTRAINT [FK_DiseaseMeasure_Measure] FOREIGN KEY ([MeasureId]) REFERENCES [dbo].[Measure] ([MeasureId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_DiseaseMeasure_DiseaseIdMeasureId]
    ON [dbo].[DiseaseMeasure]([DiseaseId] ASC, [MeasureId] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of a medical measurement that is associated with a disease (A1C/Diabeties)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the DiseaseMeasure Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'DiseaseMeasureId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Disease Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'DiseaseId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Measure table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'MeasureId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Priority order for the Measures', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'Prioritization';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseMeasure', @level2type = N'COLUMN', @level2name = N'StatusCode';

