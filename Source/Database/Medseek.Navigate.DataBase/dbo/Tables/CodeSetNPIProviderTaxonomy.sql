CREATE TABLE [dbo].[CodeSetNPIProviderTaxonomy] (
    [ProviderTaxonomyID]   [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [NPINumberID]          [dbo].[KeyID]      NOT NULL,
    [TaxonomyCodeID]       [dbo].[KeyID]      NOT NULL,
    [LicenseNumber]        VARCHAR (20)       NULL,
    [StateID]              [dbo].[KeyID]      NULL,
    [DataSourceID]         [dbo].[KeyID]      NULL,
    [DataFileID]           [dbo].[KeyID]      NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetNPIProviderTaxonomy_StatusCode] DEFAULT ('A') NOT NULL,
    [IsPrimaryTaxanomy]    [dbo].[StatusCode] CONSTRAINT [DF_CodeSetNPIProviderTaxonomy_IsPrimaryTaxanomy] DEFAULT ('0') NULL,
    [CreatedByUserId]      INT                NOT NULL,
    [CreatedDate]          DATETIME           CONSTRAINT [DF_CodeSetNPIProviderTaxonomy_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                NULL,
    [LastModifiedDate]     DATETIME           NULL,
    CONSTRAINT [PK_CodeSetNPIProviderTaxonomy] PRIMARY KEY CLUSTERED ([ProviderTaxonomyID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNPIProviderTaxonomy_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNPIProviderTaxonomy_CodeSetNPI] FOREIGN KEY ([NPINumberID]) REFERENCES [dbo].[CodeSetNPI] ([NPINumberID]),
    CONSTRAINT [FK_CodeSetNPIProviderTaxonomy_CodeSetNUCCProviderTaxonomy] FOREIGN KEY ([TaxonomyCodeID]) REFERENCES [dbo].[CodeSetNUCCProviderTaxonomy] ([TaxonomyCodeID]),
    CONSTRAINT [FK_CodeSetNPIProviderTaxonomy_CodeSetState] FOREIGN KEY ([StateID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_CodeSetNPIProviderTaxonomy_DataSourceFile] FOREIGN KEY ([DataFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

