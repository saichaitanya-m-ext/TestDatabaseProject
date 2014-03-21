CREATE TABLE [dbo].[PatientADTProcedure] (
    [PatientADTProcedureId] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PatientADTId]          [dbo].[KeyID]    NOT NULL,
    [ProcedureCodeId]       [dbo].[KeyID]    NOT NULL,
    [RendaringProviderId]   [dbo].[KeyID]    NULL,
    [CreatedByUserId]       [dbo].[KeyID]    NOT NULL,
    [CreatedDate]           [dbo].[UserDate] CONSTRAINT [DF_PatientADTProcedure_CreadtedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]  [dbo].[KeyID]    NULL,
    [LastModifiedDate]      [dbo].[UserDate] NULL,
    [ProcedureDate]         [dbo].[UserDate] NULL,
    CONSTRAINT [PK_PatientADTProcedure] PRIMARY KEY CLUSTERED ([PatientADTProcedureId] ASC),
    CONSTRAINT [FK_PatientADTProcedure_CodeSetProcedure] FOREIGN KEY ([ProcedureCodeId]) REFERENCES [dbo].[CodeSetProcedure] ([ProcedureCodeID]),
    CONSTRAINT [FK_PatientADTProcedure_PatientADT] FOREIGN KEY ([PatientADTId]) REFERENCES [dbo].[PatientADT] ([PatientADTId]),
    CONSTRAINT [FK_PatientADTProcedure_Provider] FOREIGN KEY ([RendaringProviderId]) REFERENCES [dbo].[Provider] ([ProviderID])
);

