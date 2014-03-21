CREATE TABLE [dbo].[Measure] (
    [MeasureId]              [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [Name]                   VARCHAR (60)            NOT NULL,
    [Description]            [dbo].[LongDescription] NOT NULL,
    [MeasureTypeId]          [dbo].[KeyID]           NULL,
    [SortOrder]              [dbo].[STID]            CONSTRAINT [DF_Measure_SortOrder] DEFAULT ((1)) NULL,
    [CreatedByUserId]        [dbo].[KeyID]           NOT NULL,
    [CreatedDate]            [dbo].[UserDate]        CONSTRAINT [DF_Measure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]           NULL,
    [LastModifiedDate]       [dbo].[UserDate]        NULL,
    [StatusCode]             [dbo].[StatusCode]      CONSTRAINT [DF_Measure_StatusCode] DEFAULT ('A') NOT NULL,
    [StandardMeasureUOMId]   [dbo].[KeyID]           NULL,
    [IsVital]                [dbo].[IsIndicator]     NULL,
    [IsTextValueForControls] [dbo].[IsIndicator]     NULL,
    [RealisticMin]           DECIMAL (10, 2)         NULL,
    [RealisticMax]           DECIMAL (10, 2)         NULL,
    [ShortName]              VARCHAR (60)            NULL,
    [MeasureTextOptionId]    [dbo].[KeyID]           NULL,
    [IsSynonym]              [dbo].[IsIndicator]     CONSTRAINT [DF_Measure_IsSynonym] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Measure] PRIMARY KEY CLUSTERED ([MeasureId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Measure_MeasureTextOption] FOREIGN KEY ([MeasureTextOptionId]) REFERENCES [dbo].[MeasureTextOption] ([MeasureTextOptionId]),
    CONSTRAINT [FK_Measure_MeasureType] FOREIGN KEY ([MeasureTypeId]) REFERENCES [dbo].[MeasureType] ([MeasureTypeId]),
    CONSTRAINT [FK_Measure_MeasureUOM] FOREIGN KEY ([StandardMeasureUOMId]) REFERENCES [dbo].[MeasureUOM] ([MeasureUOMId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Measure_Name]
    ON [dbo].[Measure]([Name] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Measure_MeasureIDName]
    ON [dbo].[Measure]([MeasureId] ASC, [Name] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A specific Medical Measurement that is taken to manage a patients health', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the Measure table - identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'MeasureId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Measure Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for Measure table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the MeasureType  table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'MeasureTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alternate Sort order for Measure table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'SortOrder';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Standard UOM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'StandardMeasureUOMId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag to indicate if the measure is a lab', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'IsVital';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag to indicate if the measure is non-numeric value (Normal, abnormal, pass, fail, yes, no)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'COLUMN', @level2name = N'IsTextValueForControls';

