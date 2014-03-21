CREATE TABLE [dbo].[PatientProcedureGroupFrequencyOverride] (
    [PatientProcedureGroupFrequencyOverrideID] [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PatientID]                                [dbo].[KeyID]            NOT NULL,
    [CodeGroupingID]                           [dbo].[KeyID]            NOT NULL,
    [FrequencyNumber]                          [dbo].[KeyID]            NOT NULL,
    [Frequency]                                [dbo].[StatusCode]       NOT NULL,
    [CreatedByUserId]                          [dbo].[KeyID]            NULL,
    [CreatedDate]                              [dbo].[UserDate]         CONSTRAINT [DF_PatientProcedureGroupFrequencyOverride_CreatedDate] DEFAULT (getdate()) NULL,
    [StatusCode]                               [dbo].[StatusCode]       CONSTRAINT [DF_PatientProcedureGroupFrequencyOverride_StatusCode] DEFAULT ('A') NOT NULL,
    [EffectiveDate]                            [dbo].[UserDate]         NULL,
    [ProgramID]                                [dbo].[KeyID]            NULL,
    [ChangeType]                               VARCHAR (8)              NULL,
    [NeverSchedule]                            BIT                      NOT NULL,
    [ExclusionReason]                          [dbo].[ShortDescription] NULL,
    CONSTRAINT [PK_PatientProcedureGroupFrequencyOverride] PRIMARY KEY CLUSTERED ([PatientProcedureGroupFrequencyOverrideID] ASC),
    CONSTRAINT [FK_PatientProcedureGroupFrequencyOverride_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_PatientProcedureGroupFrequencyOverride_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientProcedureGroupFrequencyOverride_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId])
);

