CREATE TABLE [dbo].[ClaimProvider] (
    [ClaimProviderID]      [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [ClaimInfoID]          [dbo].[KeyID]       NOT NULL,
    [ProviderID]           [dbo].[KeyID]       NOT NULL,
    [ProviderRoleID]       [dbo].[KeyID]       NOT NULL,
    [ClaimLineID]          [dbo].[KeyID]       NULL,
    [DataSourceID]         [dbo].[KeyID]       NULL,
    [DataSourceFileID]     [dbo].[KeyID]       NULL,
    [RecordTag_FileID]     VARCHAR (30)        NULL,
    [StatusCode]           VARCHAR (1)         CONSTRAINT [DF_ClaimProvider_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_ClaimProvider_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    [HASPCPEncountered]    [dbo].[IsIndicator] NULL,
    CONSTRAINT [PK_ClaimProvider] PRIMARY KEY CLUSTERED ([ClaimInfoID] ASC, [ProviderID] ASC, [ProviderRoleID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_ClaimProvider_ClaimInfo] FOREIGN KEY ([ClaimInfoID]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_ClaimProvider_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ClaimProvider_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_ClaimProvider_LkUpProviderRole] FOREIGN KEY ([ProviderRoleID]) REFERENCES [dbo].[LkUpProviderRole] ([ProviderRoleID]),
    CONSTRAINT [FK_ClaimProvider_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_ClaimProvider_ClaimInfoID]
    ON [dbo].[ClaimProvider]([ClaimInfoID] ASC)
    INCLUDE([ProviderID], [ProviderRoleID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

