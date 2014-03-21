CREATE TABLE [dbo].[ClaimConditionCode] (
    [ClaimConditionCodeID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [ClaimInfoID]          [dbo].[KeyID]    NOT NULL,
    [ConditionCodeID]      [dbo].[KeyID]    NOT NULL,
    [DataSourceID]         [dbo].[KeyID]    NULL,
    [DataSourceFileID]     [dbo].[KeyID]    NULL,
    [RecordTagFileID]      VARCHAR (30)     NULL,
    [StatusCode]           VARCHAR (1)      CONSTRAINT [DF_ClaimConditionCode_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]    NOT NULL,
    [CreatedDate]          [dbo].[UserDate] CONSTRAINT [DF_ClaimConditionCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]    NULL,
    [LastModifiedDate]     [dbo].[UserDate] NULL,
    CONSTRAINT [PK_ClaimConditionCode] PRIMARY KEY CLUSTERED ([ClaimInfoID] ASC, [ConditionCodeID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_ClaimConditionCode_ClaimInfo] FOREIGN KEY ([ClaimInfoID]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_ClaimConditionCode_CodeSetConditionCode] FOREIGN KEY ([ConditionCodeID]) REFERENCES [dbo].[CodeSetConditionCode] ([ConditionCodeID]),
    CONSTRAINT [FK_ClaimConditionCode_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ClaimConditionCode_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

