CREATE TABLE [dbo].[NRPatientCount] (
    [NRPatientCountID]     [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [NRDefID]              [dbo].[KeyID]       NULL,
    [PatientID]            [dbo].[KeyID]       NOT NULL,
    [MetricID]             [dbo].[KeyID]       NOT NULL,
    [Count]                INT                 NOT NULL,
    [IsIndicator]          [dbo].[IsIndicator] NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_NRPatientCount_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    [DateKey]              INT                 NULL,
    [FrequencyID]          INT                 NULL,
    CONSTRAINT [PK_NRPatientCount] PRIMARY KEY CLUSTERED ([NRPatientCountID] ASC),
    CONSTRAINT [FK_NRPatientCount_Metric] FOREIGN KEY ([MetricID]) REFERENCES [dbo].[Metric] ([MetricId]),
    CONSTRAINT [FK_NRPatientCount_MetricNumeratorFrequency] FOREIGN KEY ([FrequencyID]) REFERENCES [dbo].[MetricNumeratorFrequency] ([MetricNumeratorFrequencyId]),
    CONSTRAINT [FK_NRPatientCount_NRDef] FOREIGN KEY ([NRDefID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID]),
    CONSTRAINT [FK_NRPatientCount_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_NRPatientCount]
    ON [dbo].[NRPatientCount]([PatientID] ASC, [MetricID] ASC, [DateKey] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_NRPatientCount_[DateKey]
    ON [dbo].[NRPatientCount]([DateKey] ASC)
    INCLUDE([PatientID], [MetricID], [Count], [IsIndicator]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

