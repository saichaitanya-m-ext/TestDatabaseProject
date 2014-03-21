CREATE TABLE [dbo].[ClaimOccurenceSpanCode] (
    [ClaimOccurenceSpanCodeID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [ClaimInfoID]              [dbo].[KeyID]    NOT NULL,
    [OccurrenceSpanCodeID]     [dbo].[KeyID]    NOT NULL,
    [OccurenceSpanDate]        [dbo].[UserDate] NULL,
    [DataSourceID]             [dbo].[KeyID]    NULL,
    [DataSourceFileID]         [dbo].[KeyID]    NULL,
    [RecordTagFileID]          VARCHAR (30)     NULL,
    [StatusCode]               VARCHAR (1)      CONSTRAINT [DF_ClaimOccurenceSpanCode_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]          [dbo].[KeyID]    NOT NULL,
    [CreatedDate]              [dbo].[UserDate] CONSTRAINT [DF_ClaimOccurenceSpanCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]     [dbo].[KeyID]    NULL,
    [LastModifiedDate]         [dbo].[UserDate] NULL,
    CONSTRAINT [PK_ClaimOccurenceSpanCode] PRIMARY KEY CLUSTERED ([ClaimInfoID] ASC, [OccurrenceSpanCodeID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_ClaimOccurenceSpanCode_ClaimInfo] FOREIGN KEY ([ClaimInfoID]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_ClaimOccurenceSpanCode_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ClaimOccurenceSpanCode_CodeSetOccurrenceSpanCode] FOREIGN KEY ([OccurrenceSpanCodeID]) REFERENCES [dbo].[CodeSetOccurrenceSpanCode] ([OccurrenceSpanCodeID]),
    CONSTRAINT [FK_ClaimOccurenceSpanCode_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

