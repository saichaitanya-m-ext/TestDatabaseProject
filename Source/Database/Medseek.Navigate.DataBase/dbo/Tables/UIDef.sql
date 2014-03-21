CREATE TABLE [dbo].[UIDef] (
    [UIDefId]              [dbo].[KeyID]               IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PortalId]             [dbo].[KeyID]               NULL,
    [PageURL]              [dbo].[LongDescription]     NULL,
    [PageObject]           [dbo].[LongDescription]     NULL,
    [PageDescription]      [dbo].[VeryLongDescription] NULL,
    [MenuItemName]         [dbo].[ShortDescription]    NULL,
    [isDataAdminPage]      [dbo].[IsIndicator]         NULL,
    [MenuItemOrder]        TINYINT                     NULL,
    [PageOrder]            TINYINT                     NULL,
    [CreatedByUserId]      [dbo].[KeyID]               NULL,
    [CreatedDate]          [dbo].[UserDate]            CONSTRAINT [DF_UIDef_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModifiedByUserId] [dbo].[KeyID]               NULL,
    [LastModifiedDate]     [dbo].[UserDate]            NULL,
    [PageURLNew]           [dbo].[LongDescription]     NULL,
    CONSTRAINT [PK_UIDef] PRIMARY KEY CLUSTERED ([UIDefId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_UIDef_Portals] FOREIGN KEY ([PortalId]) REFERENCES [dbo].[Portals] ([PortalId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A list of pages and sub-pages within the application used to associated functionality to user rights', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the UIDef table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'UIDefId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Portals table Identifies the Portal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'PortalId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL to the source code page', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'PageURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Object on the page', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'PageObject';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Free Form Page Description', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'PageDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Menu Item Name as it appears on the menu', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'MenuItemName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag to indicate if the page is a data admin page', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'isDataAdminPage';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UIDef', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

