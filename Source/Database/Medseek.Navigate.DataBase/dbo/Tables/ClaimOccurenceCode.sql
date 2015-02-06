CREATE TABLE [dbo].[ClaimOccurenceCode] (
    [ClaimOccurenceCodeID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [ClaimInfoID]          [dbo].[KeyID]    NOT NULL,
    [OccurrenceCodeID]     [dbo].[KeyID]    NOT NULL,
    [OccurenceDate]        [dbo].[UserDate] NULL,
    [DataSourceID]         [dbo].[KeyID]    NULL,
    [DataSourceFileID]     [dbo].[KeyID]    NULL,
    [RecordTag_FileID]     VARCHAR (30)     NULL,
    [StatusCode]           VARCHAR (1)      CONSTRAINT [DF_ClaimOccurenceCode_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]    NOT NULL,
    [CreatedDate]          [dbo].[UserDate] CONSTRAINT [DF_ClaimOccurenceCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]    NULL,
    [LastModifiedDate]     [dbo].[UserDate] NULL,
    CONSTRAINT [PK_ClaimOccurenceCode] PRIMARY KEY CLUSTERED ([ClaimInfoID] ASC, [OccurrenceCodeID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_ClaimOccurenceCode_ClaimInfo] FOREIGN KEY ([ClaimInfoID]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_ClaimOccurenceCode_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ClaimOccurenceCode_CodeSetOccurrenceCode] FOREIGN KEY ([OccurrenceCodeID]) REFERENCES [dbo].[CodeSetOccurrenceCode] ([OccurrenceCodeID]),
    CONSTRAINT [FK_ClaimOccurenceCode_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

