CREATE TABLE [dbo].[CodeSetRxPriorAuthorizationType] (
    [RxPriorAuthorizationTypeID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [RxPriorAuthorizationTypeCode] VARCHAR (5)             NOT NULL,
    [RxPriorAuthorizationTypeName] VARCHAR (30)            NOT NULL,
    [CodeDescription]              [dbo].[LongDescription] NULL,
    [DataSourceID]                 [dbo].[KeyID]           NULL,
    [DataSourceFileID]             [dbo].[KeyID]           NULL,
    [StatusCode]                   [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetRxPriorAuthorizationType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]              INT                     NOT NULL,
    [CreatedDate]                  DATETIME                CONSTRAINT [DF_CodeSetRxPriorAuthorizationType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]         INT                     NULL,
    [LastModifiedDate]             DATETIME                NULL,
    CONSTRAINT [PK_CodeSetRxPriorAuthorizationType] PRIMARY KEY CLUSTERED ([RxPriorAuthorizationTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetRxPriorAuthorizationType_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetRxPriorAuthorizationType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxPriorAuthorizationType_TypeCode]
    ON [dbo].[CodeSetRxPriorAuthorizationType]([RxPriorAuthorizationTypeCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxPriorAuthorizationType_TypeName]
    ON [dbo].[CodeSetRxPriorAuthorizationType]([RxPriorAuthorizationTypeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

