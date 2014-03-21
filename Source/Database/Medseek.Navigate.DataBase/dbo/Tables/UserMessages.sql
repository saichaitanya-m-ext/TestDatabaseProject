CREATE TABLE [dbo].[UserMessages] (
    [UserMessageId]   INT                 IDENTITY (1, 1) NOT NULL,
    [SubjectText]     VARCHAR (200)       NULL,
    [MessageText]     NVARCHAR (MAX)      NULL,
    [ProviderID]      [dbo].[KeyID]       NOT NULL,
    [CreatedByUserId] [dbo].[KeyID]       NOT NULL,
    [CreatedDate]     DATETIME            CONSTRAINT [DF_UserMessages_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [isDraft]         [dbo].[IsIndicator] NULL,
    [MessageState]    CHAR (1)            NULL,
    [PatientId]       [dbo].[KeyID]       NULL,
    [DeliverOnDate]   DATETIME            CONSTRAINT [DF_UserMessages_DeliverOnDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_UserMessages] PRIMARY KEY CLUSTERED ([UserMessageId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_UserMessages_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_UserMessages_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE NONCLUSTERED INDEX [IX_UserMessages_UserMessageID]
    ON [dbo].[UserMessages]([UserMessageId] ASC, [ProviderID] ASC, [PatientId] ASC, [DeliverOnDate] ASC, [SubjectText] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_UserMessages_MessageState]
    ON [dbo].[UserMessages]([ProviderID] ASC, [MessageState] ASC, [UserMessageId] ASC, [PatientId] ASC, [DeliverOnDate] ASC, [SubjectText] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'List of internal messages sent by users', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the Usermessage Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'UserMessageId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The message subject  text', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'SubjectText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The message body test', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'MessageText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table - Indicates the user that sent the message', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'ProviderID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag indicating that the message is in draft status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'isDraft';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The message state V = viewed, N = Not viewed and A = Archived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'MessageState';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'PatientId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date the message should be delivered - can be a future date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserMessages', @level2type = N'COLUMN', @level2name = N'DeliverOnDate';

