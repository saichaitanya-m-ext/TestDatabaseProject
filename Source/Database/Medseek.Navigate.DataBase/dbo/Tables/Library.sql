CREATE TABLE [dbo].[Library] (
    [LibraryId]             [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [DocumentTypeId]        [dbo].[KeyID]            NULL,
    [Name]                  [dbo].[ShortDescription] NOT NULL,
    [Description]           [dbo].[LongDescription]  NOT NULL,
    [PhysicalFileName]      [dbo].[LongDescription]  NULL,
    [DocumentNum]           VARCHAR (15)             NULL,
    [DocumentLocation]      [dbo].[ShortDescription] NULL,
    [eDocument]             VARBINARY (MAX)          NULL,
    [DocumentSourceCompany] VARCHAR (100)            NULL,
    [CreatedByUserId]       [dbo].[KeyID]            NOT NULL,
    [CreatedDate]           [dbo].[UserDate]         CONSTRAINT [DF_Library_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]  [dbo].[KeyID]            NULL,
    [LastModifiedDate]      [dbo].[UserDate]         NULL,
    [StatusCode]            [dbo].[StatusCode]       CONSTRAINT [DF_Library_StatusCode] DEFAULT ('A') NOT NULL,
    [MimeType]              VARCHAR (20)             NULL,
    [WebSiteURLLink]        VARCHAR (200)            NULL,
    [IsPEM]                 [dbo].[IsIndicator]      NULL,
    CONSTRAINT [PK_Library] PRIMARY KEY CLUSTERED ([LibraryId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_Library_DocumentType] FOREIGN KEY ([DocumentTypeId]) REFERENCES [dbo].[DocumentType] ([DocumentTypeId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Libary_Name]
    ON [dbo].[Library]([Name] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Library_DocumentTypeId]
    ON [dbo].[Library]([DocumentTypeId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [NIX_Lirary_LibraryId]
    ON [dbo].[Library]([LibraryId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A libray of health related documents or web links', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the Library Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'LibraryId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the DocumentType Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'DocumentTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Library Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for Library table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The file name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'PhysicalFileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The storage location for the hard copy of the document', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'DocumentLocation';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MIME types are used to identify the type of information that a file contains.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'MimeType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Web address for a web url', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Library', @level2type = N'COLUMN', @level2name = N'WebSiteURLLink';

