CREATE TABLE [dbo].[ProviderLanguage] (
    [ProviderLanguageID]   [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [ProviderID]           [dbo].[KeyID]       NOT NULL,
    [LanguageID]           [dbo].[KeyID]       NOT NULL,
    [IsPrimarySpoken]      [dbo].[IsIndicator] NULL,
    [IsPrimaryWritten]     [dbo].[IsIndicator] NULL,
    [DataSourceID]         [dbo].[KeyID]       NULL,
    [DataSourceFileID]     [dbo].[KeyID]       NULL,
    [RecordTagFileID]      VARCHAR (30)        NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_ProviderLanguage_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_ProviderLanguage] PRIMARY KEY CLUSTERED ([ProviderLanguageID] ASC),
    CONSTRAINT [FK_ProviderLanguage_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ProviderLanguage_CodeSetLanguage] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[CodeSetLanguage] ([LanguageID]),
    CONSTRAINT [FK_ProviderLanguage_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

