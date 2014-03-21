CREATE TABLE [dbo].[aspnet_Paths] (
    [ApplicationId] UNIQUEIDENTIFIER NOT NULL,
    [PathId]        UNIQUEIDENTIFIER CONSTRAINT [DF__aspnet_Pa__PathI__47DBAE45] DEFAULT (newid()) NOT NULL,
    [Path]          NVARCHAR (256)   NOT NULL,
    [LoweredPath]   NVARCHAR (256)   NOT NULL,
    CONSTRAINT [PK__aspnet_Paths__45F365D3] PRIMARY KEY NONCLUSTERED ([PathId] ASC) WITH (FILLFACTOR = 25) ON [FG_Transactional_NCX],
    CONSTRAINT [FK__aspnet_Pa__Appli__46E78A0C] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
);


GO
CREATE UNIQUE CLUSTERED INDEX [aspnet_Paths_index]
    ON [dbo].[aspnet_Paths]([ApplicationId] ASC, [LoweredPath] ASC) WITH (FILLFACTOR = 25);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MS .NET 2.9 Security Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Paths';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Application ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Paths', @level2type = N'COLUMN', @level2name = N'ApplicationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Path ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Paths', @level2type = N'COLUMN', @level2name = N'PathId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Path name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Paths', @level2type = N'COLUMN', @level2name = N'Path';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Path name (lowercase)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Paths', @level2type = N'COLUMN', @level2name = N'LoweredPath';

