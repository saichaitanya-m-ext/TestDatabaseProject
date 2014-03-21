CREATE TABLE [dbo].[CommunicationTemplateAttachments] (
    [LibraryId]               [dbo].[KeyID]    NOT NULL,
    [CommunicationTemplateId] [dbo].[KeyID]    NOT NULL,
    [CreatedByUserId]         [dbo].[KeyID]    NOT NULL,
    [CreatedDate]             [dbo].[UserDate] CONSTRAINT [DF_CommunicationTemplateAttachments_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CommunicationTemplateAttachments] PRIMARY KEY CLUSTERED ([LibraryId] ASC, [CommunicationTemplateId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_CommunicationTemplateAttachments_CommunicationTemplate] FOREIGN KEY ([CommunicationTemplateId]) REFERENCES [dbo].[CommunicationTemplate] ([CommunicationTemplateId]),
    CONSTRAINT [FK_CommunicationTemplateAttachments_Library] FOREIGN KEY ([LibraryId]) REFERENCES [dbo].[Library] ([LibraryId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A attachment for a mass communication', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateAttachments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Library Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateAttachments', @level2type = N'COLUMN', @level2name = N'LibraryId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CommunicationTemplate table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateAttachments', @level2type = N'COLUMN', @level2name = N'CommunicationTemplateId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateAttachments', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateAttachments', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateAttachments', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateAttachments', @level2type = N'COLUMN', @level2name = N'CreatedDate';

