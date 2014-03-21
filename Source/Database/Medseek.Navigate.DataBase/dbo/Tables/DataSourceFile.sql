CREATE TABLE [dbo].[DataSourceFile] (
    [DataSourceFileID]     [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [DataSourceFileName]   VARCHAR (128)      NOT NULL,
    [FileDescription]      VARCHAR (255)      NULL,
    [FileTypeID]           [dbo].[KeyID]      NOT NULL,
    [FileSourceID]         [dbo].[KeyID]      NOT NULL,
    [FileLocation]         VARCHAR (255)      NULL,
    [FileID]               BIGINT             NULL,
    [DocumentNumber]       VARCHAR (80)       NULL,
    [ReceivedDate]         [dbo].[UserDate]   NULL,
    [HasBeenProcessed]     BIT                NOT NULL,
    [FirstProcessedDate]   [dbo].[UserDate]   NULL,
    [LastProcessedDate]    [dbo].[UserDate]   NULL,
    [StatusCode]           [dbo].[StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_DataSourceFile_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_DataSourceFile] PRIMARY KEY CLUSTERED ([DataSourceFileID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_DataSourceFile_LkUpFileSource] FOREIGN KEY ([FileSourceID]) REFERENCES [dbo].[LkUpFileSource] ([FileSourceID]),
    CONSTRAINT [FK_DataSourceFile_LkUpFileType] FOREIGN KEY ([FileTypeID]) REFERENCES [dbo].[LkUpFileType] ([FileTypeID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_DataSourceFile_DataSourceFileName]
    ON [dbo].[DataSourceFile]([DataSourceFileName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

