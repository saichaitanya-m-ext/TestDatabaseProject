CREATE TABLE [dbo].[CodeSetNPIProviderTaxonomyGroup] (
    [ProviderTaxonomyGroupID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [NPINumberID]             [dbo].[KeyID]      NOT NULL,
    [TaxonomyGroupID]         [dbo].[KeyID]      NOT NULL,
    [DataSourceID]            [dbo].[KeyID]      NULL,
    [DataFileID]              [dbo].[KeyID]      NULL,
    [StatusCode]              [dbo].[StatusCode] CONSTRAINT [DF_CodeSetNPIProviderTaxonomyGroup_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]         INT                NOT NULL,
    [CreatedDate]             DATETIME           CONSTRAINT [DF_CodeSetNPIProviderTaxonomyGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    INT                NULL,
    [LastModifiedDate]        DATETIME           NULL,
    CONSTRAINT [PK_CodeSetNPIProviderTaxonomyGroup] PRIMARY KEY CLUSTERED ([ProviderTaxonomyGroupID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNPIProviderTaxonomyGroup_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNPIProviderTaxonomyGroup_CodeSetNPI] FOREIGN KEY ([NPINumberID]) REFERENCES [dbo].[CodeSetNPI] ([NPINumberID]),
    CONSTRAINT [FK_CodeSetNPIProviderTaxonomyGroup_CodeSetNUCCProviderTaxonomyGroup] FOREIGN KEY ([TaxonomyGroupID]) REFERENCES [dbo].[CodeSetNUCCProviderTaxonomyGroup] ([ProviderTaxonomyGroupID]),
    CONSTRAINT [FK_CodeSetNPIProviderTaxonomyGroup_DataSourceFile] FOREIGN KEY ([DataFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

