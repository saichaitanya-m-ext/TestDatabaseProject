CREATE TABLE [dbo].[ProviderHierarchyLevel] (
    [ProviderHierarchyLevelID] [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [ProviderHierarchyID]      [dbo].[KeyID]           NOT NULL,
    [HierarchyLevelName]       [dbo].[LongDescription] NULL,
    [HierarchyLevelNumber]     SMALLINT                NOT NULL,
    [DataSourceID]             [dbo].[KeyID]           NULL,
    [DataSourceFileID]         [dbo].[KeyID]           NULL,
    [RecordTagFileID]          VARCHAR (30)            NULL,
    [StatusCode]               VARCHAR (1)             CONSTRAINT [DF_ProviderHierarchyLevel_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]          [dbo].[KeyID]           NOT NULL,
    [CreatedDate]              [dbo].[UserDate]        CONSTRAINT [DF_ProviderHierarchyLevel_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]     [dbo].[KeyID]           NULL,
    [LastModifiedDate]         [dbo].[UserDate]        NULL,
    CONSTRAINT [PK_ProviderHierarchyLevel] PRIMARY KEY CLUSTERED ([ProviderHierarchyLevelID] ASC),
    CONSTRAINT [FK_ProviderHierarchyLevel_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ProviderHierarchyLevel_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_ProviderHierarchyLevel_ProviderHierarchy] FOREIGN KEY ([ProviderHierarchyID]) REFERENCES [dbo].[ProviderHierarchy] ([ProviderHierarchyID])
);

