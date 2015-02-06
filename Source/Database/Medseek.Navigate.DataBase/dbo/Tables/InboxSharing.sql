CREATE TABLE [dbo].[InboxSharing] (
    [InboxSharingId]       [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [UserID]               [dbo].[KeyID]      NOT NULL,
    [ShareWithUserID]      [dbo].[KeyID]      NOT NULL,
    [StartSharingDate]     DATETIME           NOT NULL,
    [EndSharingDate]       DATETIME           NULL,
    [Remarks]              VARCHAR (500)      NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_InboxSharing_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_InboxSharing_StatusCode] DEFAULT ('A') NOT NULL,
    CONSTRAINT [PK_InboxSharing] PRIMARY KEY CLUSTERED ([InboxSharingId] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table stores the details for one user to share their inbox with another uer for a period of time.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the InboxSharing table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'InboxSharingId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The user that is sharing their inbox with another user', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'UserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The user that has limited right to look at the inbox', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'ShareWithUserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date the sharing starts', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'StartSharingDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date the inbox sharing ends', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'EndSharingDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Remarks or comments about why the sharing was done', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'Remarks';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InboxSharing', @level2type = N'COLUMN', @level2name = N'StatusCode';

