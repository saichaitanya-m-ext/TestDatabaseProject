CREATE TABLE [dbo].[TaskRemainder] (
    [TaskRemainderId]                    INT         IDENTITY (1, 1) NOT NULL,
    [TaskId]                             INT         NULL,
    [CommunicationSequence]              INT         NULL,
    [CommunicationTypeID]                INT         NULL,
    [CommunicationAttemptDays]           INT         NULL,
    [NoOfDaysBeforeTaskClosedIncomplete] INT         NULL,
    [CommunicationTemplateID]            INT         NULL,
    [TaskTypeGeneralizedID]              INT         NULL,
    [IsAdhoc]                            BIT         NULL,
    [IsCompleted]                        BIT         NULL,
    [RemainderState]                     VARCHAR (1) NULL,
    CONSTRAINT [PK__TaskRema__915D91871B4073FD] PRIMARY KEY CLUSTERED ([TaskRemainderId] ASC),
    CONSTRAINT [FK_TaskRemainder_CommunicationTemplateId] FOREIGN KEY ([CommunicationTemplateID]) REFERENCES [dbo].[CommunicationTemplate] ([CommunicationTemplateId]),
    CONSTRAINT [FK_TaskRemainder_CommunicationTypeID] FOREIGN KEY ([CommunicationTypeID]) REFERENCES [dbo].[CommunicationType] ([CommunicationTypeId]),
    CONSTRAINT [FK_TaskRemainder_TaskId] FOREIGN KEY ([TaskId]) REFERENCES [dbo].[Task] ([TaskId])
);


GO
/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Insert_TaskRemainder]
Description:                     
When   Who    Action                      
14-Nov-2012 Rathnam  Created                      
---------------------------------------------------------------------      
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
---------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Insert_TaskRemainder] ON [dbo].[TaskRemainder]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON

	  SELECT Taskid, MIN(CommunicationSequence) CommunicationSequence
	  INTO #Tasks
	  FROM inserted
	  GROUP BY TaskId
	  	
      UPDATE
          Task
      SET
          RemainderID = INSERTED.TaskRemainderID
         ,CommunicationTypeID = INSERTED.CommunicationTypeID
         ,CommunicationTemplateID = INSERTED.CommunicationTemplateID
         ,RemainderDays = INSERTED.CommunicationAttemptDays
         ,CommunicationSequence = INSERTED.CommunicationSequence
         ,TotalRemainderCount = ( SELECT
                                      COUNT(*)
                                  FROM
                                      INSERTED I
                                  WHERE
                                      I.TaskID = INSERTED.TaskID )
         ,TerminationDays = INSERTED.NoOfDaysBeforeTaskClosedInComplete
         ,RemainderState = inserted.RemainderState
         ,NextRemainderDays = (SELECT TOP 1 I.CommunicationAttemptDays FROM inserted I WHERE I.TaskId = inserted.TaskId AND I.CommunicationSequence > #Tasks.CommunicationSequence ORDER BY I.CommunicationSequence ASC)
         ,NextRemainderState = (SELECT TOP 1 I.RemainderState FROM inserted I WHERE I.TaskId = inserted.TaskId AND I.CommunicationSequence > #Tasks.CommunicationSequence ORDER BY I.CommunicationSequence ASC)
      FROM
          INSERTED
      INNER JOIN #Tasks
          ON #Tasks.TaskId = inserted.TaskId    
      WHERE
          Task.RemainderID IS NULL
          AND INSERTED.CommunicationSequence = #Tasks.CommunicationSequence
          AND INSERTED.TaskID = Task.TaskID
          AND Task.TerminationDays IS NULL
          AND ISNULL(Task.IsEnrollment,0) = 0
          AND ISNULL(IsProgramTask,0) = 0

END
