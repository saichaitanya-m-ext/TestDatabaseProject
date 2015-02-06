CREATE TABLE [dbo].[CodeSetECTHedisMeasure] (
    [ECTHedisMeasureID]    INT                IDENTITY (1, 1) NOT NULL,
    [ECTHedisMeasureCode]  VARCHAR (20)       NOT NULL,
    [MeasureDescription]   VARCHAR (255)      NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetECTHedisMeasure_StatusCode] DEFAULT ('A') NOT NULL,
    [DataSourceID]         [dbo].[KeyID]      NULL,
    [DataSourceFileID]     [dbo].[KeyID]      NULL,
    [CreatedByUserID]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_CodeSetECTHedisMeasure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_CodeSetECTHedisMeasure] PRIMARY KEY CLUSTERED ([ECTHedisMeasureID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetECTHedisMeasure_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetECTHedisMeasure_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetECTHedisMeasure_ECTMeasureCode] UNIQUE NONCLUSTERED ([ECTHedisMeasureCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ECT_HEDIS_Measure_ECTMeasureCode]
    ON [dbo].[CodeSetECTHedisMeasure]([ECTHedisMeasureCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

