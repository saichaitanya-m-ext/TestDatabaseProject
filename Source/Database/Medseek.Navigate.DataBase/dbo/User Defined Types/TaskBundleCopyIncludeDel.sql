CREATE TYPE [dbo].[TaskBundleCopyIncludeDel] AS TABLE (
    [ReferenceTaskBundleID] [dbo].[KeyID] NULL,
    [TaskType]              VARCHAR (1)   NULL,
    [TaskTypeID]            [dbo].[KeyID] NULL);

