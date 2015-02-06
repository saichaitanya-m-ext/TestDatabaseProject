CREATE TABLE [dbo].[PopulationDefinitionPatients] (
    [PopulationDefinitionPatientID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PopulationDefinitionID]        [dbo].[KeyID]    NOT NULL,
    [PatientID]                     [dbo].[KeyID]    NOT NULL,
    [StatusCode]                    VARCHAR (1)      CONSTRAINT [DFPopulationDefinitionUsers_StatusCode] DEFAULT ('A') NULL,
    [LeaveInList]                   BIT              NULL,
    [CreatedByUserId]               [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                   [dbo].[UserDate] CONSTRAINT [DF_PopulationDefinitionUsers_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          INT              NULL,
    [LastModifiedDate]              DATETIME         NULL,
    CONSTRAINT [PK_PopulationDefinitionUsers] PRIMARY KEY CLUSTERED ([PopulationDefinitionPatientID] ASC),
    CONSTRAINT [FK_PopulationDefinitionUsers_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PopulationDefinitionUsers_PopulationDefinition] FOREIGN KEY ([PopulationDefinitionID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID])
);


GO
CREATE NONCLUSTERED INDEX [IX_CohortListUsers_StausCode]
    ON [dbo].[PopulationDefinitionPatients]([StatusCode] ASC)
    INCLUDE([PopulationDefinitionID], [PatientID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CohortListUsers_Cohortlistid]
    ON [dbo].[PopulationDefinitionPatients]([PopulationDefinitionID] ASC)
    INCLUDE([PatientID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CohortListUsers_CohortListID_StatusCode]
    ON [dbo].[PopulationDefinitionPatients]([PopulationDefinitionID] ASC, [StatusCode] ASC)
    INCLUDE([PatientID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CohortListUsers_CohortListID,UserId]
    ON [dbo].[PopulationDefinitionPatients]([PopulationDefinitionID] ASC, [PatientID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PopulationDefinitionPatients]
    ON [dbo].[PopulationDefinitionPatients]([PopulationDefinitionID] ASC, [PatientID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

