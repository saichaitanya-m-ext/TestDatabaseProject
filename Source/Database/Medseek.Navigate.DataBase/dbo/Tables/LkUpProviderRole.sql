CREATE TABLE [dbo].[LkUpProviderRole] (
    [ProviderRoleID]       [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ProviderRoleCode]     VARCHAR (5)              NOT NULL,
    [ProviderRoleName]     [dbo].[ShortDescription] NOT NULL,
    [RoleDescription]      [dbo].[LongDescription]  NULL,
    [DataSourceID]         [dbo].[KeyID]            NULL,
    [DataSourceFileID]     [dbo].[KeyID]            NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_LkUpProviderRole_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_LkUpProviderRole_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_LkUpProviderRole] PRIMARY KEY CLUSTERED ([ProviderRoleID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_LkUpProviderRole_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_LkUpProviderRole_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpProviderRole_ProviderRoleCode]
    ON [dbo].[LkUpProviderRole]([ProviderRoleCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpProviderRole_ProviderRoleName]
    ON [dbo].[LkUpProviderRole]([ProviderRoleName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

