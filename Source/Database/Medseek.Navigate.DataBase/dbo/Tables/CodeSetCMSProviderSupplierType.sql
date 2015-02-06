CREATE TABLE [dbo].[CodeSetCMSProviderSupplierType] (
    [ProviderSupplierTypeID]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ProviderSupplierTypeName] [dbo].[ShortDescription] NOT NULL,
    [SupplierTypeDescription]  [dbo].[LongDescription]  NULL,
    [DataSourceID]             [dbo].[KeyID]            NULL,
    [DataSourceFileID]         [dbo].[KeyID]            NULL,
    [StatusCode]               [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetCMSProviderSupplierType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]          INT                      NOT NULL,
    [CreatedDate]              DATETIME                 CONSTRAINT [DF_CodeSetCMSProviderSupplierType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]     INT                      NULL,
    [LastModifiedDate]         DATETIME                 NULL,
    CONSTRAINT [PK_CodeSetCMSProviderSupplierType] PRIMARY KEY CLUSTERED ([ProviderSupplierTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetCMSProviderSupplierType_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetCMSProviderSupplierType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetCMSProviderSupplierType_ProviderSupplierTypeName]
    ON [dbo].[CodeSetCMSProviderSupplierType]([ProviderSupplierTypeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

