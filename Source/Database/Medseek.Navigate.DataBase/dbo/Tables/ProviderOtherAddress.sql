CREATE TABLE [dbo].[ProviderOtherAddress] (
    [ProviderAddressID]    INT           IDENTITY (1, 1) NOT NULL,
    [ProviderID]           INT           NOT NULL,
    [ContactName]          VARCHAR (60)  NULL,
    [ContactTitle]         VARCHAR (120) NULL,
    [AddressTypeID]        INT           NOT NULL,
    [AddressLine1]         VARCHAR (60)  NOT NULL,
    [AddressLine2]         VARCHAR (60)  NOT NULL,
    [AddressLine3]         VARCHAR (60)  NOT NULL,
    [City]                 VARCHAR (60)  NULL,
    [StateID]              INT           NULL,
    [CountyID]             INT           NULL,
    [PostalCode]           VARCHAR (20)  NOT NULL,
    [CountryID]            INT           NOT NULL,
    [RankOrder]            TINYINT       NOT NULL,
    [DataSourceID]         INT           NULL,
    [DataSourceFileID]     INT           NULL,
    [RecordTagFileID]      VARCHAR (30)  NULL,
    [StatusCode]           VARCHAR (1)   CONSTRAINT [DF_ProviderOtherAddress_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      INT           NOT NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_ProviderOtherAddress_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] INT           NULL,
    [LastModifiedDate]     DATETIME      NULL,
    CONSTRAINT [PK_ProviderOtherAddress] PRIMARY KEY CLUSTERED ([ProviderID] ASC, [AddressTypeID] ASC, [AddressLine1] ASC, [AddressLine2] ASC, [AddressLine3] ASC, [PostalCode] ASC, [CountryID] ASC),
    CONSTRAINT [FK_ProviderAddressID_LkUpAddressType] FOREIGN KEY ([AddressTypeID]) REFERENCES [dbo].[LkUpAddressType] ([AddressTypeID]),
    CONSTRAINT [FK_ProviderOtherAddress_CodeSetCountry] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[CodeSetCountry] ([CountryID]),
    CONSTRAINT [FK_ProviderOtherAddress_CodeSetCounty] FOREIGN KEY ([CountyID]) REFERENCES [dbo].[CodeSetCounty] ([CountyID]),
    CONSTRAINT [FK_ProviderOtherAddress_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ProviderOtherAddress_CodeSetState] FOREIGN KEY ([StateID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_ProviderOtherAddress_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_ProviderOtherAddress_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_ProviderOtherAddress_ProviderID]
    ON [dbo].[ProviderOtherAddress]([ProviderID] ASC)
    INCLUDE([AddressTypeID], [RankOrder]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

