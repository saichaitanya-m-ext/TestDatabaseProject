CREATE TABLE [dbo].[UserMessageAttachments] (
    [UserMessageAttachmentId] INT           IDENTITY (1, 1) NOT NULL,
    [UserMessageId]           [dbo].[KeyID] NOT NULL,
    [AttachmentId]            [dbo].[KeyID] NULL,
    [CreatedByUserId]         [dbo].[KeyID] NOT NULL,
    [CreatedDate]             DATETIME      CONSTRAINT [DF_UserMessageAttachments_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LibraryId]               INT           NULL,
    CONSTRAINT [PK_UserMessageAttachments] PRIMARY KEY CLUSTERED ([UserMessageAttachmentId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_UserMessageAttachments_Attachments] FOREIGN KEY ([AttachmentId]) REFERENCES [dbo].[Attachments] ([AttachmentId]),
    CONSTRAINT [FK_UserMessageAttachments_Library] FOREIGN KEY ([LibraryId]) REFERENCES [dbo].[Library] ([LibraryId]),
    CONSTRAINT [FK_UserMessageAttachments_UserMessages] FOREIGN KEY ([UserMessageId]) REFERENCES [dbo].[UserMessages] ([UserMessageId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Attachments for internal messages', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessageAttachments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Usermessage Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessageAttachments', @level2type = N'COLUMN', @level2name = N'UserMessageId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Attachments table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessageAttachments', @level2type = N'COLUMN', @level2name = N'AttachmentId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessageAttachments', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessageAttachments', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessageAttachments', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessageAttachments', @level2type = N'COLUMN', @level2name = N'CreatedDate';

