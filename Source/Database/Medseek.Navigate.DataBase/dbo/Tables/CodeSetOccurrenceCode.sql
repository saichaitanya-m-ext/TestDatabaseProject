CREATE TABLE [dbo].[CodeSetOccurrenceCode] (
    [OccurrenceCodeID]     [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [OccurrenceCode]       VARCHAR (10)            NOT NULL,
    [OccurrenceName]       VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetOccurrenceCode_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetOccurrenceCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetOccurrenceCode] PRIMARY KEY CLUSTERED ([OccurrenceCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetOccurrenceCode_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetOccurrenceCode_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetOccurrenceCode_OccurrenceCode]
    ON [dbo].[CodeSetOccurrenceCode]([OccurrenceCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetOccurrenceCode_OccurrenceName]
    ON [dbo].[CodeSetOccurrenceCode]([OccurrenceName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

