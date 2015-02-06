CREATE TABLE [dbo].[CodeSetMDC] (
    [MDCCodeID]            [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [MDCCode]              VARCHAR (10)       NOT NULL,
    [CodeDescription]      VARCHAR (1000)     NULL,
    [BeginDate]            DATE               NOT NULL,
    [EndDate]              DATE               CONSTRAINT [DF_CodeSetMDC_EndDate] DEFAULT ('01-01-2100') NOT NULL,
    [DataSourceID]         [dbo].[KeyID]      NULL,
    [DataSourceFileID]     [dbo].[KeyID]      NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetMDC_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                NOT NULL,
    [CreatedDate]          DATETIME           CONSTRAINT [DF_CodeSetMDC_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                NULL,
    [LastModifiedDate]     DATETIME           NULL,
    CONSTRAINT [PK_CodeSetMDC] PRIMARY KEY CLUSTERED ([MDCCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetMDC_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetMDC_MDCCode] UNIQUE NONCLUSTERED ([MDCCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

