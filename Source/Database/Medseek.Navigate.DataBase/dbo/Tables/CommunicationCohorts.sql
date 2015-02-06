CREATE TABLE [dbo].[CommunicationCohorts] (
    [CommunicationCohortId]  [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [CommunicationId]        [dbo].[KeyID]       NOT NULL,
    [PopulationDefinitionID] [dbo].[KeyID]       NOT NULL,
    [UserId]                 [dbo].[KeyID]       NOT NULL,
    [IsExcludedByPreference] [dbo].[IsIndicator] NOT NULL,
    [CreatedByUserId]        [dbo].[KeyID]       NOT NULL,
    [CreatedDate]            [dbo].[UserDate]    CONSTRAINT [DF_CommunicationCohorts_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CommunicationCohorts_1] PRIMARY KEY CLUSTERED ([CommunicationCohortId] ASC),
    CONSTRAINT [FK_CommunicationCohorts_Communication] FOREIGN KEY ([CommunicationId]) REFERENCES [dbo].[Communication] ([CommunicationId])
);


GO
CREATE NONCLUSTERED INDEX [IX_CommunicationCohorts_CommunicationId]
    ON [dbo].[CommunicationCohorts]([CommunicationId] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CommunicationCohorts_CommunicationId_UserID]
    ON [dbo].[CommunicationCohorts]([CommunicationId] ASC, [UserId] ASC, [PopulationDefinitionID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Patients that wil receive a mass communication', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationCohorts';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the CommunicationCohorts table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationCohorts', @level2type = N'COLUMN', @level2name = N'CommunicationCohortId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Communications table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationCohorts', @level2type = N'COLUMN', @level2name = N'CommunicationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CohortList Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationCohorts', @level2type = N'COLUMN', @level2name = N'PopulationDefinitionID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table (Patient User ID)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationCohorts', @level2type = N'COLUMN', @level2name = N'UserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag indicating that the patient doesn’t want to be part of the Cohort List', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationCohorts', @level2type = N'COLUMN', @level2name = N'IsExcludedByPreference';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationCohorts', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationCohorts', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationCohorts', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationCohorts', @level2type = N'COLUMN', @level2name = N'CreatedDate';

