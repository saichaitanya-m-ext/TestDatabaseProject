CREATE TABLE [dbo].[TaskAttempts] (
    [TaskId]                  [dbo].[KeyID]    NOT NULL,
    [TasktypeCommunicationID] [dbo].[KeyID]    NULL,
    [AttemptedContactDate]    [dbo].[UserDate] NULL,
    [Comments]                VARCHAR (100)    NULL,
    [UserId]                  [dbo].[KeyID]    NULL,
    [NextContactDate]         [dbo].[UserDate] NULL,
    [TaskTerminationDate]     [dbo].[UserDate] NULL,
    [CommunicationTemplateID] [dbo].[KeyID]    NULL,
    [AttemptStatus]           BIT              NULL,
    [CommunicationSequence]   [dbo].[KeyID]    NULL,
    [CommunicationTypeId]     [dbo].[KeyID]    NULL,
    CONSTRAINT [FK_TaskAttempts_CommunicationTemplate] FOREIGN KEY ([CommunicationTemplateID]) REFERENCES [dbo].[CommunicationTemplate] ([CommunicationTemplateId]),
    CONSTRAINT [FK_TaskAttempts_Task] FOREIGN KEY ([TaskId]) REFERENCES [dbo].[Task] ([TaskId])
);


GO
CREATE NONCLUSTERED INDEX [IX_TaskAttempts_TaskId]
    ON [dbo].[TaskAttempts]([TaskId] ASC)
    INCLUDE([TasktypeCommunicationID], [AttemptedContactDate], [Comments], [UserId], [CommunicationTypeId]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Insert_TaskAttempts]
Description:                     
When   Who    Action                      
---------------------------------------------------------------------      
14-Nov-2012 Rathnam Created
---------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Insert_TaskAttempts] ON [dbo].[TaskAttempts]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON
--> Update the LastAttemptDate for caliculating the NextDueDate/Termination Date

	  --SELECT DISTINCT Task.Taskid, RemainderState , TaskDueDate
	  --INTO #RemainderSTate
	  --FROM Task
	  --INNER JOIN inserted
	  --ON Task.TaskId = inserted.TaskId	
      UPDATE
          Task
      SET
          LastAttemptDate = Inserted.AttemptedContactDate --CASE WHEN t.RemainderState = 'B' THEN t.TaskDueDate ELSE Inserted.AttemptedContactDate END
         ,CommunicationTypeID = CASE
                                     WHEN INSERTED.TaskTerminationDate IS NOT NULL THEN NULL
                                     ELSE Task.CommunicationTypeID
                                END
         ,CommunicationTemplateID = CASE
                                         WHEN INSERTED.TaskTerminationDate IS NOT NULL THEN NULL
                                         ELSE Task.CommunicationTemplateID
                                    END
         ,RemainderDays = CASE
                               WHEN INSERTED.TaskTerminationDate IS NOT NULL THEN NULL
                               ELSE Task.RemainderDays
                          END
      FROM
          INSERTED
      WHERE
          INSERTED.TaskID = Task.TaskID
          AND INSERTED.TaskTypeCommunicationID = Task.RemainderID
          

--> Updating the next Remainder information once attempt the previous remainder for sequence related remainders

		--> For Adhoc 


      SELECT DISTINCT
          Task.TaskID
         ,Task.CommunicationSequence CommunicationSequence
      INTO
          #tblAdhocTasks
      FROM
          Task WITH ( Nolock )
      INNER JOIN inserted
          ON inserted.TaskID = Task.TaskID
      WHERE 
          ISNULL(Task.IsEnrollment , 0) = 0
          AND ISNULL(Task.IsProgramTask , 0) = 0
          AND ISNULL(Task.Isadhoc,0) = 1
     
	  UPDATE
          Task
      SET
          AttemptedRemainderCount = NextCommnication.CommunicationCount
         ,CommunicationTemplateID = NextCommnication.CommunicationTemplateID
         ,RemainderDays = NextCommnication.CommunicationAttemptDays
         ,TerminationDays = CASE WHEN Task.TerminationDays IS NOT NULL THEN Task.TerminationDays ELSE  NextCommnication.NoOfDaysBeforeTaskClosedIncomplete END
         ,RemainderID = NextCommnication.TaskTypeCommunicationID
         ,CommunicationSequence = NextCommnication.NextCommunicationSequence
         ,CommunicationTypeID = NextCommnication.CommunicationTypeID
         ,TotalRemainderCount = NextCommnication.TotalFutureTasks
         ,RemainderState = NextCommnication.RemainderState
         ,NextRemainderDays = NextCommnication.NextRemainderDays
         ,NextRemainderState = NextCommnication.NextRemainderState
      FROM
          #tblAdhocTasks
          CROSS APPLY ufn_GetAdhocRemaindersByTaskID(#tblAdhocTasks.TaskID , #tblAdhocTasks.CommunicationSequence) NextCommnication
      WHERE
          #tblAdhocTasks.taskid = Task.TaskId
          AND ISNULL(Task.IsEnrollment , 0) = 0
          AND ISNULL(IsProgramTask , 0) = 0
          AND ISNULL(Task.Isadhoc,0) = 1
		
      --UPDATE
      --    Task
      --SET
      --    RemainderID = tr.TaskRemainderID
      --   ,CommunicationTypeID = tr.CommunicationTypeID
      --   ,CommunicationTemplateID = tr.CommunicationTemplateID
      --   ,RemainderDays = tr.CommunicationAttemptDays
      --   ,CommunicationSequence = tr.CommunicationSequence
      --   ,TotalRemainderCount = ( SELECT
      --                                COUNT(*)
      --                            FROM
      --                                TaskRemainder WITH ( Nolock )
      --                            WHERE
      --                                TaskRemainder.TaskID = tr.TaskID )
      --   ,TerminationDays = CASE
      --                           WHEN TerminationDays IS NULL THEN tr.NoOfDaysBeforeTaskClosedInComplete
      --                           ELSE TerminationDays
      --                      END
      --   ,AttemptedRemainderCount = ( SELECT
      --                                    COUNT(*)
      --                                FROM
      --                                    TaskAttempts WITH ( Nolock )
      --                                WHERE
      --                                    TaskAttempts.TaskID = tr.TaskID )
      --   ,RemainderState = tr.RemainderState
        
      --FROM
      --    TaskRemainder tr WITH ( NOLOCK )
      --    INNER JOIN #tblAdhocTasks tt
      --    ON tt.TaskID = tr.TaskID
      --WHERE
      --    Task.TaskID = tr.TaskID
      --    AND tr.CommunicationSequence = tt.CommunicationSequence + 1
      --    AND ISNULL(Task.IsEnrollment , 0) = 0
      --    AND ISNULL(IsProgramTask , 0) = 0
      --    AND ISNULL(Task.Isadhoc,0) = 1
          
          
		--> For Managed Population Patients

      SELECT DISTINCT
          Task.TaskID
         ,Task.CommunicationSequence CommunicationSequence
         ,Task.ProgramID
         ,Task.TypeID
         ,Task.TaskTypeID
      INTO
          #tblProgramTasks
      FROM
          Task WITH ( Nolock )
      INNER JOIN inserted
          ON inserted.TaskID = Task.TaskID
      WHERE
          ISNULL(Task.IsEnrollment , 0) = 0
          AND ISNULL(IsProgramTask , 0) = 1
          AND ISNULL(Task.Isadhoc,0) = 0
      

      UPDATE
          Task
      SET
          AttemptedRemainderCount = NextCommnication.CommunicationCount
         ,CommunicationTemplateID = NextCommnication.CommunicationTemplateID
         ,RemainderDays = NextCommnication.CommunicationAttemptDays
         ,TerminationDays = CASE WHEN Task.TerminationDays IS NOT NULL THEN Task.TerminationDays ELSE  NextCommnication.NoOfDaysBeforeTaskClosedIncomplete END
         ,RemainderID = NextCommnication.TaskTypeCommunicationID
         ,CommunicationSequence = NextCommnication.NextCommunicationSequence
         ,CommunicationTypeID = NextCommnication.CommunicationTypeID
         ,TotalRemainderCount = NextCommnication.TotalFutureTasks
         ,RemainderState = NextCommnication.RemainderState
         ,NextRemainderDays = NextCommnication.NextRemainderDays
         ,NextRemainderState = NextCommnication.NextRemainderState
      FROM
          #tblProgramTasks
          CROSS APPLY ufn_GetProgramRemaindersByTaskID(#tblProgramTasks.TaskID , #tblProgramTasks.ProgramID, #tblProgramTasks.TaskTypeID , #tblProgramTasks.TypeID, #tblProgramTasks.CommunicationSequence) NextCommnication
      WHERE
          #tblProgramTasks.taskid = Task.TaskId
          AND ISNULL(Task.IsEnrollment , 0) = 0
          AND ISNULL(IsProgramTask , 0) = 1
          AND ISNULL(Task.Isadhoc,0) = 0
      
      
      
      --UPDATE
      --    Task
      --SET
      --    RemainderID = tr.ProgramTaskTypeCommunicationID
      --   ,CommunicationTypeID = tr.CommunicationTypeID
      --   ,CommunicationTemplateID = tr.CommunicationTemplateID
      --   ,RemainderDays = tr.CommunicationAttemptDays
      --   ,CommunicationSequence = tr.CommunicationSequence
      --   ,TotalRemainderCount = ( SELECT
      --                                COUNT(*)
      --                            FROM
      --                                ProgramTaskTypeCommunication WITH ( Nolock )
      --                            INNER JOIN #tblProgramTasks t1
      --                                ON ProgramTaskTypeCommunication.ProgramId = t1.ProgramId
      --                                   AND ProgramTaskTypeCommunication.GeneralizedID = t1.TypeID
      --                                   AND ProgramTaskTypeCommunication.TaskTypeID = t1.TaskTypeID )
      --   ,TerminationDays = CASE
      --                           WHEN TerminationDays IS NULL THEN tr.NoOfDaysBeforeTaskClosedInComplete
      --                           ELSE TerminationDays
      --                      END
      --   ,AttemptedRemainderCount = ( SELECT
      --                                    COUNT(*)
      --                                FROM
      --                                    TaskAttempts WITH ( Nolock )
      --                                WHERE
      --                                    TaskAttempts.TaskID = t.TaskID )
      --  ,RemainderState = tr.RemainderState 
      --FROM
      --    ProgramTaskTypeCommunication tr WITH ( Nolock )
      --    INNER JOIN #tblProgramTasks t
      --    ON t.ProgramId = tr.ProgramId
      --    AND t.TypeID = tr.GeneralizedID
      --    AND t.TaskTypeID = tr.TaskTypeID
      --WHERE
      --    Task.TaskID = t.TaskID
      --    AND tr.CommunicationSequence = t.CommunicationSequence + 1
      --    AND ISNULL(Task.IsEnrollment , 0) = 0
      --    AND ISNULL(IsProgramTask , 0) = 1
      --    AND ISNULL(Task.Isadhoc,0) = 0
      --    AND tr.StatusCode = 'A'
                                
         --> For PatientPageTasks


      SELECT DISTINCT
          Task.TaskID
         ,Task.TypeID
         ,Task.TaskTypeID
         ,ISNULL(Task.CommunicationSequence,0) CommunicationSequence
      INTO
          #tblPatientTasks
      FROM
          Task WITH ( Nolock )
      INNER JOIN inserted
          ON inserted.TaskID = Task.TaskID
      WHERE
          ISNULL(Task.IsEnrollment , 0) = 0
          AND ISNULL(Task.Isadhoc , 0) = 0
          AND ISNULL(Task.IsProgramTask , 0) = 0

      UPDATE
          Task
      SET
          AttemptedRemainderCount = NextCommnication.CommunicationCount
         ,CommunicationTemplateID = NextCommnication.CommunicationTemplateID
         ,RemainderDays = NextCommnication.CommunicationAttemptDays
         ,TerminationDays = CASE WHEN Task.TerminationDays IS NOT NULL THEN Task.TerminationDays ELSE  NextCommnication.NoOfDaysBeforeTaskClosedIncomplete END
         ,RemainderID = NextCommnication.TaskTypeCommunicationID
         ,CommunicationSequence = NextCommnication.NextCommunicationSequence
         ,CommunicationTypeID = NextCommnication.CommunicationTypeID
         ,TotalRemainderCount = NextCommnication.TotalFutureTasks
         ,RemainderState = NextCommnication.RemainderState
         ,NextRemainderDays = NextCommnication.NextRemainderDays
         ,NextRemainderState = NextCommnication.NextRemainderState
      FROM
          #tblPatientTasks
          CROSS APPLY ufn_GetRemaindersByTaskID(#tblPatientTasks.TaskID , #tblPatientTasks.TaskTypeID , #tblPatientTasks.TypeID, #tblPatientTasks.CommunicationSequence) NextCommnication
      WHERE
          #tblPatientTasks.taskid = Task.TaskId
          AND ISNULL(Task.IsEnrollment , 0) = 0
          AND ISNULL(Task.Isadhoc , 0) = 0
          AND ISNULL(Task.IsProgramTask , 0) = 0
          
          
--> Updating the next Remainder information once attempt the previous Adhoc remainder related to the Adhoc Remainders
      --UPDATE
      --    Task
      --SET
      --    AdhocRemainderID = tr.TaskRemainderID
      --   ,AdhocContactDate = tr.AdhocContactDate
      --   ,AdhocCommunicationTypeID = tr.CommunicationTypeID
      --   ,AdhocTemplateID = tr.CommunicationTemplateID
      --FROM
      --    inserted
      --    INNER JOIN
      --    ( SELECT
      --          TaskRemainder.TaskID
      --         ,min(AdhocContactDate) AdhocContactDate
      --      FROM
      --          TaskRemainder
      --      INNER JOIN INSERTED
      --          ON INSERTED.TaskID = TaskRemainder.TaskID
      --      WHERE
      --          INSERTED.IsAdhocRemainder = 1
      --          AND ISNULL(TaskRemainder.IsCompleted , 0) = 0
      --          AND TaskRemainder.AdhocContactDate IS NOT NULL
      --      GROUP BY
      --          TaskRemainder.TaskID ) tr1
      --    ON tr1.TaskID = inserted.TaskID
      --    INNER JOIN TaskRemainder tr
      --    ON tr.TaskID = inserted.TaskID
      --WHERE
      --    INSERTED.TaskID = Task.TaskID
      --    AND tr.AdhocContactDate IS NOT NULL
      --    AND INSERTED.IsAdhocRemainder = 1
      --    AND ISNULL(tr.IsCompleted , 0) = 0
      --    AND CONVERT(DATE , tr.AdhocContactDate) = CONVERT(DATE , tr1.AdhocContactDate)

END






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The list of Care Provider attempts to perform a specific Patient related Task', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttempts';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Task Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttempts', @level2type = N'COLUMN', @level2name = N'TaskId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the care provider attempted to contact the patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttempts', @level2type = N'COLUMN', @level2name = N'AttemptedContactDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttempts', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the users table - indicates the patient for the task', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttempts', @level2type = N'COLUMN', @level2name = N'UserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The next date we plan to contact the patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttempts', @level2type = N'COLUMN', @level2name = N'NextContactDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the task is terminated (Closed Incomplete) if the patient did not respond', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttempts', @level2type = N'COLUMN', @level2name = N'TaskTerminationDate';

