CREATE TABLE [dbo].[DocumentProgram] (
    [LibraryID]            [dbo].[KeyID]      NOT NULL,
    [ProgramID]            [dbo].[KeyID]      NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_DocumentProgram_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_DocumentProgram_StatusCode] DEFAULT ('A') NOT NULL,
    CONSTRAINT [PK_DocumentProgram] PRIMARY KEY CLUSTERED ([LibraryID] ASC, [ProgramID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_DocumentProgram_Library] FOREIGN KEY ([LibraryID]) REFERENCES [dbo].[Library] ([LibraryId]),
    CONSTRAINT [FK_DocumentProgram_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Documents in the library associated with a specific Program', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Library Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram', @level2type = N'COLUMN', @level2name = N'LibraryID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Partial Primary Key to the DocumentProgram table and Foreign key to the Program Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram', @level2type = N'COLUMN', @level2name = N'ProgramID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DocumentProgram', @level2type = N'COLUMN', @level2name = N'StatusCode';

