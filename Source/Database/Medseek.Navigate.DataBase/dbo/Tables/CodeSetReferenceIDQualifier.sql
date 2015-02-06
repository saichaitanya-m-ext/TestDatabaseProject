CREATE TABLE [dbo].[CodeSetReferenceIDQualifier] (
    [ReferenceIDQualifierCodeID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [ReferenceIDQualifierCode]     VARCHAR (5)             NOT NULL,
    [ReferenceIDQualifierCodeName] VARCHAR (30)            NOT NULL,
    [CodeDescription]              [dbo].[LongDescription] NULL,
    [DataSourceID]                 [dbo].[KeyID]           NULL,
    [DataSourceFileID]             [dbo].[KeyID]           NULL,
    [StatusCode]                   [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetReferenceIDQualifier_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]              INT                     NOT NULL,
    [CreatedDate]                  DATETIME                CONSTRAINT [DF_CodeSetReferenceIDQualifier_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]         INT                     NULL,
    [LastModifiedDate]             DATETIME                NULL,
    CONSTRAINT [PK_CodeSetReferenceIDQualifier] PRIMARY KEY CLUSTERED ([ReferenceIDQualifierCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetReferenceIDQualifier_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetReferenceIDQualifier_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetReferenceIDQualifier_Code] UNIQUE NONCLUSTERED ([ReferenceIDQualifierCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX],
    CONSTRAINT [UQ_CodeSetReferenceIDQualifier_Name] UNIQUE NONCLUSTERED ([ReferenceIDQualifierCodeName] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

