CREATE TABLE [dbo].[CodeSetPatientStatus] (
    [PatientStatusCodeID]  [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PatientStatusCode]    VARCHAR (10)            NOT NULL,
    [PatientStatus]        VARCHAR (30)            NOT NULL,
    [StatusDescription]    [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetPatientStatus_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetPatientStatus_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetPatientStatus] PRIMARY KEY CLUSTERED ([PatientStatusCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetPatientStatus_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetPatientStatus_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetPatientStatus_Code]
    ON [dbo].[CodeSetPatientStatus]([PatientStatusCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetPatientStatus_PatientStatus]
    ON [dbo].[CodeSetPatientStatus]([PatientStatus] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

