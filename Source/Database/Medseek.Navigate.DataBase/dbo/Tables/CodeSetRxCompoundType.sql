CREATE TABLE [dbo].[CodeSetRxCompoundType] (
    [RxCompoundTypeID]     [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [RxCompoundTypeCode]   VARCHAR (5)             NOT NULL,
    [RxCompoundTypeName]   VARCHAR (30)            NOT NULL,
    [CompoundDescription]  [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetRxCompoundType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetRxCompoundType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetRxCompoundType] PRIMARY KEY CLUSTERED ([RxCompoundTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetRxCompoundType_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetRxCompoundType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxCompoundType_TypeCode]
    ON [dbo].[CodeSetRxCompoundType]([RxCompoundTypeCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxCompoundType_TypeName]
    ON [dbo].[CodeSetRxCompoundType]([RxCompoundTypeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

