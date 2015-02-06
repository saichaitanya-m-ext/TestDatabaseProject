CREATE TABLE [dbo].[TaskBundleHistory] (
    [TaskBundleId]         [dbo].[KeyID]            NOT NULL,
    [TaskBundleName]       [dbo].[SourceName]       NOT NULL,
    [Description]          [dbo].[ShortDescription] NOT NULL,
    [DefinitionVersion]    VARCHAR (5)              NOT NULL,
    [StatusCode]           [dbo].[StatusCode]       NOT NULL,
    [IsEdit]               [dbo].[IsIndicator]      NULL,
    [ProductionStatus]     VARCHAR (1)              NULL,
    [IsBuildingBlock]      BIT                      NULL,
    [ConflictType]         VARCHAR (1)              NULL,
    [CreatedByUserId]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_TaskBundleHistory_CreatetdDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    [BundlehistoryList]    VARCHAR (4000)           NULL,
    [AdhocFrequencyList]   VARCHAR (4000)           NULL,
    [PEMList]              VARCHAR (4000)           NULL,
    [QuestionnaireList]    VARCHAR (4000)           NULL,
    [CPTList]              VARCHAR (4000)           NULL,
    [ModifiedDiseaseList]  VARCHAR (4000)           NULL,
    [CopyIncludeList]      VARCHAR (4000)           NULL,
    [ParentTaskBundleList] VARCHAR (2000)           NULL,
    CONSTRAINT [PK_TaskBundleHistory] PRIMARY KEY CLUSTERED ([TaskBundleId] ASC, [DefinitionVersion] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

