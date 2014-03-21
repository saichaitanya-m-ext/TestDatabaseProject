CREATE TABLE [dbo].[UIDefUserRoles] (
    [UIDefUserRoleId]      [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [UIDefId]              [dbo].[KeyID]       NULL,
    [SecurityRoleId]       [dbo].[KeyID]       NULL,
    [ReadYN]               [dbo].[IsIndicator] NULL,
    [UpdateYN]             [dbo].[IsIndicator] NULL,
    [InsertYN]             [dbo].[IsIndicator] NULL,
    [DeleteYN]             [dbo].[IsIndicator] NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_UIDefUserRoles_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    [ParentUidefId]        [dbo].[KeyID]       NULL,
    CONSTRAINT [PK_UIDefUserRoles] PRIMARY KEY CLUSTERED ([UIDefUserRoleId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_UIDefUserRoles_SecurityRoles] FOREIGN KEY ([SecurityRoleId]) REFERENCES [dbo].[SecurityRole] ([SecurityRoleId]),
    CONSTRAINT [FK_UIDefUserRoles_UIDef] FOREIGN KEY ([UIDefId]) REFERENCES [dbo].[UIDef] ([UIDefId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cross reference tabe associating Pages and sub-pages to roles and users', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the UIDefUserRoles Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'UIDefUserRoleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Uidef table Links pages to roles', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'UIDefId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the SecurityRole table links role to pages', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'SecurityRoleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Read Rights', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'ReadYN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Update Rights', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'UpdateYN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Insert Rights', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'InsertYN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Delete Rights', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'DeleteYN';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDefUserRoles', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

