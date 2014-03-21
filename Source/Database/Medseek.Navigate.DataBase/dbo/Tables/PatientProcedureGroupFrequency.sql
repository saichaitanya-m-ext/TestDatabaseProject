CREATE TABLE [dbo].[PatientProcedureGroupFrequency] (
    [PatientId]              [dbo].[KeyID]      NOT NULL,
    [CodeGroupingID]         [dbo].[KeyID]      NOT NULL,
    [FrequencyNumber]        [dbo].[KeyID]      NOT NULL,
    [Frequency]              [dbo].[StatusCode] NOT NULL,
    [EffectiveStartDate]     [dbo].[UserDate]   CONSTRAINT [DF_PatientProcedureGroupFrequency_EffectiveStartDate] DEFAULT (getdate()) NOT NULL,
    [ManagedPopulationID]    [dbo].[KeyID]      NOT NULL,
    [AssignedCareProviderId] [dbo].[KeyID]      NOT NULL,
    [StatusCode]             [dbo].[StatusCode] CONSTRAINT [DF_PatientProcedureGroupFrequency_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]        [dbo].[KeyID]      NULL,
    [CreatedDate]            [dbo].[UserDate]   CONSTRAINT [DF_PatientProcedureGroupFrequency_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]      NULL,
    [LastModifiedDate]       [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_PatientProcedureGroupFrequency_1] PRIMARY KEY CLUSTERED ([PatientId] ASC, [CodeGroupingID] ASC),
    CONSTRAINT [FK_PatientProcedureGroupFrequency_AssignedCareProvider] FOREIGN KEY ([AssignedCareProviderId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientProcedureGroupFrequency_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_PatientProcedureGroupFrequency_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientProcedureGroupFrequency_Program] FOREIGN KEY ([ManagedPopulationID]) REFERENCES [dbo].[Program] ([ProgramId])
);

