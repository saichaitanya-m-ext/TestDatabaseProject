CREATE TABLE [dbo].[Communication] (
    [CommunicationId]         [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [CommunicationTemplateId] [dbo].[KeyID]       NOT NULL,
    [SenderEmailAddress]      VARCHAR (256)       NULL,
    [IsDraft]                 [dbo].[IsIndicator] NULL,
    [SubmittedDate]           [dbo].[UserDate]    NULL,
    [ApprovalState]           VARCHAR (30)        NULL,
    [ApprovalDate]            [dbo].[UserDate]    NULL,
    [CreatedByUserId]         [dbo].[KeyID]       NOT NULL,
    [CreatedDate]             [dbo].[UserDate]    CONSTRAINT [DF_Communication_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    [dbo].[KeyID]       NULL,
    [LastModifiedDate]        [dbo].[UserDate]    NULL,
    [StatusCode]              [dbo].[StatusCode]  CONSTRAINT [DF_Communication_StatusCode] DEFAULT ('A') NOT NULL,
    [CommunicationSentDate]   DATETIME            NULL,
    [PrintDate]               DATETIME            NULL,
    [CommunicationTypeId]     [dbo].[KeyID]       NULL,
    CONSTRAINT [PK_Communication] PRIMARY KEY CLUSTERED ([CommunicationId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_Communication_CommunicationTemplate] FOREIGN KEY ([CommunicationTemplateId]) REFERENCES [dbo].[CommunicationTemplate] ([CommunicationTemplateId]),
    CONSTRAINT [FK_Communication_CommunicationType] FOREIGN KEY ([CommunicationTypeId]) REFERENCES [dbo].[CommunicationType] ([CommunicationTypeId])
);


GO
CREATE NONCLUSTERED INDEX [Ix_Communication_CommunicationTypeId]
    ON [dbo].[Communication]([CommunicationTypeId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A mass communication instance', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the Communication Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'CommunicationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CommunicationTemplate Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'CommunicationTemplateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Email Address for the sender', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'SenderEmailAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag to indicate that the communication is still in draft state', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'IsDraft';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Submit date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'SubmittedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Approved state', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'ApprovalState';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Approved Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'ApprovalDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the communication was last sent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'CommunicationSentDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the communication was last printed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Communication', @level2type = N'COLUMN', @level2name = N'PrintDate';

