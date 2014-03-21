CREATE TABLE [dbo].[Portals] (
    [PortalId]          [dbo].[KeyID]               IDENTITY (1, 1) NOT NULL,
    [PortalName]        [dbo].[SourceName]          NOT NULL,
    [PortalDescription] [dbo].[VeryLongDescription] NULL,
    CONSTRAINT [PK_Portals] PRIMARY KEY CLUSTERED ([PortalId] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This pable is for future use when CCM manages more than on Web site', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Portals';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the Portal Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Portals', @level2type = N'COLUMN', @level2name = N'PortalId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the Portal -', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Portals', @level2type = N'COLUMN', @level2name = N'PortalName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Portal Description', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Portals', @level2type = N'COLUMN', @level2name = N'PortalDescription';

