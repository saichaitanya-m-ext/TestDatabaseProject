CREATE TABLE [dbo].[CodeSetNPIProviderNameType] (
    [ProviderNameTypeCodeID] [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [ProviderNameTypeCode]   VARCHAR (2)             NOT NULL,
    [ProviderNameType]       VARCHAR (30)            NOT NULL,
    [NameTypeDescription]    [dbo].[LongDescription] NULL,
    [EntityTypeID]           [dbo].[KeyID]           NOT NULL,
    [DataSourceID]           [dbo].[KeyID]           NULL,
    [DataSourceFileID]       [dbo].[KeyID]           NULL,
    [StatusCode]             [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetNPIOtherProviderNameType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]        INT                     NOT NULL,
    [CreatedDate]            DATETIME                CONSTRAINT [DF_CodeSetNPIOtherProviderNameType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   INT                     NULL,
    [LastModifiedDate]       DATETIME                NULL,
    CONSTRAINT [PK_CodeSetNPIOtherProviderNameType] PRIMARY KEY CLUSTERED ([ProviderNameTypeCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNPIOtherProviderNameType_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNPIOtherProviderNameType_CodeSetEntityType] FOREIGN KEY ([EntityTypeID]) REFERENCES [dbo].[CodeSetEntityType] ([EntityTypeID]),
    CONSTRAINT [FK_CodeSetNPIOtherProviderNameType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetNPIOtherProviderNameType_OtherProviderNameType] UNIQUE NONCLUSTERED ([ProviderNameType] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX],
    CONSTRAINT [UQ_CodeSetNPIOtherProviderNameType_OtherProviderNameTypeCode] UNIQUE NONCLUSTERED ([ProviderNameTypeCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

