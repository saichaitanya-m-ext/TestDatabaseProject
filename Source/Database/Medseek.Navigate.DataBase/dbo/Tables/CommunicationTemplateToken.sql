CREATE TABLE [dbo].[CommunicationTemplateToken] (
    [CommunicationTemplateTokenId] [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [TokenString]                  [dbo].[SourceName]      NOT NULL,
    [TokenDescription]             [dbo].[LongDescription] NULL,
    [SQLString]                    VARCHAR (2000)          NULL,
    [TagNameInTemplate]            VARCHAR (20)            NULL,
    [CreatedByUserId]              [dbo].[KeyID]           NOT NULL,
    [CreatedDate]                  [dbo].[UserDate]        CONSTRAINT [DF_CommunicationTemplateToken_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]         [dbo].[KeyID]           NULL,
    [LastModifiedDate]             [dbo].[UserDate]        NULL,
    [StatusCode]                   [dbo].[StatusCode]      CONSTRAINT [DF_CommunicationTemplateToken_StatusCode] DEFAULT ('A') NOT NULL,
    CONSTRAINT [PK_CommunicationTemplateToken] PRIMARY KEY CLUSTERED ([CommunicationTemplateTokenId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CommunicationTemplateToken.TokenString]
    ON [dbo].[CommunicationTemplateToken]([TokenString] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A token is a piece of text with a template that is replaced by a specific db attributes value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the CommunicationTemplateToken table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'CommunicationTemplateTokenId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The token string that is replaced before the message is sent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'TokenString';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token description, explains the token and how it is resolved', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'TokenDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A SQL string or SP name that will retrieve the data for the database to replace the token.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'SQLString';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The complete token string', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'TagNameInTemplate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationTemplateToken', @level2type = N'COLUMN', @level2name = N'StatusCode';

