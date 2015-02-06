CREATE TABLE [dbo].[CohortListCriteriaAudit] (
    [CohortListCriteriaAuditID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PopulationDefinitionID]    [dbo].[KeyID]    NULL,
    [CohortCriteriaSQL]         VARCHAR (MAX)    NULL,
    [CohortCriteriaText]        VARCHAR (MAX)    NULL,
    [Version]                   DECIMAL (18, 1)  CONSTRAINT [DF_CohortListCriteriaAudit_Version] DEFAULT ((0.1)) NULL,
    [CreatedByUserId]           [dbo].[KeyID]    NOT NULL,
    [CreatedDate]               [dbo].[UserDate] CONSTRAINT [DF_CohortListCriteriaAudit_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]      [dbo].[KeyID]    NULL,
    [LastModifiedDate]          [dbo].[UserDate] NULL,
    CONSTRAINT [PK_CohortListCriteriaAudit] PRIMARY KEY CLUSTERED ([CohortListCriteriaAuditID] ASC),
    CONSTRAINT [FK_CohortListCriteriaAudit_PopulationDefinition] FOREIGN KEY ([PopulationDefinitionID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaAudit', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaAudit', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaAudit', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaAudit', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

