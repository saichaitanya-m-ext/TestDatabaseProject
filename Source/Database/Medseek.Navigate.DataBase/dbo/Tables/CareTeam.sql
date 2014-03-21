CREATE TABLE [dbo].[CareTeam] (
    [CareTeamId]           [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [CareTeamName]         [dbo].[SourceName]       NOT NULL,
    [Description]          [dbo].[ShortDescription] NOT NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_CareTeam_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_Table_1_CreatetdDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    [DiseaseId]            [dbo].[KeyID]            NULL,
    CONSTRAINT [PK_CareTeam] PRIMARY KEY CLUSTERED ([CareTeamId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_CareTeam_Disease] FOREIGN KEY ([DiseaseId]) REFERENCES [dbo].[Disease] ([DiseaseId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CareTeam_CareTeamName]
    ON [dbo].[CareTeam]([CareTeamName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Team of Health care professionals that treat a patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the CareTeam table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'CareTeamId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the Care team', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'CareTeamName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for CareTeam table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Disease Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeam', @level2type = N'COLUMN', @level2name = N'DiseaseId';

