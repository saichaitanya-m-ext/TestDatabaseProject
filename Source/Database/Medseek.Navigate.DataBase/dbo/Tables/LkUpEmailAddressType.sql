CREATE TABLE [dbo].[LkUpEmailAddressType] (
    [EmailAddressTypeID]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [EmailAddressTypeCode] VARCHAR (5)              NOT NULL,
    [EmailAddressTypeName] [dbo].[ShortDescription] NOT NULL,
    [TypeDescription]      [dbo].[LongDescription]  NULL,
    [DataSourceID]         [dbo].[KeyID]            NULL,
    [DataSourceFileID]     [dbo].[KeyID]            NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_LkUpEmailAddressType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_LkUpEmailAddressType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_LkUpEmailAddressType] PRIMARY KEY CLUSTERED ([EmailAddressTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_LkUpEmailAddressType_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_LkUpEmailAddressType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_LkUpEmailAddressType_TypeCode]
    ON [dbo].[LkUpEmailAddressType]([EmailAddressTypeCode] ASC)
    INCLUDE([EmailAddressTypeName]) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

