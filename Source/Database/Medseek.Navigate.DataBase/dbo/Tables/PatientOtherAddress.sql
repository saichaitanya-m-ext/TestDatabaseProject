CREATE TABLE [dbo].[PatientOtherAddress] (
    [PatientAddressID]      INT          IDENTITY (1, 1) NOT NULL,
    [PatientID]             INT          NOT NULL,
    [ContactName]           VARCHAR (60) NULL,
    [ContactRelationshipID] INT          NULL,
    [AddressTypeID]         INT          NOT NULL,
    [AddressLine1]          VARCHAR (60) NOT NULL,
    [AddressLine2]          VARCHAR (60) NOT NULL,
    [AddressLine3]          VARCHAR (60) NOT NULL,
    [City]                  VARCHAR (30) NULL,
    [StateID]               INT          NULL,
    [CountyID]              INT          NULL,
    [PostalCode]            VARCHAR (15) NOT NULL,
    [CountryID]             INT          NOT NULL,
    [RankOrder]             TINYINT      NOT NULL,
    [DataSourceID]          INT          NULL,
    [DataSourceFileID]      INT          NULL,
    [RecordTagFileID]       VARCHAR (30) NULL,
    [StatusCode]            VARCHAR (1)  CONSTRAINT [DF_PatientOtherAddress_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]       INT          NOT NULL,
    [CreatedDate]           DATETIME     CONSTRAINT [DF_PatientOtherAddress_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]  INT          NULL,
    [LastModifiedDate]      DATETIME     NULL,
    CONSTRAINT [PK_PatientOtherAddress] PRIMARY KEY CLUSTERED ([PatientID] ASC, [AddressTypeID] ASC, [AddressLine1] ASC, [AddressLine2] ASC, [AddressLine3] ASC, [PostalCode] ASC, [CountryID] ASC),
    CONSTRAINT [FK_PatientOtherAddress_CodeSetCountry] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[CodeSetCountry] ([CountryID]),
    CONSTRAINT [FK_PatientOtherAddress_CodeSetCounty] FOREIGN KEY ([CountyID]) REFERENCES [dbo].[CodeSetCounty] ([CountyID]),
    CONSTRAINT [FK_PatientOtherAddress_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientOtherAddress_CodeSetRelation] FOREIGN KEY ([ContactRelationshipID]) REFERENCES [dbo].[CodeSetRelation] ([RelationId]),
    CONSTRAINT [FK_PatientOtherAddress_CodeSetState] FOREIGN KEY ([StateID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_PatientOtherAddress_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientOtherAddress_LkUpAddressType] FOREIGN KEY ([AddressTypeID]) REFERENCES [dbo].[LkUpAddressType] ([AddressTypeID]),
    CONSTRAINT [FK_PatientOtherAddress_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_PatientOtherAddress_PatientID]
    ON [dbo].[PatientOtherAddress]([PatientID] ASC)
    INCLUDE([AddressTypeID], [RankOrder]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

