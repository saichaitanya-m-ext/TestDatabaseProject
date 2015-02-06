CREATE TABLE [dbo].[CareTeamMembers] (
    [CareTeamId]           [dbo].[KeyID]       NOT NULL,
    [ProviderID]           [dbo].[KeyID]       NOT NULL,
    [IsCareTeamManager]    [dbo].[IsIndicator] NULL,
    [StatusCode]           [dbo].[StatusCode]  CONSTRAINT [DF_CareTeamMembers_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_CareTeamMembers_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_CareTeamMembers] PRIMARY KEY CLUSTERED ([CareTeamId] ASC, [ProviderID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_CareTeamMembers_CareTeam] FOREIGN KEY ([CareTeamId]) REFERENCES [dbo].[CareTeam] ([CareTeamId]),
    CONSTRAINT [FK_CareTeamMembers_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE NONCLUSTERED INDEX [IX_CareTeamMembers_UserID]
    ON [dbo].[CareTeamMembers]([CareTeamId] ASC, [ProviderID] ASC)
    INCLUDE([IsCareTeamManager], [StatusCode]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Member of a Care Team', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Careteam Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'CareTeamId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Part of the Primary Key for the CareTemMembers table and Foreign key to the users table to define the care team member', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'ProviderID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag to indicate which team members are care team manager and used to define who can assign task rights for the care team', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'IsCareTeamManager';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamMembers', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

