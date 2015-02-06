CREATE TABLE [dbo].[CodeSetPharmacyServiceType] (
    [PharmacyServiceTypeID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PharmacyServiceTypeCode] VARCHAR (5)             NOT NULL,
    [PharmacyServiceTypeName] VARCHAR (30)            NOT NULL,
    [CodeDescription]         [dbo].[LongDescription] NULL,
    [DataSourceID]            [dbo].[KeyID]           NULL,
    [DataSourceFileID]        [dbo].[KeyID]           NULL,
    [StatusCode]              [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetPharmacyServiceType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]         INT                     NOT NULL,
    [CreatedDate]             DATETIME                CONSTRAINT [DF_CodeSetPharmacyServiceType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    INT                     NULL,
    [LastModifiedDate]        DATETIME                NULL,
    CONSTRAINT [PK_CodeSetPharmacyServiceType] PRIMARY KEY CLUSTERED ([PharmacyServiceTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetPharmacyServiceType_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetPharmacyServiceType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetPharmacyServiceType_TypeCode]
    ON [dbo].[CodeSetPharmacyServiceType]([PharmacyServiceTypeCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetPharmacyServiceType_TypeName]
    ON [dbo].[CodeSetPharmacyServiceType]([PharmacyServiceTypeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

