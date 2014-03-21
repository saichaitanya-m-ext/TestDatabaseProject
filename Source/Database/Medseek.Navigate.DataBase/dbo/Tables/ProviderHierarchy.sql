CREATE TABLE [dbo].[ProviderHierarchy] (
    [ProviderHierarchyID]  [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [HierarchyName]        [dbo].[LongDescription] NOT NULL,
    [HierarchyDescription] VARCHAR (1000)          NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [RecordTagFileID]      VARCHAR (30)            NULL,
    [StatusCode]           VARCHAR (1)             CONSTRAINT [DF_ProviderHierarchy_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]           NOT NULL,
    [CreatedDate]          [dbo].[UserDate]        CONSTRAINT [DF_ProviderHierarchy_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]           NULL,
    [LastModifiedDate]     [dbo].[UserDate]        NULL,
    CONSTRAINT [PK_ProviderHierarchy] PRIMARY KEY CLUSTERED ([ProviderHierarchyID] ASC),
    CONSTRAINT [FK_ProviderHierarchy_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ProviderHierarchy_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

