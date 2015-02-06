CREATE TABLE [dbo].[SecurityRole] (
    [SecurityRoleId]  [dbo].[KeyID]               IDENTITY (1, 1) NOT NULL,
    [PortalId]        [dbo].[KeyID]               NULL,
    [RoleName]        NVARCHAR (256)              NOT NULL,
    [RoleDescription] [dbo].[VeryLongDescription] NOT NULL,
    [Status]          [dbo].[StatusCode]          NULL,
    CONSTRAINT [PK_SecurityRole] PRIMARY KEY CLUSTERED ([SecurityRoleId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_SecurityRole_Portals] FOREIGN KEY ([PortalId]) REFERENCES [dbo].[Portals] ([PortalId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_SecurityRole_RoleName]
    ON [dbo].[SecurityRole]([RoleName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A Application security role that enables a specific functionality right ot rights for a user', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SecurityRole';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the SecurityRole table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SecurityRole', @level2type = N'COLUMN', @level2name = N'SecurityRoleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Portal Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SecurityRole', @level2type = N'COLUMN', @level2name = N'PortalId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Security Role name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SecurityRole', @level2type = N'COLUMN', @level2name = N'RoleName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The security role description', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SecurityRole', @level2type = N'COLUMN', @level2name = N'RoleDescription';

