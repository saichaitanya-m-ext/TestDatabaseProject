CREATE TABLE [dbo].[CodeSetNPIProviderIDIssuer] (
    [ProviderIDIssuerCodeID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [ProviderIDIssuerCode]   VARCHAR (2)        NOT NULL,
    [ProviderIDIssuer]       VARCHAR (30)       NOT NULL,
    [IDIssuerDescription]    VARCHAR (255)      NULL,
    [EntityTypeID]           [dbo].[KeyID]      NOT NULL,
    [DataSourceID]           [dbo].[KeyID]      NULL,
    [DataSourceFileID]       [dbo].[KeyID]      NULL,
    [StatusCode]             [dbo].[StatusCode] CONSTRAINT [DF_CodeSetNPIOtherProviderIDIssuer_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]        INT                NOT NULL,
    [CreatedDate]            DATETIME           CONSTRAINT [DF_CodeSetNPIOtherProviderIDIssuer_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   INT                NULL,
    [LastModifiedDate]       DATETIME           NULL,
    CONSTRAINT [PK_CodeSetNPIOtherProviderIDIssuer] PRIMARY KEY CLUSTERED ([ProviderIDIssuerCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNPIOtherProviderIDIssuer_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNPIOtherProviderIDIssuer_CodeSetEntityType] FOREIGN KEY ([EntityTypeID]) REFERENCES [dbo].[CodeSetEntityType] ([EntityTypeID]),
    CONSTRAINT [FK_CodeSetNPIOtherProviderIDIssuer_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetNPIProviderIDIssuer_OtherProviderIDIssuerCode]
    ON [dbo].[CodeSetNPIProviderIDIssuer]([ProviderIDIssuerCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetNPIProviderIDIssuer_ProviderIDIssuer]
    ON [dbo].[CodeSetNPIProviderIDIssuer]([ProviderIDIssuer] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

