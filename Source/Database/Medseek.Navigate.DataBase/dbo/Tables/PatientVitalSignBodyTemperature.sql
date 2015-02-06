CREATE TABLE [dbo].[PatientVitalSignBodyTemperature] (
    [PatientVitalSignBodyTempID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PatientID]                  [dbo].[KeyID]    NOT NULL,
    [BodyTemperature]            NUMERIC (5)      NULL,
    [UnitOfMeasureID]            [dbo].[KeyID]    NULL,
    [MeasurementTime]            [dbo].[UserDate] NULL,
    [DataSourceID]               [dbo].[KeyID]    NULL,
    [DataSourceFileID]           [dbo].[KeyID]    NULL,
    [RecordTagFileID]            VARCHAR (30)     NULL,
    [StatusCode]                 VARCHAR (1)      CONSTRAINT [DF_PatientVitalSignBodyTemperature_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]            [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                [dbo].[UserDate] CONSTRAINT [DF_PatientVitalSignBodyTemperature_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]       [dbo].[KeyID]    NULL,
    [LastModifiedDate]           [dbo].[UserDate] NULL,
    CONSTRAINT [PK_PatientVitalSignBodyTemperature] PRIMARY KEY CLUSTERED ([PatientVitalSignBodyTempID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_PatientVitalSignBodyTemperature_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientVitalSignBodyTemperature_CodeSetUnitOfMeasure] FOREIGN KEY ([UnitOfMeasureID]) REFERENCES [dbo].[CodeSetUnitOfMeasure] ([UnitOfMeasureID]),
    CONSTRAINT [FK_PatientVitalSignBodyTemperature_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientVitalSignBodyTemperature_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_PatientVitalSignBodyTemperature_PatientVitalBody]
    ON [dbo].[PatientVitalSignBodyTemperature]([PatientID] ASC)
    INCLUDE([MeasurementTime]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

