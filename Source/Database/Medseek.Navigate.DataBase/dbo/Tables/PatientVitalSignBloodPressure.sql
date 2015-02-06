CREATE TABLE [dbo].[PatientVitalSignBloodPressure] (
    [PatientVitalSignBPID]  [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PatientID]             [dbo].[KeyID]    NOT NULL,
    [SystolicValue]         NUMERIC (5)      NULL,
    [SystolicMeasureUOMID]  [dbo].[KeyID]    NULL,
    [DiastolicValue]        NUMERIC (5)      NULL,
    [DiastolicMeasureUOMID] [dbo].[KeyID]    NULL,
    [MeasurementTime]       [dbo].[UserDate] NULL,
    [DataSourceID]          [dbo].[KeyID]    NULL,
    [DataSourceFileID]      [dbo].[KeyID]    NULL,
    [RecordTagFileID]       VARCHAR (30)     NULL,
    [StatusCode]            VARCHAR (1)      CONSTRAINT [DF_PatientVitalSignBloodPressure_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]       [dbo].[KeyID]    NOT NULL,
    [CreatedDate]           [dbo].[UserDate] CONSTRAINT [DF_PatientVitalSignBloodPressure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]  [dbo].[KeyID]    NULL,
    [LastModifiedDate]      [dbo].[UserDate] NULL,
    CONSTRAINT [PK_PatientVitalSignBloodPressure] PRIMARY KEY CLUSTERED ([PatientVitalSignBPID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_PatientVitalSignBloodPressure_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientVitalSignBloodPressure_CodeSetUnitsOfMeasure] FOREIGN KEY ([SystolicMeasureUOMID]) REFERENCES [dbo].[CodeSetUnitOfMeasure] ([UnitOfMeasureID]),
    CONSTRAINT [FK_PatientVitalSignBloodPressure_CodeSetUnitsOfMeasureDiastolic] FOREIGN KEY ([DiastolicMeasureUOMID]) REFERENCES [dbo].[CodeSetUnitOfMeasure] ([UnitOfMeasureID]),
    CONSTRAINT [FK_PatientVitalSignBloodPressure_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientVitalSignBloodPressure_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_PatientVitalSignBloodPressure_PatientVitalBP]
    ON [dbo].[PatientVitalSignBloodPressure]([PatientID] ASC)
    INCLUDE([MeasurementTime]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

