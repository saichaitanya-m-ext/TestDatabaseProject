CREATE TYPE [dbo].[TherapeuticClass] AS TABLE (
    [TherapeuticID] [dbo].[KeyID]           NULL,
    [Name]          [dbo].[SourceName]      NULL,
    [Description]   [dbo].[LongDescription] NULL,
    [SortOrder]     [dbo].[STID]            NULL,
    [StatusCode]    [dbo].[StatusCode]      NOT NULL);

