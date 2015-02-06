CREATE TABLE [dbo].[PatientVitalSignBMI] (
    [PatientVitalSignBMIID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PatientID]             [dbo].[KeyID]    NOT NULL,
    [BMIValue]              NUMERIC (5)      NULL,
    [Weight]                NUMERIC (4)      NULL,
    [WeightMeasureUOMID]    [dbo].[KeyID]    NULL,
    [Height]                NUMERIC (4)      NULL,
    [HeightMeasureUOMID]    [dbo].[KeyID]    NULL,
    [MeasurementDate]       [dbo].[UserDate] NULL,
    [DataSourceID]          [dbo].[KeyID]    NULL,
    [DataSourceFileID]      [dbo].[KeyID]    NULL,
    [RecordTagFileID]       VARCHAR (30)     NULL,
    [StatusCode]            VARCHAR (1)      CONSTRAINT [DF_PatientVitalSignBMI_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]       [dbo].[KeyID]    NOT NULL,
    [CreatedDate]           [dbo].[UserDate] CONSTRAINT [DF_PatientVitalSignBMI_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]  [dbo].[KeyID]    NULL,
    [LastModifiedDate]      [dbo].[UserDate] NULL,
    CONSTRAINT [PK_PatientVitalSignBMI] PRIMARY KEY CLUSTERED ([PatientVitalSignBMIID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_PatientVitalSignBMI_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientVitalSignBMI_CodeSetUnitsOfMeasure] FOREIGN KEY ([WeightMeasureUOMID]) REFERENCES [dbo].[CodeSetUnitOfMeasure] ([UnitOfMeasureID]),
    CONSTRAINT [FK_PatientVitalSignBMI_CodeSetUnitsOfMeasureHeight] FOREIGN KEY ([HeightMeasureUOMID]) REFERENCES [dbo].[CodeSetUnitOfMeasure] ([UnitOfMeasureID]),
    CONSTRAINT [FK_PatientVitalSignBMI_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientVitalSignBMI_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_PatientVitalSignBMI_PatientVitalSign]
    ON [dbo].[PatientVitalSignBMI]([PatientID] ASC)
    INCLUDE([MeasurementDate]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

