﻿CREATE TABLE [dbo].[CodeSetCMSProviderTaxonomySpecialtyCrosswalk] (
    [TaxonomySpecialtyCrosswalkID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [CMSProviderSpecialtyCodeID]   [dbo].[KeyID]      NOT NULL,
    [ProviderSupplierTypeID]       [dbo].[KeyID]      NOT NULL,
    [TaxonomyCodeID]               [dbo].[KeyID]      NOT NULL,
    [ProviderTypeID]               [dbo].[KeyID]      NOT NULL,
    [ProviderClassificationID]     [dbo].[KeyID]      NOT NULL,
    [ProviderSpecializationID]     [dbo].[KeyID]      NOT NULL,
    [DataSourceID]                 [dbo].[KeyID]      NULL,
    [DataSourceFileID]             [dbo].[KeyID]      NULL,
    [StatusCode]                   [dbo].[StatusCode] CONSTRAINT [DF_CodeSetCMSProviderTaxonomySpecialtyCrosswalk_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]              INT                NOT NULL,
    [CreatedDate]                  DATETIME           CONSTRAINT [DF_CodeSetCMSProviderTaxonomySpecialtyCrosswalk_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]         INT                NULL,
    [LastModifiedDate]             DATETIME           NULL,
    CONSTRAINT [PK_CodeSetCMSProviderTaxonomySpecialtyCrosswalk] PRIMARY KEY CLUSTERED ([CMSProviderSpecialtyCodeID] ASC, [ProviderSupplierTypeID] ASC, [TaxonomyCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetCMSProviderTaxonomySpecialtyCrosswalk_CodeSetCMSProviderSpecialty] FOREIGN KEY ([CMSProviderSpecialtyCodeID]) REFERENCES [dbo].[CodeSetCMSProviderSpecialty] ([CMSProviderSpecialtyCodeID]),
    CONSTRAINT [FK_CodeSetCMSProviderTaxonomySpecialtyCrosswalk_CodeSetCMSProviderSupplierType] FOREIGN KEY ([ProviderSupplierTypeID]) REFERENCES [dbo].[CodeSetCMSProviderSupplierType] ([ProviderSupplierTypeID]),
    CONSTRAINT [FK_CodeSetCMSProviderTaxonomySpecialtyCrosswalk_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetCMSProviderTaxonomySpecialtyCrosswalk_CodeSetNUCCProviderClassification] FOREIGN KEY ([ProviderClassificationID]) REFERENCES [dbo].[CodeSetNUCCProviderClassification] ([ProviderClassificationID]),
    CONSTRAINT [FK_CodeSetCMSProviderTaxonomySpecialtyCrosswalk_CodeSetNUCCProviderSpecialization] FOREIGN KEY ([ProviderSpecializationID]) REFERENCES [dbo].[CodeSetNUCCProviderSpecialization] ([ProviderSpecializationID]),
    CONSTRAINT [FK_CodeSetCMSProviderTaxonomySpecialtyCrosswalk_CodeSetNUCCProviderTaxonomy] FOREIGN KEY ([TaxonomyCodeID]) REFERENCES [dbo].[CodeSetNUCCProviderTaxonomy] ([TaxonomyCodeID]),
    CONSTRAINT [FK_CodeSetCMSProviderTaxonomySpecialtyCrosswalk_CodeSetNUCCProviderType] FOREIGN KEY ([ProviderTypeID]) REFERENCES [dbo].[CodeSetNUCCProviderType] ([ProviderTypeID]),
    CONSTRAINT [FK_CodeSetCMSProviderTaxonomySpecialtyCrosswalk_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);
