CREATE TABLE [dbo].[PatientOtherTask] (
    [PatientOtherTaskId]       INT            IDENTITY (1, 1) NOT NULL,
    [PatientId]                INT            NOT NULL,
    [PatientProgramID]         [dbo].[KeyID]  NULL,
    [AdhocTaskId]              INT            NOT NULL,
    [DateTaken]                DATETIME       NULL,
    [Comments]                 VARCHAR (4000) NULL,
    [DateDue]                  DATETIME       NOT NULL,
    [StatusCode]               VARCHAR (1)    CONSTRAINT [DF_UserOtherTask_StatusCode] DEFAULT ('A') NOT NULL,
    [ProgramId]                INT            NULL,
    [CreatedDate]              DATETIME       CONSTRAINT [DF_UserOtherTask_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedByUserId]          INT            NOT NULL,
    [LastModifiedByUserId]     INT            NULL,
    [LastModifiedDate]         DATETIME       NULL,
    [IsProgramTask]            BIT            NULL,
    [PatientEducationMaterial] INT            NULL,
    CONSTRAINT [PK_UserOtherTask] PRIMARY KEY CLUSTERED ([PatientOtherTaskId] ASC),
    CONSTRAINT [FK_PatientOtherTask_PatientProgram] FOREIGN KEY ([PatientProgramID]) REFERENCES [dbo].[PatientProgram] ([PatientProgramID]),
    CONSTRAINT [FK_UserOtherTask_AdhocTask] FOREIGN KEY ([AdhocTaskId]) REFERENCES [dbo].[AdhocTask] ([AdhocTaskId]),
    CONSTRAINT [FK_UserOtherTask_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_UserOtherTask_Program] FOREIGN KEY ([ProgramId]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
CREATE NONCLUSTERED INDEX [IX_UserOtherTask_PatientUserID]
    ON [dbo].[PatientOtherTask]([PatientId] ASC, [ProgramId] ASC, [AdhocTaskId] ASC, [PatientProgramID] ASC)
    INCLUDE([DateTaken], [IsProgramTask]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Update_UserOtherTask]  
Description:                       
When   Who    Action   
31-10-2012 Rathnam Created                       
---------------------------------------------------------------------        
24-Dec-2012 Mohan Modified  'Closed Complete' to  Pending in TaskStatusText    
25-July-2013 Rathnam dropped the column PatientOthertaskid from task table
---------------------------------------------------------------------        
*/
CREATE TRIGGER [dbo].[tr_Update_UserOtherTask] ON [dbo].[PatientOtherTask]
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @i_ScheduledDays INT

	SELECT @i_ScheduledDays = ScheduledDays
	FROM TaskType
	WHERE TasktypeId = [dbo].[ReturnTaskTypeID]('Other Tasks')

	IF 
		UPDATE (DateDue)

	BEGIN
		UPDATE Task
		SET TaskDueDate = INSERTED.DateDue
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
			,TaskStatusId = CASE 
				--WHEN DATEADD(DD,@i_ScheduledDays, INSERTED.DateDue) >= GETDATE() THEN  
				WHEN INSERTED.DateDue - @i_ScheduledDays > GETDATE()
					THEN (
							SELECT TaskStatusId
							FROM TaskStatus
							WHERE TaskStatusText = 'Scheduled'
							)
				ELSE (
						SELECT TaskStatusId
						FROM TaskStatus
						WHERE TaskStatusText = 'Open'
						)
				END
			,
			--AssignedCareProviderId = INSERTED.LastModifiedByUserId ,  
			ProgramID = INSERTED.ProgramID
		FROM INSERTED
		WHERE Task.PatientTaskID = INSERTED.PatientOtherTaskId
		    AND Task.PatientId = inserted.PatientId
			AND INSERTED.DateTaken IS NULL
			AND Task.TypeID = INSERTED.AdhocTaskId
			AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Other Tasks')
			AND Task.TaskStatusId IN (
				SELECT TaskStatusId FROM TaskStatus ts WHERE TaskStatusText IN ('Scheduled','Open')
				)
	END

	IF 
		UPDATE (DateTaken)
			OR

	UPDATE (StatusCode)

	BEGIN
		UPDATE Task
		SET TaskCompletedDate = INSERTED.DateTaken
			,Comments = INSERTED.Comments
			,TaskStatusId = CASE 
				WHEN INSERTED.DateTaken IS NOT NULL
					THEN (
							SELECT TaskStatusId
							FROM TaskStatus
							WHERE TaskStatusText = 'Closed Complete'
							)
				ELSE (
						SELECT TaskStatusId
						FROM TaskStatus
						WHERE TaskStatusText = 'Closed InComplete'
						)
				END
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
		--AssignedCareProviderId = INSERTED.LastModifiedByUserId,  
		FROM INSERTED
		WHERE Task.PatientTaskID = INSERTED.PatientOtherTaskId
			AND Task.PatientId = inserted.PatientId
			AND (
				INSERTED.DateTaken IS NOT NULL
				OR INSERTED.StatusCode = 'I'
				)
			AND Task.TypeID = INSERTED.AdhocTaskId
			AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Other Tasks')
			AND Task.TaskStatusId IN (
				SELECT TaskStatusId FROM TaskStatus ts WHERE TaskStatusText IN ('Scheduled','Open')
				)
	END
END

GO
/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Insert_UserOtherTask]
Description:  This trigger is used to wirte the tasks for Patient Adhoc tasks                   
When   Who    Action                      
29/Apr/2010  Rathnam  Created                      
---------------------------------------------------------------------      
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
---------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Insert_UserOtherTask] ON [dbo].[PatientOtherTask]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON

      DECLARE @i_ScheduledDays INT

      SELECT
          @i_ScheduledDays = ScheduledDays
      FROM
          TaskType
      WHERE
          TasktypeId = [dbo].[ReturnTaskTypeID]('Other Tasks')


      INSERT INTO
          TASK
          (
            PatientId
          ,TasktypeId
          ,TaskDueDate
          ,TaskStatusId
          ,PatientTaskID
          ,CreatedByUserId
          --,AssignedCareProviderId
          ,ProgramID
          ,TypeID
          ,IsProgramTask
          ,IsBatchProgram
          ,PatientADTID
          )
          SELECT
              INSERTED.PatientId
             ,[dbo].[ReturnTaskTypeID]('Other Tasks')
             ,INSERTED.DateDue
             ,CASE
                   WHEN INSERTED.DateDue - @i_ScheduledDays > GETDATE() THEN( SELECT
                                                                                  TaskStatusId
                                                                              FROM
                                                                                  TaskStatus
                                                                              WHERE
                                                                                  TaskStatusText = 'Scheduled' )
                   ELSE( SELECT
                             TaskStatusId
                         FROM
                             TaskStatus
                         WHERE
                             TaskStatusText = 'Open' )
              END
             ,INSERTED.PatientOtherTaskId
             ,INSERTED.CreatedByUserId
             --,INSERTED.CreatedByUserId
             --,INSERTED.CreatedByUserId
             ,INSERTED.ProgramId
             ,inserted.AdhocTaskId
             ,inserted.IsProgramTask
             ,case when inserted.IsProgramTask = 1 then 1 else 0 END
             ,(SELECT PatientADTID FROM PatientProgram pp WHERE pp.PatientProgramID = INSERTED.PatientProgramID)
          FROM
              INSERTED
          WHERE
              INSERTED.DateDue IS NOT NULL
              AND INSERTED.DateTaken IS NULL

END
