CREATE TABLE [dbo].[CommunicationTemplate] (
    [CommunicationTemplateId]       [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [TemplateName]                  [dbo].[ShortDescription] NOT NULL,
    [Description]                   [dbo].[LongDescription]  NULL,
    [CommunicationTypeId]           [dbo].[KeyID]            NOT NULL,
    [SubjectText]                   VARCHAR (200)            NULL,
    [SenderEmailAddress]            VARCHAR (256)            NULL,
    [CreatedByUserId]               [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                   [dbo].[UserDate]         CONSTRAINT [DF_CommunicationTemplate_CreatedDate_1] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          [dbo].[KeyID]            NULL,
    [LastModifiedDate]              [dbo].[UserDate]         NULL,
    [StatusCode]                    [dbo].[StatusCode]       CONSTRAINT [DF_CommunicationTemplate_StatusCode] DEFAULT ('A') NOT NULL,
    [IsDraft]                       [dbo].[IsIndicator]      NULL,
    [NotifyCommunicationTemplateId] [dbo].[KeyID]            NULL,
    [CommunicationText]             NVARCHAR (MAX)           NOT NULL,
    [SubmittedDate]                 [dbo].[UserDate]         NULL,
    [ApprovalState]                 VARCHAR (30)             NULL,
    CONSTRAINT [PK_CommunicationTemplate] PRIMARY KEY CLUSTERED ([CommunicationTemplateId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_CommunicationTemplate_CommunicationType] FOREIGN KEY ([CommunicationTypeId]) REFERENCES [dbo].[CommunicationType] ([CommunicationTypeId]),
    CONSTRAINT [FK_CommunicationTemplate_NotifyCommunicationTemplate] FOREIGN KEY ([NotifyCommunicationTemplateId]) REFERENCES [dbo].[CommunicationTemplate] ([CommunicationTemplateId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CommunicationTemplate_TemplateName]
    ON [dbo].[CommunicationTemplate]([TemplateName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CommunicationTemplate_CommunicationTemplateID]
    ON [dbo].[CommunicationTemplate]([CommunicationTemplateId] ASC)
    INCLUDE([TemplateName]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The template for a mass communication', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the CommunicationTemplate Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'CommunicationTemplateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the Communications Template', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'TemplateName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for CommunicationTemplate table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Communication Type table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'CommunicationTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Subject text line for the Communication Template', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'SubjectText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Email address for the person sending the communications', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'SenderEmailAddress';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag indicating that the Communication Template is still a draft.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'IsDraft';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to The Communications Template table (recursive)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'NotifyCommunicationTemplateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The text message body', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'CommunicationText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the template was submitted', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'SubmittedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Approval State for the template (ready or Not Ready)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplate', @level2type = N'COLUMN', @level2name = N'ApprovalState';

