CREATE TABLE [dbo].[CodeSetMSDRG] (
    [MSDRGCodeID]          [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [MSDRGCode]            VARCHAR (10)       NOT NULL,
    [CodeDescription]      VARCHAR (1000)     NULL,
    [BeginDate]            DATE               NOT NULL,
    [EndDate]              DATE               CONSTRAINT [DF_CodeSetMSDRG_EndDate] DEFAULT ('01-01-2100') NOT NULL,
    [DataSourceID]         [dbo].[KeyID]      NULL,
    [DataSourceFileID]     [dbo].[KeyID]      NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetMSDRG_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                NOT NULL,
    [CreatedDate]          DATETIME           CONSTRAINT [DF_CodeSetMSDRG_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                NULL,
    [LastModifiedDate]     DATETIME           NULL,
    [MDCCodeID]            INT                NULL,
    CONSTRAINT [PK_CodeSetMSDRG] PRIMARY KEY CLUSTERED ([MSDRGCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetMSDRG_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetMSDRG_CodeSetMDC] FOREIGN KEY ([MDCCodeID]) REFERENCES [dbo].[CodeSetMDC] ([MDCCodeID]),
    CONSTRAINT [FK_CodeSetMSDRG_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetMSDRG_MSDRGCode] UNIQUE NONCLUSTERED ([MSDRGCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

