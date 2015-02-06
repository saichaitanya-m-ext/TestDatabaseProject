CREATE TABLE [dbo].[CodeGroupingECTTable] (
    [CodeGroupingECTTableID] [dbo].[KeyID] IDENTITY (1, 1) NOT NULL,
    [CodeGroupingID]         [dbo].[KeyID] NOT NULL,
    [ECThedisTableID]        [dbo].[KeyID] NOT NULL,
    [ECTTableDescription]    VARCHAR (100) NULL,
    [ECTHedisCodeTypeID]     [dbo].[KeyID] NULL,
    [StatusCode]             VARCHAR (10)  CONSTRAINT [DF_CodeGroupingECTTable_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]        INT           NOT NULL,
    [CreatedDate]            DATETIME      CONSTRAINT [DF_CodeGroupingECTTable_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModifiedByUserId]   INT           NULL,
    [LastModifiedDate]       DATETIME      NULL,
    [ECTTableColumn]         VARCHAR (20)  NULL,
    CONSTRAINT [CodeGroupingECTTable_PK] PRIMARY KEY CLUSTERED ([CodeGroupingECTTableID] ASC),
    CONSTRAINT [FK_CodeGroupingECTTable_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_CodeGroupingECTTable_CodeSetECTHedisCodeType] FOREIGN KEY ([ECTHedisCodeTypeID]) REFERENCES [dbo].[CodeSetECTHedisCodeType] ([ECTHedisCodeTypeID]),
    CONSTRAINT [FK_CodeGroupingECTTable_CodeSetECTHedisTable] FOREIGN KEY ([ECThedisTableID]) REFERENCES [dbo].[CodeSetECTHedisTable] ([ECTHedisTableID])
);


GO
CREATE NONCLUSTERED INDEX [IX_CodeGroupingECTTable_CodeGroupingID_ECTHedisCodeTypeID_ECThedisTableID]
    ON [dbo].[CodeGroupingECTTable]([CodeGroupingID] ASC, [ECTHedisCodeTypeID] ASC, [ECThedisTableID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE STATISTICS [stat_CodeGroupingECTTable_ECTHedisCodeTypeID_CodeGroupingID]
    ON [dbo].[CodeGroupingECTTable]([ECTHedisCodeTypeID], [CodeGroupingID]);


GO
CREATE STATISTICS [stat_CodeGroupingECTTable_ECThedisTableID_CodeGroupingID]
    ON [dbo].[CodeGroupingECTTable]([ECThedisTableID], [CodeGroupingID]);


GO
CREATE STATISTICS [stat_CodeGroupingECTTable_ECThedisTableID_ECTHedisCodeTypeID_CodeGroupingID]
    ON [dbo].[CodeGroupingECTTable]([ECThedisTableID], [ECTHedisCodeTypeID], [CodeGroupingID]);

