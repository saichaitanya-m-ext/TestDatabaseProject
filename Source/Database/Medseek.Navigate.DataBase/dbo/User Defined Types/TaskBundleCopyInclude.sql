CREATE TYPE [dbo].[TaskBundleCopyInclude] AS TABLE (
    [TaskBundleID]    [dbo].[KeyID]      NULL,
    [FrequencyNumber] [dbo].[KeyID]      NULL,
    [Frequency]       VARCHAR (1)        NULL,
    [CopyInclude]     [dbo].[StatusCode] NULL,
    [Id1]             [dbo].[KeyID]      NULL,
    [Id2]             VARCHAR (1)        NULL,
    [Id3]             [dbo].[KeyID]      NULL);

