CREATE TABLE [dbo].[ProgramPatientTaskConflict] (
    [ProgramTaskBundleId]  [dbo].[KeyID]       NOT NULL,
    [PatientUserID]        [dbo].[KeyID]       NOT NULL,
    [StatusCode]           [dbo].[StatusCode]  CONSTRAINT [DF_ProgramPatientTaskConflict_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_ProgramPatientTaskConflict_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    [IsConflictResolved]   [dbo].[IsIndicator] CONSTRAINT [DF_ProgramPatientTaskConflict_IsConflictResolved] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ProgramPatientTaskConflict] PRIMARY KEY CLUSTERED ([ProgramTaskBundleId] ASC, [PatientUserID] ASC),
    CONSTRAINT [FK_ProgramPatientTaskConflict_Patient] FOREIGN KEY ([PatientUserID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_ProgramPatientTaskConflict_ProgramTaskBundleID] FOREIGN KEY ([ProgramTaskBundleId]) REFERENCES [dbo].[ProgramTaskBundle] ([ProgramTaskBundleID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ProgramPatientTaskConflict]
    ON [dbo].[ProgramPatientTaskConflict]([ProgramTaskBundleId] ASC, [PatientUserID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramPatientTaskConflict', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramPatientTaskConflict', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramPatientTaskConflict', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramPatientTaskConflict', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

