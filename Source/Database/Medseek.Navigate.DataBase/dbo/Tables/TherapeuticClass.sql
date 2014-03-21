CREATE TABLE [dbo].[TherapeuticClass] (
    [TherapeuticID]        [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [Name]                 [dbo].[SourceName]      NOT NULL,
    [Description]          [dbo].[LongDescription] NULL,
    [SortOrder]            [dbo].[STID]            NULL,
    [CreatedByUserId]      [dbo].[KeyID]           NOT NULL,
    [CreatedDate]          [dbo].[UserDate]        CONSTRAINT [DF_TherapeuticClasses_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]           NULL,
    [LastModifiedDate]     [dbo].[UserDate]        NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_TherapeuticClasses_StatusCode] DEFAULT ('A') NOT NULL,
    CONSTRAINT [PK_TherapeuticClass] PRIMARY KEY CLUSTERED ([TherapeuticID] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_TherapeuticClass]
    ON [dbo].[TherapeuticClass]([Name] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A drug classification system that groups medication by the conditions they address', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the TherapeuticClass table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'TherapeuticID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TherapeuticClass Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for TherapeuticClass table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alternate Sort order for TherapeuticClass table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'SortOrder';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClass', @level2type = N'COLUMN', @level2name = N'StatusCode';

