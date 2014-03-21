CREATE TABLE [dbo].[CodeSetRxClaimSource] (
    [RxClaimSourceID]      [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [RxClaimSource]        VARCHAR (30)            NOT NULL,
    [SourceDescription]    [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetRxClaimSoure_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetRxClaimSoure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetRxClaimSoure] PRIMARY KEY CLUSTERED ([RxClaimSourceID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetRxClaimSoure_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetRxClaimSoure_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxClaimSoure_RxClaimSource]
    ON [dbo].[CodeSetRxClaimSource]([RxClaimSource] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

