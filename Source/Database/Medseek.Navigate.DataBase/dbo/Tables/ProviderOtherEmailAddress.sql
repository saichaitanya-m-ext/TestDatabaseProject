CREATE TABLE [dbo].[ProviderOtherEmailAddress] (
    [ProviderEmailAddressID] INT           IDENTITY (1, 1) NOT NULL,
    [ProviderID]             INT           NOT NULL,
    [ContactName]            VARCHAR (60)  NULL,
    [ContactTitle]           VARCHAR (120) NULL,
    [EmailAddressTypeID]     INT           NOT NULL,
    [EmailAddress]           VARCHAR (256) NOT NULL,
    [RankOrder]              TINYINT       NOT NULL,
    [DataSourceID]           INT           NULL,
    [DataSourceFileID]       INT           NULL,
    [RecordTag_FileID]       VARCHAR (30)  NULL,
    [StatusCode]             VARCHAR (1)   CONSTRAINT [DF_ProviderOtherEmailAddress_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]        INT           NOT NULL,
    [CreatedDate]            DATETIME      CONSTRAINT [DF_ProviderOtherEmailAddress_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]   INT           NULL,
    [LastModifiedDate]       DATETIME      NULL,
    CONSTRAINT [PK_ProviderOtherEmailAddress] PRIMARY KEY CLUSTERED ([ProviderID] ASC, [EmailAddressTypeID] ASC, [EmailAddress] ASC),
    CONSTRAINT [FK_ProviderOtherEmailAddress_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ProviderOtherEmailAddress_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_ProviderOtherEmailAddress_LkUpEmailAddressType] FOREIGN KEY ([EmailAddressTypeID]) REFERENCES [dbo].[LkUpEmailAddressType] ([EmailAddressTypeID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_ProviderOtherEmailAddress_ProviderID]
    ON [dbo].[ProviderOtherEmailAddress]([ProviderID] ASC)
    INCLUDE([EmailAddressTypeID], [RankOrder]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

