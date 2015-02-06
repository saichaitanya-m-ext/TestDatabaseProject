CREATE TABLE [dbo].[Task] (
    [TaskId]                  [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PatientId]               [dbo].[KeyID]            NOT NULL,
    [ProgramID]               [dbo].[KeyID]            NULL,
    [TaskTypeId]              [dbo].[KeyID]            NULL,
    [TaskDueDate]             [dbo].[UserDate]         NULL,
    [TaskCompletedDate]       [dbo].[UserDate]         NULL,
    [TaskStatusId]            [dbo].[KeyID]            NOT NULL,
    [AssignedCareProviderId]  [dbo].[KeyID]            NULL,
    [TypeID]                  [dbo].[KeyID]            NULL,
    [Isadhoc]                 BIT                      NULL,
    [IsEnrollment]            BIT                      CONSTRAINT [DF_Task_IsEnrollment] DEFAULT ((0)) NULL,
    [IsProgramTask]           BIT                      NULL,
    [ManualTaskName]          [dbo].[ShortDescription] NULL,
    [CommunicationTemplateID] INT                      NULL,
    [CommunicationSequence]   INT                      NULL,
    [CommunicationTypeID]     INT                      NULL,
    [RemainderID]             INT                      NULL,
    [LastAttemptDate]         DATETIME                 NULL,
    [TotalRemainderCount]     SMALLINT                 NULL,
    [AttemptedRemainderCount] SMALLINT                 NULL,
    [RemainderDays]           SMALLINT                 NULL,
    [TerminationDays]         SMALLINT                 NULL,
    [RemainderState]          VARCHAR (1)              NULL,
    [NextRemainderDays]       SMALLINT                 NULL,
    [NextRemainderState]      VARCHAR (1)              NULL,
    [Comments]                [dbo].[LongDescription]  NULL,
    [CreatedByUserId]         [dbo].[KeyID]            NOT NULL,
    [CreatedDate]             [dbo].[UserDate]         CONSTRAINT [DF_Task_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    [dbo].[KeyID]            NULL,
    [LastModifiedDate]        [dbo].[UserDate]         NULL,
    [IsBatchProgram]          BIT                      NULL,
    [PatientTaskID]           [dbo].[KeyID]            NULL,
    [PatientADTId]            INT                      NULL,
    CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED ([TaskId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Task_CommunicationTemplate] FOREIGN KEY ([CommunicationTemplateID]) REFERENCES [dbo].[CommunicationTemplate] ([CommunicationTemplateId]),
    CONSTRAINT [FK_Task_CommunicationType] FOREIGN KEY ([CommunicationTypeID]) REFERENCES [dbo].[CommunicationType] ([CommunicationTypeId]),
    CONSTRAINT [FK_Task_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_Task_PatientADT] FOREIGN KEY ([PatientADTId]) REFERENCES [dbo].[PatientADT] ([PatientADTId]),
    CONSTRAINT [FK_Task_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId]),
    CONSTRAINT [FK_Task_TaskStatus] FOREIGN KEY ([TaskStatusId]) REFERENCES [dbo].[TaskStatus] ([TaskStatusId]),
    CONSTRAINT [FK_Task_TaskType] FOREIGN KEY ([TaskTypeId]) REFERENCES [dbo].[TaskType] ([TaskTypeId])
);


GO
CREATE NONCLUSTERED INDEX [UIX_Task_PatientUserId]
    ON [dbo].[Task]([PatientId] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Task_TaskDueDate]
    ON [dbo].[Task]([TaskStatusId] ASC, [TaskDueDate] ASC)
    INCLUDE([PatientId]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Task_TaskStatusId]
    ON [dbo].[Task]([TaskStatusId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Task_TaskTypeId]
    ON [dbo].[Task]([TaskTypeId] ASC)
    INCLUDE([TaskId], [PatientId], [TaskDueDate], [TaskStatusId]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Task_ProgramID]
    ON [dbo].[Task]([ProgramID] ASC)
    INCLUDE([TaskTypeId], [TypeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Task_Program_PatientUserID]
    ON [dbo].[Task]([ProgramID] ASC)
    INCLUDE([PatientId]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Task_TaskStatusIdInclude]
    ON [dbo].[Task]([TaskStatusId] ASC)
    INCLUDE([TaskId], [PatientId], [ProgramID], [TaskTypeId], [TaskDueDate], [RemainderDays], [TerminationDays], [RemainderState]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Task_TaskType]
    ON [dbo].[Task]([TaskTypeId] ASC, [ProgramID] ASC, [TaskId] ASC, [TaskStatusId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Task_PatientUserId]
    ON [dbo].[Task]([PatientId] ASC, [TaskId] ASC, [TaskCompletedDate] DESC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Task_TaskStatusIDProgramID]
    ON [dbo].[Task]([TaskStatusId] ASC, [ProgramID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Task_Include2]
    ON [dbo].[Task]([PatientId] ASC, [IsEnrollment] ASC, [ProgramID] ASC, [TaskId] ASC, [TaskStatusId] ASC)
    INCLUDE([TaskDueDate]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_Task_Include1]
    ON [dbo].[Task]([PatientId] ASC, [TaskId] ASC, [TaskStatusId] ASC, [ProgramID] ASC, [TaskTypeId] ASC)
    INCLUDE([TypeID], [ManualTaskName], [TerminationDays], [TaskDueDate]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_IsBatchProgram]
    ON [dbo].[Task]([IsBatchProgram] ASC)
    INCLUDE([TaskTypeId], [PatientTaskID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Insert_Task]                   
Description:                     
When   Who    Action                      
---------------------------------------------------------------------      

*/
CREATE TRIGGER [dbo].[tr_Insert_Task] ON dbo.Task
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON
      
      --> Only for Patient Page related tasks for updating the Specific / Default Schedules
      UPDATE
          Task
      SET
          AttemptedRemainderCount = NextCommnication.CommunicationCount
         ,CommunicationTemplateID = NextCommnication.CommunicationTemplateID
         ,RemainderDays = NextCommnication.CommunicationAttemptDays
         ,TerminationDays = NextCommnication.NoOfDaysBeforeTaskClosedIncomplete
         ,RemainderID = NextCommnication.TaskTypeCommunicationID
         ,CommunicationSequence = NextCommnication.NextCommunicationSequence
         ,CommunicationTypeID = NextCommnication.CommunicationTypeID
         ,TotalRemainderCount = NextCommnication.TotalFutureTasks
         ,RemainderState = NextCommnication.RemainderState
         ,NextRemainderDays = NextCommnication.NextRemainderDays
         ,NextRemainderState = NextCommnication.NextRemainderState
      FROM
          INSERTED
          CROSS APPLY ufn_GetRemaindersByTaskID(INSERTED.TaskID , INSERTED.TaskTypeID , INSERTED.TypeID, ISNULL(inserted.CommunicationSequence,0)) NextCommnication
      WHERE
          inserted.Taskid = Task.TaskId
          AND ISNULL(Task.IsEnrollment,0) = 0
          AND ISNULL(Task.Isadhoc,0) = 0
          AND ISNULL(Task.IsProgramTask,0) = 0
          
      UPDATE Task
      SET AssignedCareProviderId = ups.ProviderID
      FROM PatientProgram ups
      INNER JOIN inserted i
      ON i.PatientID = ups.PatientID
      AND i.ProgramID = ups.ProgramId
      WHERE Task.TaskId = i.TaskID
      AND Task.AssignedCareProviderId IS NULL    
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A task that must be done my a care provider for a specific patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the Task Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'TaskId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'PatientId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the TaskType table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'TaskTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the task is due', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'TaskDueDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the tacks was completed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'TaskCompletedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the TaskStatus table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'TaskStatusId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Task', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

