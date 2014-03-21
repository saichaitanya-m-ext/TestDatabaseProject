CREATE TABLE [dbo].[PatientVitalSignRespiratoryRate] (
    [PatientVitalSignRespiratoryRateID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PatientID]                         [dbo].[KeyID]    NOT NULL,
    [RespiratoryRate]                   TINYINT          NULL,
    [RateMeasureUOMID]                  [dbo].[KeyID]    NULL,
    [MeasurementTime]                   [dbo].[UserDate] NULL,
    [DataSourceID]                      [dbo].[KeyID]    NULL,
    [DataSourceFileID]                  [dbo].[KeyID]    NULL,
    [RecordTagFileID]                   VARCHAR (30)     NULL,
    [StatusCode]                        VARCHAR (1)      CONSTRAINT [DF_PatientVitalSignRespiratoryRate_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]                   [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                       [dbo].[UserDate] CONSTRAINT [DF_PatientVitalSignRespiratoryRate_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]              [dbo].[KeyID]    NULL,
    [LastModifiedDate]                  [dbo].[UserDate] NULL,
    CONSTRAINT [PK_PatientVitalSignRespiratoryRate] PRIMARY KEY CLUSTERED ([PatientVitalSignRespiratoryRateID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_PatientVitalSignRespiratoryRate_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientVitalSignRespiratoryRate_CodeSetUnitsOfMeasure] FOREIGN KEY ([RateMeasureUOMID]) REFERENCES [dbo].[CodeSetUnitOfMeasure] ([UnitOfMeasureID]),
    CONSTRAINT [FK_PatientVitalSignRespiratoryRate_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientVitalSignRespiratoryRate_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_PatientVitalSignRespiratoryRate_PatientVitalRespiratoryRate]
    ON [dbo].[PatientVitalSignRespiratoryRate]([PatientID] ASC)
    INCLUDE([MeasurementTime]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

