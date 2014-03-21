CREATE TABLE [dbo].[CodeSetICDCodeGroup] (
    [ICDCodeGroupId]       [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ICDCodeGroupName]     [dbo].[ShortDescription] NOT NULL,
    [GroupDescription]     [dbo].[LongDescription]  NULL,
    [DataSourceID]         [dbo].[KeyID]            NULL,
    [DataSourceFileID]     [dbo].[KeyID]            NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetICDCodeGroup_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_CodeSetICDCodeGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_CodeSetICDCodeGroup] PRIMARY KEY CLUSTERED ([ICDCodeGroupId] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetICDCodeGroup_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetICDCodeGroup_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetICDCodeGroup_ICDCodeGroupName]
    ON [dbo].[CodeSetICDCodeGroup]([ICDCodeGroupName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

