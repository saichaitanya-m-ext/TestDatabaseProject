CREATE TABLE [dbo].[CodeSetAdmissionType] (
    [AdmissionTypeCodeID]  [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [AdmissionTypeCode]    VARCHAR (10)            NOT NULL,
    [AdmissionType]        VARCHAR (30)            NOT NULL,
    [TypeDescription]      [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetAdmissionType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetAdmissionType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetAdmissionType] PRIMARY KEY CLUSTERED ([AdmissionTypeCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetAdmissionType_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetAdmissionType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetAdmissionType_AdmissionType]
    ON [dbo].[CodeSetAdmissionType]([AdmissionType] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetAdmissionType_AdmissionTypeCode]
    ON [dbo].[CodeSetAdmissionType]([AdmissionTypeCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

