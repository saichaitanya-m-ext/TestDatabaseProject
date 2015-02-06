CREATE TABLE [dbo].[CodeSetNUCCProviderType] (
    [ProviderTypeID]       [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ProviderType]         [dbo].[ShortDescription] NOT NULL,
    [TypeDescription]      [dbo].[LongDescription]  NULL,
    [DataSourceID]         [dbo].[KeyID]            NULL,
    [DataSourceFileID]     [dbo].[KeyID]            NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetNUCCProviderType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                      NOT NULL,
    [CreatedDate]          DATETIME                 CONSTRAINT [DF_CodeSetNUCCProviderType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                      NULL,
    [LastModifiedDate]     DATETIME                 NULL,
    CONSTRAINT [PK_CodeSetNUCCProviderType] PRIMARY KEY CLUSTERED ([ProviderTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNUCCProviderType_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNUCCProviderType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetNUCCProviderType] UNIQUE NONCLUSTERED ([ProviderType] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

