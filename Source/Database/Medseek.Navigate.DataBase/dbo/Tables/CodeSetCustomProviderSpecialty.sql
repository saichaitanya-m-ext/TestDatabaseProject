CREATE TABLE [dbo].[CodeSetCustomProviderSpecialty] (
    [CustomProviderSpecialtyCodeID] INT                     IDENTITY (1, 1) NOT NULL,
    [SpecialtyName]                 VARCHAR (50)            NOT NULL,
    [CreatedByUserId]               [dbo].[KeyID]           NULL,
    [CreatedDate]                   DATETIME                CONSTRAINT [DF_CodeSetCustomProviderSpecialty_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          INT                     NULL,
    [LastModifiedDate]              DATETIME                NULL,
    [StatusCode]                    CHAR (1)                CONSTRAINT [DF_CodeSetCustomProviderSpecialty_StatusCode] DEFAULT ('A') NOT NULL,
    [Description]                   [dbo].[LongDescription] NULL,
    [SpecialtyCode]                 VARCHAR (10)            NULL,
    [DataSourceID]                  [dbo].[KeyID]           NULL,
    [DataSourceFileID]              [dbo].[KeyID]           NULL,
    CONSTRAINT [PK_CodeSetCustomProviderSpecialty] PRIMARY KEY CLUSTERED ([CustomProviderSpecialtyCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetCustomProviderSpecialty_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetCustomProviderSpecialty_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_CodeSetCustomProviderSpecialty_LastProvider] FOREIGN KEY ([LastModifiedByUserId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_CodeSetCustomProviderSpecialty_Provider] FOREIGN KEY ([CreatedByUserId]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not used in the application', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Table not used in the application', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty', @level2type = N'COLUMN', @level2name = N'CustomProviderSpecialtyCodeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Table not used in the application', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty', @level2type = N'COLUMN', @level2name = N'SpecialtyName';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCustomProviderSpecialty', @level2type = N'COLUMN', @level2name = N'StatusCode';

