CREATE TABLE [dbo].[ProviderCareTeam] (
    [ProviderCareTeamID]   [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [ProviderID]           [dbo].[KeyID]    NOT NULL,
    [CareTeamId]           [dbo].[KeyID]    NOT NULL,
    [DataSourceID]         [dbo].[KeyID]    NULL,
    [DataSourceFileID]     [dbo].[KeyID]    NULL,
    [RecordTag_FileID]     VARCHAR (30)     NULL,
    [StatusCode]           VARCHAR (1)      CONSTRAINT [DF_ProviderCareTeam_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]    NOT NULL,
    [CreatedDate]          [dbo].[UserDate] CONSTRAINT [DF_ProviderCareTeam_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]    NULL,
    [LastModifiedDate]     [dbo].[UserDate] NULL,
    CONSTRAINT [PK_ProviderCareTeam] PRIMARY KEY CLUSTERED ([ProviderID] ASC, [CareTeamId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_ProviderCareTeam_CareTeam] FOREIGN KEY ([CareTeamId]) REFERENCES [dbo].[CareTeam] ([CareTeamId]),
    CONSTRAINT [FK_ProviderCareTeam_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ProviderCareTeam_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_ProviderCareTeam_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);

