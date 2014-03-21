CREATE TABLE [dbo].[CodeSetOccurrenceSpanCode] (
    [OccurrenceSpanCodeID] [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [OccurrenceSpanCode]   VARCHAR (10)            NOT NULL,
    [OccurrenceSpanName]   VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetOccurrenceSpanCode_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetOccurrenceSpanCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetOccurrenceSpanCode] PRIMARY KEY CLUSTERED ([OccurrenceSpanCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetOccurrenceSpanCode_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetOccurrenceSpanCode_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetOccurrenceSpanCode_OccurrenceSpanCode]
    ON [dbo].[CodeSetOccurrenceSpanCode]([OccurrenceSpanCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetOccurrenceSpanCode_OccurrenceSpanName]
    ON [dbo].[CodeSetOccurrenceSpanCode]([OccurrenceSpanName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

