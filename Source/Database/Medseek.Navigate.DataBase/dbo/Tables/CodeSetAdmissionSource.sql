CREATE TABLE [dbo].[CodeSetAdmissionSource] (
    [AdmissionSourceCodeID] [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [AdmissionSourceCode]   VARCHAR (10)            NOT NULL,
    [AdmissionSource]       VARCHAR (30)            NOT NULL,
    [AdmissionType_NewBorn] BIT                     NOT NULL,
    [SourceDescription]     [dbo].[LongDescription] NULL,
    [DataSourceID]          [dbo].[KeyID]           NULL,
    [DataSourceFileID]      [dbo].[KeyID]           NULL,
    [StatusCode]            [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetAdmissionSource_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]       INT                     NOT NULL,
    [CreatedDate]           DATETIME                CONSTRAINT [DF_CodeSetAdmissionSource_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]  INT                     NULL,
    [LastModifiedDate]      DATETIME                NULL,
    CONSTRAINT [PK_CodeSetAdmissionSource] PRIMARY KEY CLUSTERED ([AdmissionSourceCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetAdmissionSource_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetAdmissionSource_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetAdmissionSource_AdmissionSource]
    ON [dbo].[CodeSetAdmissionSource]([AdmissionSource] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetAdmissionSource_AdmissionSourceCode]
    ON [dbo].[CodeSetAdmissionSource]([AdmissionSourceCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

