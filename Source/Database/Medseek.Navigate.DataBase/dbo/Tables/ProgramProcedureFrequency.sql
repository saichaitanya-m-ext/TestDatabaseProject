CREATE TABLE [dbo].[ProgramProcedureFrequency] (
    [ProgramId]            [dbo].[KeyID]       NOT NULL,
    [ProcedureId]          [dbo].[KeyID]       NOT NULL,
    [StatusCode]           [dbo].[StatusCode]  CONSTRAINT [DF_ProgramProcedureFrequency_StatusCode] DEFAULT ('A') NOT NULL,
    [FrequencyNumber]      [dbo].[KeyID]       NULL,
    [Frequency]            VARCHAR (1)         NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_ProgramProcedureFrequency_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    [NeverSchedule]        BIT                 NULL,
    [ExclusionReason]      VARCHAR (100)       NULL,
    [LabTestId]            [dbo].[KeyID]       NULL,
    [EffectiveStartDate]   [dbo].[UserDate]    NULL,
    [DiseaseID]            [dbo].[KeyID]       NULL,
    [IsPreventive]         [dbo].[IsIndicator] CONSTRAINT [DF_ProgramProcedureFrequency_IsPreventive] DEFAULT ((0)) NULL,
    [FrequencyCondition]   [dbo].[SourceName]  NULL,
    CONSTRAINT [PK_ProgramProcedureFrequency] PRIMARY KEY CLUSTERED ([ProgramId] ASC, [ProcedureId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_ProgramProcedureFrequency_CodeSetProcedure] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[CodeSetProcedure] ([ProcedureCodeID]),
    CONSTRAINT [FK_ProgramProcedureFrequency_DiseaseID] FOREIGN KEY ([DiseaseID]) REFERENCES [dbo].[Disease] ([DiseaseId]),
    CONSTRAINT [FK_ProgramProcedureFrequency_LabTests] FOREIGN KEY ([LabTestId]) REFERENCES [dbo].[LabTests] ([LabTestId]),
    CONSTRAINT [FK_ProgramProcedureFrequency_Program] FOREIGN KEY ([ProgramId]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This is the frequency that a specific procedure should be done for all the patients enrolled in a program', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the program Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'ProgramId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CodeSetProcedure table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'ProcedureId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Frequency Number integer to  define the period between each instance of the procedure', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'FrequencyNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Frequency period D = Days, W = Weeks, M = Months and Y = Years. Example if Frequency Number = 3 and Frequency = W then the procedure should be done every three weeks', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'Frequency';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

