CREATE TABLE [dbo].[NRPatientValue] (
    [NRPatientValueID]     [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [NRDefID]              [dbo].[KeyID]       NULL,
    [PatientID]            [dbo].[KeyID]       NOT NULL,
    [MetricID]             [dbo].[KeyID]       NOT NULL,
    [Value]                DECIMAL (10, 2)     NULL,
    [ValueDate]            DATE                NOT NULL,
    [IsIndicator]          [dbo].[IsIndicator] NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_NRPatientValue_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    [DateKey]              INT                 NULL,
    [FrequencyID]          INT                 NULL,
    CONSTRAINT [PK_NRPatientValue] PRIMARY KEY CLUSTERED ([NRPatientValueID] ASC),
    CONSTRAINT [FK_NRPatientValue_Metric] FOREIGN KEY ([MetricID]) REFERENCES [dbo].[Metric] ([MetricId]),
    CONSTRAINT [FK_NRPatientValue_MetricNumeratorFrequency] FOREIGN KEY ([FrequencyID]) REFERENCES [dbo].[MetricNumeratorFrequency] ([MetricNumeratorFrequencyId]),
    CONSTRAINT [FK_NRPatientValue_NRDef] FOREIGN KEY ([NRDefID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID]),
    CONSTRAINT [FK_NRPatientValue_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_NRPatientValue]
    ON [dbo].[NRPatientValue]([PatientID] ASC, [MetricID] ASC, [Value] ASC, [ValueDate] ASC, [DateKey] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

