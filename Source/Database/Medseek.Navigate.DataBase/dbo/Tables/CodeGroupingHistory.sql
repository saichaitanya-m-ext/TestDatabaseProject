CREATE TABLE [dbo].[CodeGroupingHistory] (
    [CodeGroupingHistoryID]   [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [CodeGroupingID]          [dbo].[KeyID]      NULL,
    [DefinitionVersion]       VARCHAR (5)        CONSTRAINT [DF_CodeGroupingHistory_DefinitionVersion] DEFAULT ('1.0') NULL,
    [CodeGroupingTypeID]      [dbo].[KeyID]      NULL,
    [CodeGroupingName]        VARCHAR (50)       NULL,
    [ECTHedisTableID]         [dbo].[KeyID]      NULL,
    [ECTTableDescription]     VARCHAR (100)      NULL,
    [CodeGroupingDescription] VARCHAR (500)      NULL,
    [CodeGroupingSource]      VARCHAR (20)       NULL,
    [CodeGroupingSynonym]     VARCHAR (200)      NULL,
    [NonModifiable]           BIT                CONSTRAINT [DF_CodeGroupingHistory_NonModifiable] DEFAULT ((1)) NULL,
    [IsPrimary]               BIT                NULL,
    [ProductionStatus]        [dbo].[StatusCode] NULL,
    [DisplayStatus]           BIT                NULL,
    [StatusCode]              [dbo].[StatusCode] CONSTRAINT [DF_CodeGroupingHistory_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]         [dbo].[KeyID]      NOT NULL,
    [CreatedDate]             [dbo].[UserDate]   CONSTRAINT [DF_CodeGroupingHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    [dbo].[KeyID]      NULL,
    [LastModifiedDate]        [dbo].[UserDate]   NULL,
    CONSTRAINT [CodeGroupingHistory_PK] PRIMARY KEY CLUSTERED ([CodeGroupingHistoryID] ASC),
    CONSTRAINT [FK_CodeGroupingHistory_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_CodeGroupingHistory_CodeGroupingType] FOREIGN KEY ([CodeGroupingTypeID]) REFERENCES [dbo].[CodeGroupingType] ([CodeGroupingTypeID]),
    CONSTRAINT [FK_CodeGroupingHistory_CodeSetECTHedisTable] FOREIGN KEY ([ECTHedisTableID]) REFERENCES [dbo].[CodeSetECTHedisTable] ([ECTHedisTableID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeGroupingHistory_CodeGroupingHistoryID]
    ON [dbo].[CodeGroupingHistory]([DefinitionVersion] ASC, [CodeGroupingID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

