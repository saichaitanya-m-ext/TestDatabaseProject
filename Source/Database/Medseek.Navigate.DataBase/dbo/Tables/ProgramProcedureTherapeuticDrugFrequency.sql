CREATE TABLE [dbo].[ProgramProcedureTherapeuticDrugFrequency] (
    [ProgramProcedureTherapeuticDrugFrequencyID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [ProgramId]                                  [dbo].[KeyID]    NOT NULL,
    [ProcedureId]                                [dbo].[KeyID]    NOT NULL,
    [TherapeuticID]                              [dbo].[KeyID]    NULL,
    [DrugCodeId]                                 [dbo].[KeyID]    NULL,
    [Duration]                                   SMALLINT         NOT NULL,
    [DurationType]                               CHAR (1)         NOT NULL,
    [Frequency]                                  SMALLINT         NOT NULL,
    [FrequencyUOM]                               CHAR (1)         NOT NULL,
    [CreatedByUserId]                            [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                                [dbo].[UserDate] CONSTRAINT [DF_ProgramProcedureTherapeuticDrugFrequency_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]                       [dbo].[KeyID]    NULL,
    [LastModifiedDate]                           [dbo].[UserDate] NULL,
    CONSTRAINT [PK_ProgramProcedureTherapeuticDrugFrequency] PRIMARY KEY CLUSTERED ([ProgramProcedureTherapeuticDrugFrequencyID] ASC),
    CONSTRAINT [FK_ProgramProcedureTherapeuticDrugFrequency_CodeSetDrug] FOREIGN KEY ([DrugCodeId]) REFERENCES [dbo].[CodeSetDrug] ([DrugCodeId]),
    CONSTRAINT [FK_ProgramProcedureTherapeuticDrugFrequency_ProgramProcedureFrequency] FOREIGN KEY ([ProgramId], [ProcedureId]) REFERENCES [dbo].[ProgramProcedureFrequency] ([ProgramId], [ProcedureId]),
    CONSTRAINT [FK_ProgramProcedureTherapeuticDrugFrequency_TherapeuticClass] FOREIGN KEY ([TherapeuticID]) REFERENCES [dbo].[TherapeuticClass] ([TherapeuticID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureTherapeuticDrugFrequency', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureTherapeuticDrugFrequency', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureTherapeuticDrugFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureTherapeuticDrugFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

