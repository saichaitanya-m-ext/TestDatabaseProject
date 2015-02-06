CREATE TABLE [dbo].[PatientProcedureGroupTask] (
    [PatientProcedureGroupTaskID] [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PatientID]                   [dbo].[KeyID]            NOT NULL,
    [PatientProgramID]            [dbo].[KeyID]            NULL,
    [CodeGroupingID]              [dbo].[KeyID]            NOT NULL,
    [DueDate]                     DATE                     NOT NULL,
    [ProcedureGroupCompletedDate] [dbo].[UserDate]         NULL,
    [ManagedPopulationID]         [dbo].[KeyID]            NOT NULL,
    [AssignedCareProviderId]      INT                      NOT NULL,
    [IsAdhoc]                     BIT                      NULL,
    [IsProgramTask]               BIT                      NULL,
    [Commments]                   [dbo].[ShortDescription] NULL,
    [StatusCode]                  [dbo].[StatusCode]       CONSTRAINT [DF_PatientProcedureGroup_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]             [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                 [dbo].[UserDate]         CONSTRAINT [DF_PatientProcedureGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]        [dbo].[KeyID]            NULL,
    [LastModifiedDate]            [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_PatientProcedureGroup] PRIMARY KEY CLUSTERED ([PatientProcedureGroupTaskID] ASC),
    CONSTRAINT [FK_PatientProcedureGroup_AssignedCareProvider] FOREIGN KEY ([AssignedCareProviderId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientProcedureGroup_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_PatientProcedureGroup_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientProcedureGroup_PatientProgram] FOREIGN KEY ([PatientProgramID]) REFERENCES [dbo].[PatientProgram] ([PatientProgramID]),
    CONSTRAINT [FK_PatientProcedureGroup_Program] FOREIGN KEY ([ManagedPopulationID]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PatientProcedureGroupTask]
    ON [dbo].[PatientProcedureGroupTask]([PatientID] ASC, [CodeGroupingID] ASC, [DueDate] ASC, [PatientProgramID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Insert_PatientProcedureGroupTask]                     
Description:                       
When   Who    Action                        
---------------------------------------------------------------------        
25-July-2013  Rathnam  Created    
---------------------------------------------------------------------        
*/
CREATE TRIGGER [dbo].[tr_Insert_PatientProcedureGroupTask] ON [dbo].[PatientProcedureGroupTask]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @ScheduledDays INT

	SELECT @ScheduledDays = ScheduledDays
	FROM TaskType
	WHERE TasktypeId = [dbo].[ReturnTaskTypeID]('Schedule Procedure')

	INSERT INTO TASK (
		PatientId
		,TasktypeId
		,TaskDueDate
		,TaskStatusId
		,PatientTaskID
		,CreatedByUserId
		,AssignedCareProviderId
		,ProgramID
		,IsAdhoc
		,TypeID
		,IsProgramTask
		,IsBatchProgram
		,PatientADTId
		)
	SELECT INSERTED.PatientId
		,[dbo].[ReturnTaskTypeID]('Schedule Procedure')
		,INSERTED.DueDate
		,CASE 
			--WHEN DATEADD(DD,@ScheduledDays, INSERTED.DueDate) >= GETDATE() THEN   
			WHEN CONVERT(DATETIME, INSERTED.DueDate) - @ScheduledDays > GETDATE()
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
		,INSERTED.PatientProcedureGroupTaskID
		,INSERTED.CreatedByUserId
		,INSERTED.AssignedCareProviderId
		,INSERTED.ManagedPopulationID
		,INSERTED.IsAdhoc
		,inserted.CodeGroupingID
		,inserted.IsProgramTask
		,CASE 
			WHEN inserted.IsProgramTask = 1
				THEN 1
			ELSE 0
			END
		,(SELECT PatientADTID FROM PatientProgram pp WHERE pp.PatientProgramID = INSERTED.PatientProgramID)	
	FROM INSERTED
	WHERE INSERTED.ProcedureGroupCompletedDate IS NULL
		AND INSERTED.DueDate IS NOT NULL
END

GO
/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Update_PatientProcedureGroupTask]                     
Description:                       
When   Who    Action                        
---------------------------------------------------------------------        
25-July-2013  Rathnam  Created                        
---------------------------------------------------------------------        
*/
CREATE TRIGGER [dbo].[tr_Update_PatientProcedureGroupTask] ON [dbo].[PatientProcedureGroupTask]
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @ScheduledDays INT

	SELECT @ScheduledDays = ScheduledDays
	FROM TaskType
	WHERE TasktypeId = [dbo].[ReturnTaskTypeID]('Schedule Procedure')

	IF 
		UPDATE (DueDate)

	BEGIN
		UPDATE Task
		SET TaskDueDate = INSERTED.DueDate
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
			,TaskStatusId = CASE 
				--WHEN DATEADD(DD,@ScheduledDays, INSERTED.DueDate) >= GETDATE() THEN   
				WHEN CONVERT(DATETIME, INSERTED.DueDate) - @ScheduledDays > GETDATE()
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
			,AssignedCareProviderId = INSERTED.AssignedCareProviderId
			,ProgramID = INSERTED.ManagedPopulationID
		FROM INSERTED
		WHERE INSERTED.PatientID = Task.PatientId
			AND INSERTED.PatientProcedureGroupTaskID = Task.PatientTaskID
			AND INSERTED.ProcedureGroupCompletedDate IS NULL
			AND Task.TaskStatusId IN (
				SELECT TaskStatusId FROM TaskStatus ts WHERE TaskStatusText IN ('Scheduled','Open')
				)
			AND Task.TaskTypeId = dbo.[ReturnTaskTypeID]('Schedule Procedure')
	END

	IF 
		UPDATE (ProcedureGroupCompletedDate)
			OR

	UPDATE (StatusCode)

	BEGIN
		UPDATE Task
		SET TaskCompletedDate = INSERTED.ProcedureGroupCompletedDate
			,Comments = INSERTED.Commments
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
			,TaskStatusId = CASE 
				WHEN INSERTED.ProcedureGroupCompletedDate IS NOT NULL
					THEN (
							SELECT TaskStatusId
							FROM TaskStatus
							WHERE TaskStatusText = 'Pending For Claims'
							)
				ELSE (
						SELECT TaskStatusId
						FROM TaskStatus
						WHERE TaskStatusText = 'Closed InComplete'
						)
				END
			,AssignedCareProviderId = INSERTED.AssignedCareProviderId
		FROM INSERTED
		WHERE INSERTED.PatientId = Task.PatientId
			AND INSERTED.PatientProcedureGroupTaskID = Task.PatientTaskID
			AND Task.TaskStatusId IN (
				SELECT TaskStatusId FROM TaskStatus ts WHERE TaskStatusText IN ('Scheduled','Open')
				)
			AND (
				INSERTED.ProcedureGroupCompletedDate IS NOT NULL
				OR INSERTED.StatusCode = 'I'
				)
			AND Task.TaskTypeId = dbo.[ReturnTaskTypeID]('Schedule Procedure')
	END
END
