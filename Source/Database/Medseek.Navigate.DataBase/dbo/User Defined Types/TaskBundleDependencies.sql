CREATE TYPE [dbo].[TaskBundleDependencies] AS TABLE (
    [TaskBundleID]          [dbo].[KeyID]       NULL,
    [FrequencyNumber]       [dbo].[KeyID]       NULL,
    [Frequency]             VARCHAR (1)         NULL,
    [CopyInclude]           [dbo].[StatusCode]  NULL,
    [TaskType]              VARCHAR (1)         NULL,
    [TypeID]                [dbo].[KeyID]       NULL,
    [TasktypeGeneralizedID] [dbo].[KeyID]       NULL,
    [IsConflict]            [dbo].[IsIndicator] NULL);

