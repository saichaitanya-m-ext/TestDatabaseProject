CREATE TABLE [dbo].[CodeSetPrescriptionOrigin] (
    [PrescriptionOriginID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PrescriptionOriginCode] VARCHAR (4)             NOT NULL,
    [PrescriptionOriginName] VARCHAR (60)            NOT NULL,
    [CodeDescription]        [dbo].[LongDescription] NULL,
    [DataSourceID]           [dbo].[KeyID]           NULL,
    [DataSourceFileID]       [dbo].[KeyID]           NULL,
    [StatusCode]             [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetPrescriptionOrigin_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]        INT                     NOT NULL,
    [CreatedDate]            DATETIME                CONSTRAINT [DF_CodeSetPrescriptionOrigin_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   INT                     NULL,
    [LastModifiedDate]       DATETIME                NULL,
    CONSTRAINT [PK_CodeSetPrescriptionOrigin] PRIMARY KEY CLUSTERED ([PrescriptionOriginID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetPrescriptionOrigin_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetPrescriptionOrigin_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetPrescriptionOrigin_PrescriptionOriginCode]
    ON [dbo].[CodeSetPrescriptionOrigin]([PrescriptionOriginCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetPrescriptionOrigin_PrescriptionOriginName]
    ON [dbo].[CodeSetPrescriptionOrigin]([PrescriptionOriginName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

