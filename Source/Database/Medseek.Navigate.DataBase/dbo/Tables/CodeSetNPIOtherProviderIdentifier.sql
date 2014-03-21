CREATE TABLE [dbo].[CodeSetNPIOtherProviderIdentifier] (
    [ProviderOtherProviderID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [NPINumberID]             [dbo].[KeyID]      NOT NULL,
    [ProviderIdentifier]      VARCHAR (80)       NOT NULL,
    [ProviderNameTypeCodeID]  [dbo].[KeyID]      NULL,
    [StateID]                 [dbo].[KeyID]      NULL,
    [DataSourceID]            [dbo].[KeyID]      NULL,
    [DataSourceFileID]        [dbo].[KeyID]      NULL,
    [StatusCode]              [dbo].[StatusCode] CONSTRAINT [DF_CodeSetNPIOtherProviderIdentifier_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]         INT                NOT NULL,
    [CreatedDate]             DATETIME           CONSTRAINT [DF_CodeSetNPIOtherProviderIdentifier_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    INT                NULL,
    [LastModifiedDate]        DATETIME           NULL,
    [ProviderIDIssuerCodeID]  INT                NULL,
    CONSTRAINT [PK_CodeSetNPIOtherProviderIdentifier] PRIMARY KEY CLUSTERED ([ProviderOtherProviderID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNPIOtherProviderIdentifier_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNPIOtherProviderIdentifier_CodeSetNPI] FOREIGN KEY ([NPINumberID]) REFERENCES [dbo].[CodeSetNPI] ([NPINumberID]),
    CONSTRAINT [FK_CodeSetNPIOtherProviderIdentifier_CodeSetNPIOtherProviderIDIssuer] FOREIGN KEY ([ProviderIDIssuerCodeID]) REFERENCES [dbo].[CodeSetNPIProviderIDIssuer] ([ProviderIDIssuerCodeID]),
    CONSTRAINT [FK_CodeSetNPIOtherProviderIdentifier_CodeSetNPIOtherProviderNameType] FOREIGN KEY ([ProviderNameTypeCodeID]) REFERENCES [dbo].[CodeSetNPIProviderNameType] ([ProviderNameTypeCodeID]),
    CONSTRAINT [FK_CodeSetNPIOtherProviderIdentifier_CodeSetState] FOREIGN KEY ([StateID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_CodeSetNPIOtherProviderIdentifier_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

