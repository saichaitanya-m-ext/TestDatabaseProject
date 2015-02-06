CREATE TABLE [dbo].[PatientCommunication] (
    [PatientCommunicationId]         [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [PatientId]                      [dbo].[KeyID]       NOT NULL,
    [CommunicationCohortId]          [dbo].[KeyID]       NULL,
    [SentByUserID]                   [dbo].[KeyID]       NULL,
    [CommunicationTypeId]            [dbo].[KeyID]       NULL,
    [CommunicationText]              NVARCHAR (MAX)      NULL,
    [IsSentIndicator]                [dbo].[IsIndicator] NOT NULL,
    [SubjectText]                    VARCHAR (200)       NULL,
    [SenderEmailAddress]             VARCHAR (256)       NULL,
    [CreatedByUserId]                [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                    [dbo].[UserDate]    CONSTRAINT [DF_PatientCommunication_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [UserMessageId]                  [dbo].[KeyID]       NULL,
    [DateScheduled]                  [dbo].[UserDate]    NULL,
    [DateSent]                       [dbo].[UserDate]    NULL,
    [DateDue]                        [dbo].[UserDate]    NULL,
    [CommunicationId]                [dbo].[KeyID]       NULL,
    [LastModifiedByUserId]           [dbo].[KeyID]       NULL,
    [LastModifiedDate]               [dbo].[UserDate]    NULL,
    [dbmailReferenceId]              INT                 NULL,
    [eMailDeliveryState]             VARCHAR (20)        NULL,
    [CommunicationTemplateId]        [dbo].[KeyID]       NULL,
    [StatusCode]                     [dbo].[StatusCode]  CONSTRAINT [DF_PatientCommunication_Status] DEFAULT ('A') NOT NULL,
    [CommunicationState]             VARCHAR (20)        NULL,
    [MergedIntoUserCommunicationID]  INT                 NULL,
    [IsMergedLetter]                 [dbo].[IsIndicator] CONSTRAINT [DF_PatientCommunication_IsMergedLetter] DEFAULT ((0)) NULL,
    [TaskAttemptsCommunicationLogId] [dbo].[KeyID]       NULL,
    [IsAdhoc]                        BIT                 NULL,
    [ProgramID]                      [dbo].[KeyID]       NULL,
    [IsEnrollment]                   BIT                 CONSTRAINT [DF_PatientCommunication_IsEnrollment] DEFAULT ((0)) NULL,
    [AssignedCareProviderId]         [dbo].[KeyID]       NULL,
    CONSTRAINT [PK_PatientCommunication] PRIMARY KEY CLUSTERED ([PatientCommunicationId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientCommunication_AssignedCareProvider] FOREIGN KEY ([AssignedCareProviderId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientCommunication_Communication] FOREIGN KEY ([CommunicationId]) REFERENCES [dbo].[Communication] ([CommunicationId]),
    CONSTRAINT [FK_PatientCommunication_CommunicationTemplate] FOREIGN KEY ([CommunicationTemplateId]) REFERENCES [dbo].[CommunicationTemplate] ([CommunicationTemplateId]),
    CONSTRAINT [FK_PatientCommunication_CommunicationType] FOREIGN KEY ([CommunicationTypeId]) REFERENCES [dbo].[CommunicationType] ([CommunicationTypeId]),
    CONSTRAINT [FK_PatientCommunication_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientCommunication_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId]),
    CONSTRAINT [FK_PatientCommunication_SentByUser] FOREIGN KEY ([SentByUserID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientCommunication_TaskAttemptsCommunicationLog] FOREIGN KEY ([TaskAttemptsCommunicationLogId]) REFERENCES [dbo].[TaskAttemptsCommunicationLog] ([TaskAttemptsCommunicationLogId]),
    CONSTRAINT [FK_PatientCommunication_UserMessages] FOREIGN KEY ([UserMessageId]) REFERENCES [dbo].[UserMessages] ([UserMessageId])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientCommunication_CommunicationTypeIdStatusCodeCommunicationState]
    ON [dbo].[PatientCommunication]([CommunicationTypeId] ASC, [StatusCode] ASC, [CommunicationState] ASC)
    INCLUDE([PatientCommunicationId], [PatientId], [CommunicationText], [SubjectText], [CommunicationId]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientCommunication_UserIdTemplateIdStateStatusCode]
    ON [dbo].[PatientCommunication]([PatientId] ASC)
    INCLUDE([CommunicationTemplateId], [StatusCode], [CommunicationState]) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientCommunication_CommunicationState]
    ON [dbo].[PatientCommunication]([CommunicationState] ASC)
    INCLUDE([PatientId], [CommunicationId]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [Ix_PatientCommunication_CommunicationId]
    ON [dbo].[PatientCommunication]([CommunicationId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [Ix_PatientCommunication_UserID]
    ON [dbo].[PatientCommunication]([PatientId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Insert_UserCommunication]
Description:                   
When   Who    Action                    
---------------------------------------------------------------------    
28/Apr/2010  Balla Kalyan  Created                    
20-Aug-2010  Rathnam added Trimfunctions  
12-Oct-2010  Rathnam added case statement for the column Taskstatusid. 
24-Feb-2011 NagaBabu Joined CommunicationType table to get CommunicationType insteed of getting CommunicationTypeid          
16-May-2011 Rathnam added AssignedCareProviderId column to the task table
02-Dec-2011 NagaBabu Added UserId field in INSERT statement of Task table 
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been INSERTing by INSERTED.LastModifiedByUserId     
10-Feb-2012 Rathnam added IsAdhoc column to the task table
28-June-2012 Rathnam added Typeid column to the task table
25-July-2013 Rathnam dropped the column Patientcommunicationid from task table
---------------------------------------------------------------------    
*/
CREATE TRIGGER [dbo].[tr_Insert_PatientCommunication] ON [dbo].[PatientCommunication]
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
          TasktypeId = [dbo].[ReturnTaskTypeID]('Communications')


      INSERT INTO
          Task
          (
            PatientId
          ,TaskTypeId
          ,TaskDueDate
          ,TaskStatusId
          ,CreatedByUserId
          ,PatientTaskID
          ,AssignedCareProviderId
          ,Isadhoc
          ,TypeID
          ,ProgramID
          ,IsEnrollment
          ,CommunicationTemplateID
          )
          SELECT
              INSERTED.PatientId
             ,dbo.ReturnTaskTypeID('Communications')
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
             ,INSERTED.CreatedByUserId
             ,INSERTED.PatientCommunicationId
             ,INSERTED.AssignedCareProviderId
             ,INSERTED.IsAdhoc
             ,inserted.CommunicationTypeId
             ,inserted.ProgramID
             ,inserted.IsEnrollment
             ,inserted.CommunicationTemplateId
          FROM
              INSERTED
          WHERE
              INSERTED.DateSent IS NULL
              AND INSERTED.StatusCode = 'A'
END



GO

/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Update_UserCommunication]  
Description:                     
When   Who    Action                      
---------------------------------------------------------------------      
28/Apr/2010  Balla Kalyan  Created                      
23/Jun/10 Pramod Removed tasktype from the join as it is not required  
20-Aug-2010 Rathnam Trim functions added.  
1-Oct-10 Pramod Included INSERTED.DateSent IS NULL condition to the update query  
11-Oct-10 Rathnam modified case statement WHEN INSERTED.DateDue - @i_ScheduledDays > GETDATE()  
                  instead of using WHEN Task.DateDue   
24-Feb-2011 NagaBabu Joined CommunicationType table to get CommunicationType insteed of getting CommunicationTypeid            
16-May-2011 Rathnam added AssignedCareProviderId column to the task table    
02-Dec-2011 NagaBabu Added CASE statement for UserId field in Task table  
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been updating by INSERTED.LastModifiedByUserId  
17-May-2012 NagaBabu Added where clause for UPDATE(DUEDATE) condition to Task table update Statement    
25-May-2012 Sivakrishna Added where Condition(Taskstatusid in(1,2) to restrict the update TaskCompleted date for Pending For Claims and closed incomplete  
24-Dec-2012 Mohan Modified  'Closed Complete' to  Pending in TaskStatusText   
25-July-2013 Rathnam dropped the column patientcommunicationid from the task table
---------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Update_PatientCommunication] ON [dbo].[PatientCommunication]
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @i_ScheduledDays INT

	SELECT @i_ScheduledDays = ScheduledDays
	FROM TaskType
	WHERE TasktypeId = [dbo].[ReturnTaskTypeID]('Communications')

	IF (
			UPDATE (DateDue)
				AND EXISTS (
					SELECT 1
					FROM INSERTED
					WHERE INSERTED.DateSent IS NULL
					)
			)
	BEGIN
		UPDATE Task
		SET TaskDueDate = INSERTED.DateDue
			,TaskStatusId = CASE 
				--WHEN (Task.TaskDueDate - (GETDATE() + TaskType.ScheduledDays)) > 0 THEN  
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
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = GETDATE()
			,AssignedCareProviderId = INSERTED.AssignedCareProviderId
		FROM INSERTED
		WHERE INSERTED.PatientCommunicationId = Task.PatientTaskID
			AND INSERTED.DateSent IS NULL
			AND Task.TypeID = inserted.CommunicationTypeId
			AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Communications')
			AND INSERTED.DateSent IS NULL
			AND Task.TaskStatusId IN (
				1
				,2
				)
	END

	IF EXISTS (
			SELECT 1
			FROM INSERTED
			WHERE INSERTED.DateSent IS NOT NULL
				OR INSERTED.StatusCode = 'I'
			)
	BEGIN
		UPDATE Task
		SET TaskCompletedDate = INSERTED.DateSent
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
			,Comments = NULL
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = GETDATE()
			,AssignedCareProviderId = INSERTED.AssignedCareProviderId
		FROM INSERTED
		WHERE INSERTED.PatientCommunicationId = Task.PatientTaskID
			AND Task.TaskStatusId IN (
				1
				,2
				)
			AND (
				INSERTED.DateSent IS NOT NULL
				OR INSERTED.StatusCode = 'I'
				)
			AND Task.TypeID = inserted.CommunicationTypeId
			AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Communications')

		UPDATE PatientProgram
		SET EnrollmentStartDate = inserted.DateSent
			,StatusCode = CASE 
				WHEN inserted.DateSent IS NOT NULL
					THEN 'A'
				ELSE 'I'
				END
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = GETDATE()
		FROM inserted
		WHERE inserted.PatientId = PatientProgram.PatientID
			AND inserted.ProgramID = PatientProgram.ProgramId
			AND PatientProgram.IsEnrollConfirmationSent = 1
			AND PatientProgram.EnrollmentStartDate IS NULL
	END
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'List of Communication and their contents for patients', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserCommunication Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'PatientCommunicationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table - Patient User ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'PatientId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CommunicationCohorts table If populated this was generated by a mass communication', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'CommunicationCohortId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table - If populated this was sent by a manually generated communication', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'SentByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CommunicationType table - Identifies the Type of communication', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'CommunicationTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The body of the message', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'CommunicationText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag indicating is the message has been sent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'IsSentIndicator';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The subject line text if required', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'SubjectText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Email address of the person that sent the message', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'SenderEmailAddress';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Usermessages table Indicates the corresponding internal message', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'UserMessageId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the Communication is scheduled to be send', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'DateScheduled';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the Communication was sent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'DateSent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Due Date for the Communication', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'DateDue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the communication table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'CommunicationId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Communicationtemplate table identifies the template used in the message', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'CommunicationTemplateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code A = Active , I = Inactive', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunication', @level2type = N'COLUMN', @level2name = N'StatusCode';

