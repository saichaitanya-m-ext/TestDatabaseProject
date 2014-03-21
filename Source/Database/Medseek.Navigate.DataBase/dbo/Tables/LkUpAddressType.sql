CREATE TABLE [dbo].[LkUpAddressType] (
    [AddressTypeID]        [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [AddressTypeCode]      VARCHAR (3)              NOT NULL,
    [AddressTypeName]      [dbo].[ShortDescription] NOT NULL,
    [TypeDescription]      [dbo].[LongDescription]  NULL,
    [DataSourceID]         [dbo].[KeyID]            NULL,
    [DataSourceFileID]     [dbo].[KeyID]            NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_LkUpAddressType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_LkUpAddressType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_LkUpAddressType] PRIMARY KEY CLUSTERED ([AddressTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_LkUpAddressType_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_LkUpAddressType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_LkUpAddressType_LastProvider] FOREIGN KEY ([LastModifiedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_LkUpAddressType_Provider] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpAddressType_AddressTypeCode]
    ON [dbo].[LkUpAddressType]([AddressTypeCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpAddressType_AddressTypeName]
    ON [dbo].[LkUpAddressType]([AddressTypeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

