CREATE TABLE [dbo].[CohortListHistory] (
    [PopulationDefinitionID]           INT                     NOT NULL,
    [DefinitionVersion]                VARCHAR (5)             NOT NULL,
    [CohortListName]                   VARCHAR (100)           NOT NULL,
    [CohortListDescription]            [dbo].[LongDescription] NULL,
    [LastDateListGenerated]            DATETIME                NOT NULL,
    [StatusCode]                       VARCHAR (1)             CONSTRAINT [DF_CohortListHistory_StatusCode] DEFAULT ('A') NOT NULL,
    [RefreshPatientListDaily]          BIT                     NOT NULL,
    [NonModifiable]                    BIT                     NULL,
    [Private]                          BIT                     NULL,
    [ProductionStatus]                 VARCHAR (1)             NULL,
    [DefinitionType]                   VARCHAR (20)            CONSTRAINT [DF_CohortListHistory_DefinitionType] DEFAULT ('Population') NULL,
    [StandardId]                       [dbo].[KeyID]           NULL,
    [StandardOrganizationId]           [dbo].[KeyID]           NULL,
    [NumeratorType]                    VARCHAR (1)             NULL,
    [CohortModificationList]           VARCHAR (3000)          NULL,
    [CohortCriteriaModificationList]   VARCHAR (3000)          NULL,
    [CohortDependencyModificationList] VARCHAR (3000)          NULL,
    [CreatedByUserId]                  INT                     NOT NULL,
    [CreatedDate]                      DATETIME                CONSTRAINT [DF_CohortListHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CohortListHistory_1] PRIMARY KEY CLUSTERED ([PopulationDefinitionID] ASC, [DefinitionVersion] ASC),
    CONSTRAINT [FK_CohortListHistory_PopulationDefinition] FOREIGN KEY ([PopulationDefinitionID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';

