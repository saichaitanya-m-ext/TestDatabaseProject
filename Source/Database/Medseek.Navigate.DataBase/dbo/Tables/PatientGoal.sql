CREATE TABLE [dbo].[PatientGoal] (
    [PatientGoalId]          [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PatientId]              [dbo].[KeyID]            NULL,
    [Description]            [dbo].[LongDescription]  NULL,
    [DurationUnits]          [dbo].[Unit]             NOT NULL,
    [DurationTimeline]       SMALLINT                 NOT NULL,
    [ContactFrequencyUnits]  [dbo].[Unit]             NULL,
    [ContactFrequency]       SMALLINT                 NULL,
    [CommunicationTypeId]    [dbo].[KeyID]            NULL,
    [CreatedByUserId]        [dbo].[KeyID]            NULL,
    [CreatedDate]            [dbo].[UserDate]         CONSTRAINT [DF_PatientGoal_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]            NULL,
    [LastModifiedDate]       [dbo].[UserDate]         NULL,
    [CancellationReason]     [dbo].[ShortDescription] NULL,
    [StatusCode]             [dbo].[StatusCode]       CONSTRAINT [DF_PatientGoal_StatusCode] DEFAULT ('A') NOT NULL,
    [StartDate]              [dbo].[UserDate]         NOT NULL,
    [Comments]               [dbo].[LongDescription]  NULL,
    [LifeStyleGoalId]        [dbo].[KeyID]            NULL,
    [GoalCompletedDate]      [dbo].[UserDate]         NULL,
    [GoalStatus]             [dbo].[StatusCode]       CONSTRAINT [DF_PatientGoal_GoalStatus] DEFAULT ('I') NULL,
    [IsAdhoc]                [dbo].[IsIndicator]      NULL,
    [AssignedCareProviderId] [dbo].[KeyID]            NULL,
    [ProgramId]              INT                      NULL,
    [PatientProgramId]       [dbo].[KeyID]            NULL,
    CONSTRAINT [PK_PatientGoal] PRIMARY KEY CLUSTERED ([PatientGoalId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientGoal_AssignedCareProvider] FOREIGN KEY ([AssignedCareProviderId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientGoal_CommunicationType] FOREIGN KEY ([CommunicationTypeId]) REFERENCES [dbo].[CommunicationType] ([CommunicationTypeId]),
    CONSTRAINT [FK_PatientGoal_LifeStyleGoal] FOREIGN KEY ([LifeStyleGoalId]) REFERENCES [dbo].[LifeStyleGoals] ([LifeStyleGoalId]),
    CONSTRAINT [FK_PatientGoal_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientGoal_PatientProgramId] FOREIGN KEY ([PatientProgramId]) REFERENCES [dbo].[PatientProgram] ([PatientProgramID]),
    CONSTRAINT [FK_PatientGoal_Program] FOREIGN KEY ([ProgramId]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PatientGoal]
    ON [dbo].[PatientGoal]([PatientId] ASC, [StartDate] ASC, [LifeStyleGoalId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                  
----------------------------------------------------------------------------------
Procedure Name: [tr_Insert_PatientGoal]
Description   : 
Created By    :	NagaBabu 
Created Date  : 29-Feb-2012

----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
28-June-2012 Rathnam added Typeid column to the task table
25-July-2013 Rathnam dropped the column patientgoalid from task table
----------------------------------------------------------------------------------
*/
CREATE TRIGGER [dbo].[tr_Insert_PatientGoal] ON [dbo].[PatientGoal]
       FOR INSERT
AS
BEGIN
      DECLARE @i_ScheduledDays INT
      SELECT
          @i_ScheduledDays = ScheduledDays
      FROM
          TaskType
      WHERE
          TasktypeId = [dbo].[ReturnTaskTypeID]('Life Style Goal\Activity Follow Up')

      INSERT INTO
          TASK
          (
            PatientId
          ,TasktypeId
          ,TaskDueDate
          ,Comments
          ,TaskStatusId
          ,CreatedByUserId
          ,AssignedCareProviderId
          ,Isadhoc
          ,PatientTaskID
          ,TypeID
          ,ProgramID
          ,PatientADTId
          )
          SELECT
              INSERTED.PatientId
             ,[dbo].[ReturnTaskTypeID]('Life Style Goal\Activity Follow Up')
             ,INSERTED.StartDate
             ,INSERTED.Comments
             ,CASE
                   WHEN INSERTED.StartDate - @i_ScheduledDays > GETDATE() THEN( SELECT
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
             ,INSERTED.CreatedByUserId
             ,INSERTED.AssignedCareProviderId
             ,INSERTED.Isadhoc
             ,INSERTED.PatientGoalId
             ,inserted.LifeStyleGoalId
             ,Inserted.ProgramID
             ,(SELECT pp.PatientADTId FROM PatientProgram pp WHERE pp.PatientProgramID = INSERTED.PatientProgramId)
          FROM
              INSERTED
          WHERE
              INSERTED.StartDate IS NOT NULL
              AND INSERTED.GoalCompletedDate IS NULL
END


GO

/*                    
----------------------------------------------------------------------------------  
Procedure Name: [tr_Update_PatientGoal]  
Description   :   
Created By    : NagaBabu   
Created Date  : 29-Feb-2012  
----------------------------------------------------------------------------------  
Log History   :   
25-May-2012 Sivakrishna Added where Condition(Taskstatusid in(1,2) to restrict the update TaskCompleted date to Task table update Statement for closed complete and closed incomplete  
24-Dec-2012 Mohan Modified  'Closed Complete' to  Pending in TaskStatusText
*/
CREATE TRIGGER [dbo].[tr_Update_PatientGoal] ON [dbo].[PatientGoal]
FOR UPDATE
AS
BEGIN
	DECLARE @i_ScheduledDays INT

	SELECT @i_ScheduledDays = ScheduledDays
	FROM TaskType
	WHERE TasktypeId = [dbo].[ReturnTaskTypeID]('Life Style Goal\Activity Follow Up')

	IF 
		UPDATE (StartDate)

	BEGIN
		UPDATE Task
		SET TaskDueDate = INSERTED.StartDate
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
			,TaskStatusId = CASE 
				WHEN INSERTED.StartDate - @i_ScheduledDays > GETDATE()
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
		FROM INSERTED
		WHERE Task.PatientTaskID = INSERTED.PatientGoalId
			AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Life Style Goal\Activity Follow Up')
			AND Task.TypeID = INSERTED.LifeStyleGoalId
	END

	IF EXISTS (
			SELECT 1
			FROM INSERTED
			WHERE INSERTED.GoalCompletedDate IS NOT NULL
				OR INSERTED.StatusCode = 'I'
			)
	BEGIN
		UPDATE Task
		SET TaskCompletedDate = INSERTED.GoalCompletedDate
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
			,TaskStatusId = CASE 
				WHEN INSERTED.GoalCompletedDate IS NOT NULL
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
			,AssignedCareProviderId = INSERTED.AssignedCareProviderId
		FROM INSERTED
		WHERE Task.PatientTaskID = INSERTED.PatientGoalId
			AND Task.TaskStatusId IN (
				1
				,2
				)
			AND (
				INSERTED.GoalCompletedDate IS NOT NULL
				OR INSERTED.StatusCode = 'I'
				)
			AND Task.TypeID = inserted.LifeStyleGoalId
			AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Life Style Goal\Activity Follow Up')
	END
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A Medical related goal for a Patient(lose weight, Take Medication, Education, exercise)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the PatientGoal table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'PatientGoalId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table = defines the patients the goal was created for', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'PatientId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for PatientGoal table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'the direction date units  {D = Day, W = Week, M= Month, Q = 3 Months, Y = Year}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'DurationUnits';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Number of direction Units for the goal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'DurationTimeline';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The direction units for the follow up progress contacts  {D = Day, W = Week, M= Month, Q = 3 Months, Y = Year}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'ContactFrequencyUnits';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Number of direction units between each progress follow up contact', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'ContactFrequency';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Used to define the communication contact type for the follow up contacts for the goal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'CommunicationTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Feel for comment field to explain why the activity was canceled', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'CancellationReason';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Start date for the goal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'StartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoal', @level2type = N'COLUMN', @level2name = N'Comments';

