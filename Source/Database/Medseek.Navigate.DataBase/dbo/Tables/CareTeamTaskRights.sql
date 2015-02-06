CREATE TABLE [dbo].[CareTeamTaskRights] (
    [CareTeamTaskRightsId] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [ProviderID]           [dbo].[KeyID]      NULL,
    [TaskTypeId]           [dbo].[KeyID]      NULL,
    [CareTeamId]           [dbo].[KeyID]      NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CareTeamTaskRights_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_CareTeamTaskRights_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_CareTeamTaskRights] PRIMARY KEY CLUSTERED ([CareTeamTaskRightsId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CareTeamTaskRights]
    ON [dbo].[CareTeamTaskRights]([ProviderID] ASC, [TaskTypeId] ASC, [CareTeamId] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CareTeamTaskRights_UserID]
    ON [dbo].[CareTeamTaskRights]([ProviderID] ASC, [TaskTypeId] ASC, [CareTeamId] ASC, [CareTeamTaskRightsId] ASC)
    INCLUDE([StatusCode]) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The specific set of task rights associated with a specific Care team Member', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the CareTeamTaskRights table - identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'CareTeamTaskRightsId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the users table defines the care provider that was granted the right to perform a specific task type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'ProviderID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Tasktype table defines the Task type the care provide can do', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'TaskTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Careteam Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'CareTeamId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CareTeamTaskRights', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

