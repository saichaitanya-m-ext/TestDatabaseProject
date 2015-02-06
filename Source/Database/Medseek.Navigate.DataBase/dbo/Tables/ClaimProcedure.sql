CREATE TABLE [dbo].[ClaimProcedure] (
    [ClaimProcedureID]     [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [ClaimInfoID]          [dbo].[KeyID]    NOT NULL,
    [ProcedureCodeID]      [dbo].[KeyID]    NOT NULL,
    [RankOrder]            TINYINT          NOT NULL,
    [DataSourceID]         [dbo].[KeyID]    NULL,
    [DataSourceFileID]     [dbo].[KeyID]    NULL,
    [RecordTag_FileID]     VARCHAR (30)     NULL,
    [StatusCode]           VARCHAR (1)      CONSTRAINT [DF_ClaimProcedure_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]    NOT NULL,
    [CreatedDate]          [dbo].[UserDate] CONSTRAINT [DF_ClaimProcedure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]    NULL,
    [LastModifiedDate]     [dbo].[UserDate] NULL,
    CONSTRAINT [PK_ClaimProcedure] PRIMARY KEY CLUSTERED ([ClaimProcedureID] ASC),
    CONSTRAINT [FK_ClaimProcedure_ClaimInfo] FOREIGN KEY ([ClaimInfoID]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_ClaimProcedure_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ClaimProcedure_CodeSetICDProcedure] FOREIGN KEY ([ProcedureCodeID]) REFERENCES [dbo].[CodeSetICDProcedure] ([ProcedureCodeID]),
    CONSTRAINT [FK_ClaimProcedure_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE NONCLUSTERED INDEX [IX_ClaimProcedure_ClaimInfoID]
    ON [dbo].[ClaimProcedure]([ClaimInfoID] ASC)
    INCLUDE([ClaimProcedureID], [ProcedureCodeID], [RankOrder]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE STATISTICS [stat_ClaimProcedure_ProcedureCodeID_ClaimInfoID]
    ON [dbo].[ClaimProcedure]([ProcedureCodeID], [ClaimInfoID]);

