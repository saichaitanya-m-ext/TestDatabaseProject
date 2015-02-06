CREATE TABLE [dbo].[ProgramPatientTasks] (
    [ProgramPatientTaskConflictID] [dbo].[KeyID]      NOT NULL,
    [ProgramTaskBundleId]          [dbo].[KeyID]      NOT NULL,
    [ConflictProgramTaskBundleID]  [dbo].[KeyID]      NOT NULL,
    [StatusCode]                   [dbo].[StatusCode] CONSTRAINT [DFProgramPatientTasksStatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]              [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                  [dbo].[UserDate]   CONSTRAINT [DFProgramPatientTasksCreatedDate] DEFAULT (getdate()) NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramPatientTasks', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramPatientTasks', @level2type = N'COLUMN', @level2name = N'CreatedDate';

