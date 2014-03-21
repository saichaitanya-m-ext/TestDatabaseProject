CREATE TABLE [dbo].[PatientEducationMaterial] (
    [PatientEducationMaterialID] [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PatientID]                  [dbo].[KeyID]           NOT NULL,
    [PatientProgramID]           [dbo].[KeyID]           NULL,
    [EducationMaterialID]        INT                     NULL,
    [DueDate]                    [dbo].[UserDate]        NOT NULL,
    [IsPatientViewable]          [dbo].[IsIndicator]     CONSTRAINT [DF_PatientEducationMaterial_IsPatientViewable] DEFAULT ((0)) NOT NULL,
    [Comments]                   [dbo].[LongDescription] NOT NULL,
    [StatusCode]                 [dbo].[StatusCode]      CONSTRAINT [DF_PatientEducationMaterial_StatusCode] DEFAULT ('A') NOT NULL,
    [ProviderID]                 [dbo].[KeyID]           NULL,
    [ProgramID]                  INT                     NULL,
    [DateSent]                   [dbo].[UserDate]        NULL,
    [IsAdhoc]                    BIT                     NULL,
    [IsProgramTask]              BIT                     NULL,
    [CreatedByUserId]            [dbo].[KeyID]           NOT NULL,
    [CreatedDate]                [dbo].[UserDate]        CONSTRAINT [DF_PatientEducationMaterial_CreatetdDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]       [dbo].[KeyID]           NULL,
    [LastModifiedDate]           [dbo].[UserDate]        NULL,
    CONSTRAINT [PK_PatientEducationMaterial] PRIMARY KEY CLUSTERED ([PatientEducationMaterialID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientEducationMaterial_EducationMaterial] FOREIGN KEY ([EducationMaterialID]) REFERENCES [dbo].[EducationMaterial] ([EducationMaterialID]),
    CONSTRAINT [FK_PatientEducationMaterial_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientEducationMaterial_PatientProgram] FOREIGN KEY ([PatientProgramID]) REFERENCES [dbo].[PatientProgram] ([PatientProgramID]),
    CONSTRAINT [FK_PatientEducationMaterial_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId]),
    CONSTRAINT [FK_PatientEducationMaterial_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientEducationMaterial_PatientUserID]
    ON [dbo].[PatientEducationMaterial]([PatientID] ASC, [PatientEducationMaterialID] ASC, [StatusCode] ASC, [IsPatientViewable] ASC, [ProgramID] ASC, [EducationMaterialID] ASC, [ProviderID] ASC)
    INCLUDE([DueDate], [Comments], [DateSent], [CreatedByUserId], [CreatedDate], [LastModifiedByUserId], [LastModifiedDate]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientEducationalMaterial]
    ON [dbo].[PatientEducationMaterial]([PatientID] ASC, [ProgramID] ASC)
    INCLUDE([PatientEducationMaterialID], [IsProgramTask]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PatientEducationMaterial]
    ON [dbo].[PatientEducationMaterial]([PatientID] ASC, [EducationMaterialID] ASC, [DueDate] ASC, [PatientProgramID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Insert_PatientEducationMaterial]   
Description:                       
When   Who    Action                        
---------------------------------------------------------------------        
24/May/2011  Rathnam   Created   
02-Dec-2011 NagaBabu Replaced NULL by INSERTED.CreatedByUserId for UserId field in Task table 
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been INSERTing by INSERTED.LastModifiedByUserId 				
10-Feb-2012 Rathnam added Isadhoc task to the task table
27-June-2012 Rathnam added  TypeID, CommunicationType,  CommunicationCount, CommunicationTemplateID, TaskTypeCommunicationID, CommunicationSequence, CommunicationTypeID column to the task table
25-June-2013 Rathnam dropped the column [PatientEducationMaterialid] from task table
---------------------------------------------------------------------        
*/
CREATE TRIGGER [dbo].[tr_Insert_PatientEducationMaterial] ON [dbo].[PatientEducationMaterial]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON
      DECLARE @ScheduledDays INT,

              @i_TaskTypeID int
   
      SELECT @i_TaskTypeID = [dbo].[ReturnTaskTypeID]('Patient Education Material')
              
      SELECT
          @ScheduledDays = ScheduledDays
      FROM
          TaskType
      WHERE
          TasktypeId = @i_TaskTypeID

      INSERT INTO
          TASK
          (
            PatientId ,
            TasktypeId ,
            TaskDueDate ,
            TaskStatusId ,
            CreatedByUserId ,
            AssignedCareProviderId ,
            PatientTaskID,
            Isadhoc,
            TypeID,
            ProgramID,
            IsProgramTask,
            IsBatchProgram,
            PatientADTId
          )
          SELECT
              INSERTED.PatientId ,
              @i_TaskTypeID,
              INSERTED.DueDate ,
              CASE   
                   WHEN INSERTED.DueDate - @ScheduledDays > GETDATE() THEN( SELECT
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
              END ,
              INSERTED.CreatedByUserId ,
              INSERTED.ProviderID ,
              INSERTED.PatientEducationMaterialID ,
              inserted.IsAdhoc,
              INSERTED.EducationMaterialID,
              inserted.ProgramID,
              inserted.IsProgramTask,
              CASE WHEN IsProgramTask = 1 THEN 1 ELSE NULL END,
              (SELECT PatientADTID FROM PatientProgram pp WHERE pp.PatientProgramID = INSERTED.PatientProgramID)	
          FROM
              INSERTED
          WHERE
              INSERTED.DueDate IS NOT NULL
          AND INSERTED.DateSent IS NULL    

END


GO
/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Update_PatientEducationMaterial]   
Description:                       
When   Who    Action                        
---------------------------------------------------------------------        
24/May/2011  Rathnam   Created                        
07-Jun-2011 rathnam added DiseaseId column to the task table   
02-Dec-2011 NagaBabu Added CASE statement for UserId field in Task table                         
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been updating by INSERTED.LastModifiedByUserId   
17-May-2012 NagaBabu Added where clause for UPDATE(DUEDATE) condition to Task table update Statement    
25-May-2012 Sivakrishna Added where Condition(Taskstatusid in(1,2) to restrict the update TaskCompleted date to Task table update Statement for closed complete and closed incomplete  
24-Dec-2012 Mohan Modified  'Closed Complete' to  Pending in TaskStatusText   
25-July-2013 Rathnam dropped the column PatientEducationMaterialid from task table
---------------------------------------------------------------------        
*/
CREATE TRIGGER [dbo].[tr_Update_PatientEducationMaterial] ON [dbo].[PatientEducationMaterial]
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @i_ScheduledDays INT

	SELECT @i_ScheduledDays = ScheduledDays
	FROM TaskType
	WHERE TasktypeId = [dbo].[ReturnTaskTypeID]('Patient Education Material')

	IF 
		UPDATE (DueDate)

	BEGIN
		UPDATE Task
		SET TaskDueDate = INSERTED.DueDate
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
			,TaskStatusId = CASE 
				WHEN INSERTED.DueDate - @i_ScheduledDays > GETDATE()
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
			,AssignedCareProviderId = INSERTED.ProviderID
		FROM INSERTED
		WHERE Task.PatientTaskID = INSERTED.PatientEducationMaterialID
			AND Task.PatientId = INSERTED.PatientID
			AND INSERTED.DateSent IS NULL
			AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Patient Education Material')
			AND Task.TypeID = inserted.EducationMaterialID
			AND Task.TaskStatusId IN (
				SELECT TaskStatusId FROM TaskStatus ts WHERE TaskStatusText IN ('Scheduled','Open')
				)
	END

	IF EXISTS (
			SELECT 1
			FROM INSERTED
			WHERE DateSent IS NOT NULL
				OR StatusCode = 'I'
				OR IsPatientViewable = 1
			)
	BEGIN
		UPDATE TASK
		SET TaskCompletedDate = INSERTED.LastModifiedDate
			,Comments = NULL
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
			,TaskStatusId = CASE 
				WHEN INSERTED.DateSent IS NOT NULL
					THEN (
							SELECT TaskStatusId
							FROM TaskStatus
							WHERE TaskStatusText = 'Closed Complete'
							)
				ELSE (
						SELECT TaskStatusId
						FROM TaskStatus
						WHERE TaskStatusText = 'Closed Incomplete'
						)
				END
			,AssignedCareProviderId = INSERTED.ProviderID
		FROM INSERTED
		WHERE TASK.PatientId = INSERTED.PatientID
			AND Task.PatientTaskID = INSERTED.PatientEducationMaterialID
			AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Patient Education Material')
			AND Task.TypeID = inserted.EducationMaterialID
			AND (
				DateSent IS NOT NULL
				OR StatusCode = 'I'
				OR IsPatientViewable = 1
				)
			AND Task.TaskStatusId IN (
				SELECT TaskStatusId FROM TaskStatus ts WHERE TaskStatusText IN ('Scheduled','Open')
				)
	END
END

GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientEducationMaterial', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientEducationMaterial', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientEducationMaterial', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientEducationMaterial', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

