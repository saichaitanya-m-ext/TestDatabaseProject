CREATE TABLE [dbo].[ProgramCohortList] (
    [ProgramCohortListID]    [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [ProgramID]              [dbo].[KeyID]      NOT NULL,
    [PopulationDefinitionID] [dbo].[KeyID]      NOT NULL,
    [StatusCode]             [dbo].[StatusCode] CONSTRAINT [DF_ProgramCohortList_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]        [dbo].[KeyID]      NOT NULL,
    [CreatedDate]            [dbo].[UserDate]   CONSTRAINT [DF_ProgramCohortList_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]      NULL,
    [LastModifiedDate]       [dbo].[UserDate]   NULL,
    [CohortVersion]          VARCHAR (5)        NULL,
    CONSTRAINT [PK_ProgramCohortList] PRIMARY KEY CLUSTERED ([ProgramCohortListID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_ProgramCohortList_PopulationDefinition] FOREIGN KEY ([PopulationDefinitionID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID]),
    CONSTRAINT [FK_ProgramCohortList_ProgramID] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ProgramCohortList_ProgramCohortListID]
    ON [dbo].[ProgramCohortList]([ProgramID] ASC, [PopulationDefinitionID] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramCohortList', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramCohortList', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramCohortList', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramCohortList', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

