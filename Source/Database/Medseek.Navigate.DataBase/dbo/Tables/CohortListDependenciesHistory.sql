CREATE TABLE [dbo].[CohortListDependenciesHistory] (
    [CohortDependencyId]     [dbo].[KeyID]       NOT NULL,
    [DefinitionVersion]      VARCHAR (5)         NOT NULL,
    [PopulationDefinitionID] [dbo].[KeyID]       NOT NULL,
    [IncludedCohortListId]   [dbo].[KeyID]       NOT NULL,
    [Type]                   VARCHAR (1)         NULL,
    [IsDraft]                [dbo].[IsIndicator] NULL,
    [CreatedByUserId]        [dbo].[KeyID]       NOT NULL,
    [CreatedDate]            [dbo].[UserDate]    CONSTRAINT [DF_CohortListDependenciesHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]       NULL,
    [LastModifiedDate]       [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_CohortListDependenciesHistory] PRIMARY KEY CLUSTERED ([CohortDependencyId] ASC, [DefinitionVersion] ASC, [PopulationDefinitionID] ASC, [IncludedCohortListId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_CohortListDependenciesHistory_PopulationDefinition] FOREIGN KEY ([PopulationDefinitionID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListDependenciesHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListDependenciesHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListDependenciesHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListDependenciesHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

