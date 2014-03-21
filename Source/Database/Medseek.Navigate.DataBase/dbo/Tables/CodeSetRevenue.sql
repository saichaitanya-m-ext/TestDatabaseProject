CREATE TABLE [dbo].[CodeSetRevenue] (
    [RevenueCodeID]        [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [RevenueCode]          VARCHAR (10)       NOT NULL,
    [Description]          VARCHAR (4000)     NOT NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetRevenue_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_CodeSetRevenue_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    [BeginDate]            DATE               CONSTRAINT [DF_CodeSetRevenue_BeginDate] DEFAULT ('01/01/2000') NULL,
    [EndDate]              DATE               CONSTRAINT [DF_CodeSetRevenue_EndDate] DEFAULT ('01/01/2020') NULL,
    [DataSourceID]         [dbo].[KeyID]      NULL,
    [DataFileID]           [dbo].[KeyID]      NULL,
    CONSTRAINT [PK_CodeSetRevenue] PRIMARY KEY CLUSTERED ([RevenueCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetRevenueCode_DataSourceFile] FOREIGN KEY ([DataFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UK_CodesetRevenue_RevenueCode] UNIQUE NONCLUSTERED ([RevenueCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

