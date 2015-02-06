CREATE TABLE [dbo].[Attachments] (
    [AttachmentId]        INT             IDENTITY (1, 1) NOT NULL,
    [AttachmentName]      VARCHAR (100)   NOT NULL,
    [AttachmentExtension] VARCHAR (5)     NOT NULL,
    [AttachmentBody]      VARBINARY (MAX) NULL,
    [FileType]            VARCHAR (100)   NULL,
    [MimeType]            VARCHAR (100)   NULL,
    [FileSizeInBytes]     INT             NULL,
    [CreatedByUserId]     INT             NOT NULL,
    [CreatedDate]         DATETIME        CONSTRAINT [DF_Attachments_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Attachments] PRIMARY KEY CLUSTERED ([AttachmentId] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Attachments for internal messages', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the Attachement Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments', @level2type = N'COLUMN', @level2name = N'AttachmentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the Attachment', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments', @level2type = N'COLUMN', @level2name = N'AttachmentName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ext of the Attachment', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments', @level2type = N'COLUMN', @level2name = N'AttachmentExtension';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Body text', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments', @level2type = N'COLUMN', @level2name = N'AttachmentBody';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'File Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments', @level2type = N'COLUMN', @level2name = N'FileType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MIME types are used to identify the type of information that a file contains.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments', @level2type = N'COLUMN', @level2name = N'MimeType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'File size in bytes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments', @level2type = N'COLUMN', @level2name = N'FileSizeInBytes';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Attachments', @level2type = N'COLUMN', @level2name = N'CreatedDate';

