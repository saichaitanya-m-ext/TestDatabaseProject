CREATE TABLE [dbo].[PatientADTModifier] (
    [PatientADTModifierId]    INT              IDENTITY (1, 1) NOT NULL,
    [PatientADTId]            [dbo].[KeyID]    NULL,
    [ProcedureCodeModifierID] [dbo].[KeyID]    NULL,
    [CreatedByUserId]         [dbo].[KeyID]    NULL,
    [CreatedDate]             [dbo].[UserDate] NULL,
    [LastModifiedUserId]      [dbo].[KeyID]    NULL,
    [LastModifiedDate]        [dbo].[UserDate] NULL,
    CONSTRAINT [PK_PatientADTModifier] PRIMARY KEY CLUSTERED ([PatientADTModifierId] ASC),
    CONSTRAINT [FK_PatientADTModifier_CodeSetProcedureModifier] FOREIGN KEY ([ProcedureCodeModifierID]) REFERENCES [dbo].[CodeSetProcedureModifier] ([ProcedureCodeModifierId]),
    CONSTRAINT [FK_PatientADTModifier_PatientADT] FOREIGN KEY ([PatientADTId]) REFERENCES [dbo].[PatientADT] ([PatientADTId])
);

