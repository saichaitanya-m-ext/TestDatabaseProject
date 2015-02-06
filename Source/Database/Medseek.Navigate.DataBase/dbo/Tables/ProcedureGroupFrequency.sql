CREATE TABLE [dbo].[ProcedureGroupFrequency] (
    [CodeGroupingID]       [dbo].[KeyID]            NOT NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_ProcedureGroupFrequency_StatusCode] DEFAULT ('A') NOT NULL,
    [FrequencyNumber]      [dbo].[KeyID]            NOT NULL,
    [Frequency]            VARCHAR (1)              NOT NULL,
    [GenderSpecific]       VARCHAR (1)              NULL,
    [CreatedByUserId]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_ProcedureGroupFrequency_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    [LastModifiedByUserId] [dbo].[KeyID]            NULL,
    [NeverSchedule]        BIT                      NULL,
    [ExclusionReason]      [dbo].[ShortDescription] NULL,
    [LabTestId]            [dbo].[KeyID]            NULL,
    CONSTRAINT [PK_ProcedureGroupFrequency] PRIMARY KEY CLUSTERED ([CodeGroupingID] ASC),
    CONSTRAINT [FK_ProcedureGroupFrequency_LabTests] FOREIGN KEY ([LabTestId]) REFERENCES [dbo].[LabTests] ([LabTestId]),
    CONSTRAINT [FKProcedureGroupFrequency_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID])
);

