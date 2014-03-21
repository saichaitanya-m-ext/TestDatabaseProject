CREATE TABLE [dbo].[PatientDocument] (
    [PatientDocumentId]    [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PatientID]            [dbo].[KeyID]            NOT NULL,
    [DocumentCategoryId]   [dbo].[KeyID]            NULL,
    [Name]                 [dbo].[ShortDescription] NOT NULL,
    [Body]                 VARBINARY (MAX)          NULL,
    [FileSizeinBytes]      [dbo].[KeyID]            NULL,
    [DocumentTypeId]       [dbo].[KeyID]            NULL,
    [StatusCode]           VARCHAR (1)              CONSTRAINT [DF_PatientDocument_StatusCode] DEFAULT ('A') NOT NULL,
    [MimeType]             VARCHAR (20)             NULL,
    [CreatedByUserId]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_PatientDocument_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                      NULL,
    [LastModifiedDate]     DATETIME                 NULL,
    CONSTRAINT [PK_PatientDocument] PRIMARY KEY CLUSTERED ([PatientDocumentId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientDocument_DocumentCategory] FOREIGN KEY ([DocumentCategoryId]) REFERENCES [dbo].[DocumentCategory] ([DocumentCategoryId]),
    CONSTRAINT [FK_PatientDocument_DocumentType] FOREIGN KEY ([DocumentTypeId]) REFERENCES [dbo].[DocumentType] ([DocumentTypeId]),
    CONSTRAINT [FK_PatientDocument_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'List of documents uploaded for a specific patient (Patient photos, medical records, x-rays, reports)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserDocument table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'PatientDocumentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table - Identifies the Patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'PatientID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the DocumentCategory table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'DocumentCategoryId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'UserDocument Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The document contents or the image in digital format', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'Body';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'File size in bytes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'FileSizeinBytes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the DocumentType table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'DocumentTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MIME types are used to identify the type of information that a file contains.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'MimeType';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDocument', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

