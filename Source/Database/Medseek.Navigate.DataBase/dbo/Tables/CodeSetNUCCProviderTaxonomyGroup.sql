CREATE TABLE [dbo].[CodeSetNUCCProviderTaxonomyGroup] (
    [ProviderTaxonomyGroupID]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ProviderTaxonomyGroupName] [dbo].[ShortDescription] NOT NULL,
    [GroupDescription]          [dbo].[LongDescription]  NULL,
    [DataSourceID]              [dbo].[KeyID]            NULL,
    [DataSourceFileID]          [dbo].[KeyID]            NULL,
    [StatusCode]                [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetNUCCProviderTaxonomyGroup_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]           INT                      NOT NULL,
    [CreatedDate]               DATETIME                 CONSTRAINT [DF_CodeSetNUCCProviderTaxonomyGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]      INT                      NULL,
    [LastModifiedDate]          DATETIME                 NULL,
    CONSTRAINT [PK_CodeSetNUCCProviderTaxonomyGroup] PRIMARY KEY CLUSTERED ([ProviderTaxonomyGroupID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNUCCProviderTaxonomyGroup_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNUCCProviderTaxonomyGroup_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [IX_CodeSetNUCCProviderTaxonomyGroup] UNIQUE NONCLUSTERED ([ProviderTaxonomyGroupName] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX],
    CONSTRAINT [UQ_CodeSetNUCCProviderTaxonomyGroup_GroupName] UNIQUE NONCLUSTERED ([ProviderTaxonomyGroupName] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

