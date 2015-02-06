CREATE TABLE [dbo].[CodeSetUnitOfMeasure] (
    [UnitOfMeasureID]      [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [UnitCode]             VARCHAR (5)             NOT NULL,
    [UnitName]             VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetUnitsOfMeasure_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetUnitsOfMeasure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetUnitsOfMeasure] PRIMARY KEY CLUSTERED ([UnitOfMeasureID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetUnitsOfMeasure_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetUnitsOfMeasure_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetUnitsOfMeasure_UnitCode]
    ON [dbo].[CodeSetUnitOfMeasure]([UnitCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetUnitsOfMeasure_UnitName]
    ON [dbo].[CodeSetUnitOfMeasure]([UnitName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

