CREATE TABLE [dbo].[CodeSetEthnicity] (
    [EthnicityId]          [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [EthnicityName]        [dbo].[SourceName]      NOT NULL,
    [Description]          [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [CreatedByUserId]      [dbo].[KeyID]           NOT NULL,
    [CreatedDate]          [dbo].[UserDate]        CONSTRAINT [DF_CodeSetEthnicity_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]           NULL,
    [LastModifiedDate]     [dbo].[UserDate]        NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetEthnicity_StatusCode] DEFAULT ('A') NOT NULL,
    CONSTRAINT [PK_Ethnicity] PRIMARY KEY CLUSTERED ([EthnicityId] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_Ethnicity_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Ethnicity.EthnicityName]
    ON [dbo].[CodeSetEthnicity]([EthnicityName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ethnic Background Classification', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the Ethnicity table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'EthnicityId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ethnicity name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'EthnicityName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for Ethnicity table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetEthnicity', @level2type = N'COLUMN', @level2name = N'StatusCode';

