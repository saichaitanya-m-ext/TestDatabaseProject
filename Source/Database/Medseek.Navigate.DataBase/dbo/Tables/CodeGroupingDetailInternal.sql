CREATE TABLE [dbo].[CodeGroupingDetailInternal] (
    [CodeGroupingDetailInternalID] [dbo].[KeyID] IDENTITY (1, 1) NOT NULL,
    [CodeGroupingID]               [dbo].[KeyID] NOT NULL,
    [CodeGroupingCodeTypeID]       [dbo].[KeyID] NULL,
    [CodeGroupingCodeID]           VARCHAR (10)  NOT NULL,
    [StatusCode]                   VARCHAR (10)  CONSTRAINT [DF_CodeGroupingDetailIntrenal_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId]              [dbo].[KeyID] NULL,
    [CreatedDate]                  DATETIME      CONSTRAINT [DF_CodeGroupingDetailIntrenal_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModifiedByUserId]         [dbo].[KeyID] NULL,
    [LastModifiedDate]             DATETIME      NULL,
    CONSTRAINT [CodeGroupingDetailIntrenal_PK] PRIMARY KEY CLUSTERED ([CodeGroupingDetailInternalID] ASC),
    CONSTRAINT [FK_CodeGroupingDetailIntrenal_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_CodeGroupingDetailIntrenal_LkUpCodeType] FOREIGN KEY ([CodeGroupingCodeTypeID]) REFERENCES [dbo].[LkUpCodeType] ([CodeTypeID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeGroupingDetailIntrenal]
    ON [dbo].[CodeGroupingDetailInternal]([CodeGroupingID] ASC, [CodeGroupingCodeTypeID] ASC, [CodeGroupingCodeID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CodeGroupingDetailInternal_CodeGroupingID_CodeGroupingCodeTypeID]
    ON [dbo].[CodeGroupingDetailInternal]([CodeGroupingID] ASC, [CodeGroupingCodeTypeID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE STATISTICS [stat_CodeGroupingDetailInternal_CodeGroupingID_CodeGroupingCodeID]
    ON [dbo].[CodeGroupingDetailInternal]([CodeGroupingID], [CodeGroupingCodeID]);

