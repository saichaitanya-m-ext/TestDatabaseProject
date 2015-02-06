CREATE TABLE [dbo].[CodeGroupingDetailInternalHistory] (
    [CodeGroupingDetailInternalHistoryID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [CodeGroupingDetailInternalID]        [dbo].[KeyID]      NOT NULL,
    [CodeGroupingID]                      [dbo].[KeyID]      NOT NULL,
    [CodeGroupingCodeTypeID]              [dbo].[KeyID]      NOT NULL,
    [CodeGroupingCodeID]                  [dbo].[KeyID]      NOT NULL,
    [StatusCode]                          [dbo].[StatusCode] CONSTRAINT [DF_CodeGroupingDetailInternalHistory_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]                     [dbo].[KeyID]      NULL,
    [CreatedDate]                         DATETIME           CONSTRAINT [DF_CodeGroupingDetailInternalHistory_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModifiedByUserId]                [dbo].[KeyID]      NULL,
    [LastModifiedDate]                    DATETIME           NULL,
    CONSTRAINT [CodeGroupingDetailInternalHistory_PK] PRIMARY KEY CLUSTERED ([CodeGroupingDetailInternalHistoryID] ASC),
    CONSTRAINT [FK_CodeGroupingDetailInternalHistory_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_CodeGroupingDetailInternalHistory_CodeGroupingDetailInternal] FOREIGN KEY ([CodeGroupingDetailInternalID]) REFERENCES [dbo].[CodeGroupingDetailInternal] ([CodeGroupingDetailInternalID]),
    CONSTRAINT [FK_CodeGroupingDetailInternalHistory_LkUpCodeType] FOREIGN KEY ([CodeGroupingCodeTypeID]) REFERENCES [dbo].[LkUpCodeType] ([CodeTypeID])
);

