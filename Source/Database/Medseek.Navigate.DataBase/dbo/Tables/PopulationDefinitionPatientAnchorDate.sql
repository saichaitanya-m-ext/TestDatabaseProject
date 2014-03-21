CREATE TABLE [dbo].[PopulationDefinitionPatientAnchorDate] (
    [PopulationDefinitionPatientID] [dbo].[KeyID]    NOT NULL,
    [DateKey]                       [dbo].[KeyID]    NOT NULL,
    [StatusCode]                    VARCHAR (1)      CONSTRAINT [DFPopulationDefinitionPatientAnchorDate_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId]               [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                   [dbo].[UserDate] CONSTRAINT [DF_PopulationDefinitionPatientAnchorDate_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [OutPutAnchorDate]              DATE             NULL,
    [ClaimAmt]                      MONEY            NULL,
    CONSTRAINT [PK_PopulationDefinitionPatientAnchorDate] PRIMARY KEY CLUSTERED ([PopulationDefinitionPatientID] ASC, [DateKey] ASC),
    CONSTRAINT [FK_PopulationDefinitionPatientAnchorDate_PopulationDefinitionPatient] FOREIGN KEY ([PopulationDefinitionPatientID]) REFERENCES [dbo].[PopulationDefinitionPatients] ([PopulationDefinitionPatientID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PopulationDefinitionPatientAnchorDate_OutPutAnchorDate]
    ON [dbo].[PopulationDefinitionPatientAnchorDate]([OutPutAnchorDate] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

