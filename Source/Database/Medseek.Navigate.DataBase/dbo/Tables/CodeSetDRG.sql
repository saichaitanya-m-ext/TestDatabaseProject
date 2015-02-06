CREATE TABLE [dbo].[CodeSetDRG] (
    [DRGCodeID]            [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [DRGCode]              VARCHAR (10)            NOT NULL,
    [DRGCodeName]          VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [BeginDate]            DATE                    NOT NULL,
    [EndDate]              DATE                    NOT NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetDRG_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetDRG_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetDRG] PRIMARY KEY CLUSTERED ([DRGCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetDRG_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetDRG_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetDRG_DRGCode]
    ON [dbo].[CodeSetDRG]([DRGCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetDRG_DRGCodeName]
    ON [dbo].[CodeSetDRG]([DRGCodeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

