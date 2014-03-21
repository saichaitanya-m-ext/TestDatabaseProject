CREATE TABLE [dbo].[FileStatus] (
    [FileID]              INT           IDENTITY (1, 1) NOT NULL,
    [Name]                VARCHAR (300) NULL,
    [RootPath]            VARCHAR (500) NULL,
    [FileFullPath]        VARCHAR (500) NULL,
    [FileSize]            VARCHAR (20)  NULL,
    [UploadedDate]        VARCHAR (30)  NULL,
    [NoOfRecords]         INT           NULL,
    [FileType]            VARCHAR (15)  NULL,
    [FileStatus]          VARCHAR (50)  NULL,
    [ModifiedDate]        DATETIME      NULL,
    [DirName]             VARCHAR (200) NULL,
    [StartTime]           DATETIME      NULL,
    [EndTime]             DATETIME      NULL,
    [ElapsedTime]         VARCHAR (16)  NULL,
    [IsError]             BIT           NULL,
    [SourceRecordsCount]  INT           NULL,
    [ProcessedCount]      INT           NULL,
    [NonProcessedCount]   INT           NULL,
    [CreatedDate]         DATETIME      CONSTRAINT [DF_FileStatus_CreatedDate] DEFAULT (getdate()) NULL,
    [ExistingRecordCount] INT           NULL,
    [NewRecordCount]      INT           NULL,
    CONSTRAINT [PK_FileStatus] PRIMARY KEY CLUSTERED ([FileID] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FileStatus', @level2type = N'COLUMN', @level2name = N'CreatedDate';

