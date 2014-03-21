CREATE TABLE [dbo].[CohortListCriteriaHistory] (
    [CohortCriteriaID]                  INT           NOT NULL,
    [DefinitionVersion]                 VARCHAR (5)   NOT NULL,
    [PopulationDefinitionID]            INT           NOT NULL,
    [PopulationDefinitionCriteriaSQL]   VARCHAR (MAX) NULL,
    [CohortCriteriaText]                VARCHAR (MAX) NULL,
    [PopulationDefPanelConfigurationID] [dbo].[KeyID] NULL,
    [IsBuildDraft]                      BIT           NULL,
    [CreatedByUserId]                   INT           NOT NULL,
    [CreatedDate]                       DATETIME      CONSTRAINT [DF_CohortListCriteriaHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]              INT           NULL,
    [LastModifiedDate]                  DATETIME      NULL,
    CONSTRAINT [PK_CohortListCriteriaHistory] PRIMARY KEY CLUSTERED ([CohortCriteriaID] ASC, [DefinitionVersion] ASC, [PopulationDefinitionID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_CohortListCriteriaHistory_PopulationDefinition] FOREIGN KEY ([PopulationDefinitionID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID]),
    CONSTRAINT [FK_CohortListCriteriaHistory_PopulationDefPanelConfiguration] FOREIGN KEY ([PopulationDefPanelConfigurationID]) REFERENCES [dbo].[PopulationDefPanelConfiguration] ([PopulationDefPanelConfigurationID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

