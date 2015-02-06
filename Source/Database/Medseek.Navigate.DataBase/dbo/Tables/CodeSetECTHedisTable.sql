CREATE TABLE [dbo].[CodeSetECTHedisTable] (
    [ECTHedisTableID]      INT                IDENTITY (1, 1) NOT NULL,
    [ECTHedisTableName]    VARCHAR (10)       NOT NULL,
    [ECTHedisTableLetter]  VARCHAR (5)        NULL,
    [TableDescription]     VARCHAR (255)      NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetECTHedisTable_StatusCode] DEFAULT ('A') NOT NULL,
    [DataSourceID]         [dbo].[KeyID]      NULL,
    [DataSourceFileID]     [dbo].[KeyID]      NULL,
    [CreatedByUserID]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_CodeSetECTHedisTable_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_CodeSetECTHedisTable] PRIMARY KEY CLUSTERED ([ECTHedisTableID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetECTHedisTable_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetECTHedisTable_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetECTHedisTable_ECTTableName] UNIQUE NONCLUSTERED ([ECTHedisTableName] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ECTHEDISTable_ECTTableLetter_ECTTableName]
    ON [dbo].[CodeSetECTHedisTable]([ECTHedisTableLetter] ASC, [ECTHedisTableName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

