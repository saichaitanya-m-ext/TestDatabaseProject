CREATE TABLE [dbo].[CodeSetNUCCProviderTaxonomy] (
    [TaxonomyCodeID]           [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [TaxonomyCode]             VARCHAR (10)       NOT NULL,
    [ProviderTypeID]           [dbo].[KeyID]      NOT NULL,
    [ProviderClassificationID] [dbo].[KeyID]      NULL,
    [ProviderSpecializationID] [dbo].[KeyID]      NULL,
    [TaxonomyDescription]      VARCHAR (8000)     NULL,
    [TaxonomyNotes]            VARCHAR (8000)     NULL,
    [DataSourceID]             [dbo].[KeyID]      NULL,
    [DataSourceFileID]         [dbo].[KeyID]      NULL,
    [StatusCode]               [dbo].[StatusCode] CONSTRAINT [DF_CodeSetNUCCProviderTaxonomy_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]          INT                NOT NULL,
    [CreatedDate]              DATETIME           CONSTRAINT [DF_CodeSetNUCCProviderTaxonomy_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]     INT                NULL,
    [LastModifiedDate]         DATETIME           NULL,
    CONSTRAINT [PK_CodeSetNUCCProviderTaxonomy] PRIMARY KEY CLUSTERED ([TaxonomyCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNUCCProviderTaxonomy_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNUCCProviderTaxonomy_CodeSetNUCCProviderClassification] FOREIGN KEY ([ProviderClassificationID]) REFERENCES [dbo].[CodeSetNUCCProviderClassification] ([ProviderClassificationID]),
    CONSTRAINT [FK_CodeSetNUCCProviderTaxonomy_CodeSetNUCCProviderSpecialization] FOREIGN KEY ([ProviderSpecializationID]) REFERENCES [dbo].[CodeSetNUCCProviderSpecialization] ([ProviderSpecializationID]),
    CONSTRAINT [FK_CodeSetNUCCProviderTaxonomy_CodeSetNUCCProviderType] FOREIGN KEY ([ProviderTypeID]) REFERENCES [dbo].[CodeSetNUCCProviderType] ([ProviderTypeID]),
    CONSTRAINT [FK_CodeSetNUCCProviderTaxonomy_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetNUCCProviderTaxonomy] UNIQUE NONCLUSTERED ([TaxonomyCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

