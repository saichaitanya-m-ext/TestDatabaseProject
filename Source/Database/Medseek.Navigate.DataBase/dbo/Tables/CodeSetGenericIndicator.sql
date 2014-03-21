CREATE TABLE [dbo].[CodeSetGenericIndicator] (
    [GenericIndicatorID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [GenericIndicatorCode] VARCHAR (5)             NOT NULL,
    [GenericIndicatorName] VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetGenericIndicator_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetGenericIndicator_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetGenericIndicator] PRIMARY KEY CLUSTERED ([GenericIndicatorID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetGenericIndicator_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetGenericIndicator_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetGenericIndicator_IndicatorCode] UNIQUE NONCLUSTERED ([GenericIndicatorCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX],
    CONSTRAINT [UQ_CodeSetGenericIndicator_IndicatorName] UNIQUE NONCLUSTERED ([GenericIndicatorName] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

