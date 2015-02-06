CREATE TABLE [dbo].[CodeSetNUCCProviderClassification] (
    [ProviderClassificationID]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ProviderClassificationName] [dbo].[ShortDescription] NOT NULL,
    [ClassificationDescription]  [dbo].[LongDescription]  NULL,
    [DataSourceID]               [dbo].[KeyID]            NULL,
    [DataSourceFileID]           [dbo].[KeyID]            NULL,
    [StatusCode]                 [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetNUCCProviderClassification_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]            INT                      NOT NULL,
    [CreatedDate]                DATETIME                 CONSTRAINT [DF_CodeSetNUCCProviderClassification_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]       INT                      NULL,
    [LastModifiedDate]           DATETIME                 NULL,
    CONSTRAINT [PK_CodeSetNUCCProviderClassification] PRIMARY KEY CLUSTERED ([ProviderClassificationID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNUCCProviderClassification_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNUCCProviderClassification_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetNUCCProviderClassification_ProviderClassificationName]
    ON [dbo].[CodeSetNUCCProviderClassification]([ProviderClassificationName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

