CREATE TABLE [dbo].[PatientPhoneCallLog] (
    [PatientPhoneCallId]   [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [PatientId]            [dbo].[KeyID]      NOT NULL,
    [CallDate]             DATETIME           NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_PatientPhoneCallLog_StatusCode] DEFAULT ('A') NOT NULL,
    [Comments]             VARCHAR (1000)     NOT NULL,
    [CareProviderUserId]   [dbo].[KeyID]      NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_PatientPhoneCallLog_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    [DueDate]              DATETIME           NULL,
    [IsAdhoc]              BIT                NULL,
    CONSTRAINT [PK_PatientPhoneCallLog] PRIMARY KEY CLUSTERED ([PatientPhoneCallId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientPhoneCallLog_CareProviderByUser] FOREIGN KEY ([CareProviderUserId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientPhoneCallLog_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO

/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Update_UserPhoneCallLog]   
Description:                       
When   Who    Action                        
---------------------------------------------------------------------        
28-Jun-2010  Rathnam   Created                        
11-Oct-2010  Rathnam   Added closed incomplete case statement according to document.      
16-May-2011 Rathnam added AssignedCareProviderId column to the task table    
02-Dec-2011 NagaBabu Added CASE statement for UserId field in Task table   
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been updating by INSERTED.LastModifiedByUserId   
17-May-2012 NagaBabu Added where clause for UPDATE(DUEDATE) condition to Task table update Statement    
25-May-2012 Sivakrishna Added where Condition(Taskstatusid in(1,2) to restrict the update TaskCompleted date to Task table update Statement for Pending For Claims and closed incomplete  
24-Dec-2012 Mohan Modified  'Closed Complete' to  Pending in TaskStatusText
25-July-2013 Rathnam dropped the colum patientcalllogid from task table
---------------------------------------------------------------------        
*/
CREATE TRIGGER [dbo].[tr_Update_PatientPhoneCallLog] ON [dbo].[PatientPhoneCallLog]
AFTER UPDATE
AS
BEGIN
	DECLARE @i_ScheduledDays INT

	SELECT @i_ScheduledDays = ScheduledDays
	FROM TaskType
	WHERE TasktypeId = [dbo].[ReturnTaskTypeID]('Schedule Phone Call')

	IF (
			UPDATE (DueDate)
			)
	BEGIN
		UPDATE TASK
		SET TaskDueDate = INSERTED.DueDate
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
			,TaskStatusID = CASE 
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
		--AssignedCareProviderId = INSERTED.LastModifiedByUserId 
		FROM INSERTED
		WHERE TASK.PatientId = INSERTED.PatientId
			AND TASK.PatientTaskID = INSERTED.PatientPhoneCallId
			AND TASK.TypeID = inserted.PatientPhoneCallId
			AND INSERTED.CallDate IS NULL
			AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Schedule Phone Call')
			AND Task.TaskStatusId IN (
				1
				,2
				)
	END

	IF EXISTS (
			SELECT 1
			FROM INSERTED
			WHERE CallDate IS NOT NULL
				OR StatusCode = 'I'
			)
		UPDATE TASK
		SET TaskCompletedDate = GETDATE()
			,Comments = NULL
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
			,TaskStatusID = CASE 
				WHEN INSERTED.CallDate IS NOT NULL
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
			,AssignedCareProviderId = INSERTED.LastModifiedByUserId
		FROM INSERTED
		WHERE TASK.PatientId = INSERTED.PatientId
			AND TASK.PatientTaskID = INSERTED.PatientPhoneCallId
			AND Task.TaskStatusId IN (
				1
				,2
				)
			AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Schedule Phone Call')
END

GO
/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Insert_UserPhoneCallLog]   
Description:                       
When   Who    Action                        
---------------------------------------------------------------------        
28-Jun-2010 Rathnam Created   
16-May-2011 Rathnam added AssignedCareProviderId column to the task table   
02-Dec-2011 NagaBabu Added UserId field in INSERT statement of Task table 
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been INSERTing by INSERTED.LastModifiedByUserId          
10-Feb-2012 Rathnam added isadhoc column to the task table 
27-June-2012 Rathnam added  TypeID, CommunicationType,  CommunicationCount, CommunicationTemplateID, TaskTypeCommunicationID, CommunicationSequence, CommunicationTypeID column to the task table
---------------------------------------------------------------------        
*/
CREATE TRIGGER [dbo].[tr_Insert_PatientPhoneCallLog] ON [dbo].[PatientPhoneCallLog]
       AFTER INSERT
AS
BEGIN

	  DECLARE @i_ScheduledDays INT
      SELECT
          @i_ScheduledDays = ScheduledDays
      FROM
          TaskType
      WHERE
          TasktypeId = [dbo].[ReturnTaskTypeID]('Schedule Phone Call')
      IF EXISTS ( SELECT
                      1
                  FROM
                      INSERTED
                  WHERE
                      INSERTED.Calldate IS NULL )

         INSERT INTO
             TASK
             (
               PatientId ,
               TasktypeId ,
               TaskDueDate ,
               TaskStatusId ,
               CreatedByUserId ,
               PatientTaskID ,
               AssignedCareProviderId ,
               Isadhoc,
               TypeID
             )
             SELECT
                 INSERTED.PatientId ,
                 [dbo].[ReturnTaskTypeID]('Schedule Phone Call') ,
                 INSERTED.Duedate ,
                 CASE
                      WHEN INSERTED.Duedate - @i_ScheduledDays > GETDATE() 
						THEN ( SELECT TaskStatusId
                                 FROM TaskStatus
                                WHERE TaskStatusText = 'Scheduled' 
                             )
                       ELSE ( SELECT TaskStatusId
                                FROM TaskStatus
                               WHERE TaskStatusText = 'Open'
                            )
                 END ,
                 INSERTED.CreatedByUserId ,
                 INSERTED.PatientPhoneCallId ,
                 INSERTED.CreatedByUserId ,
                 INSERTED.IsAdhoc,
                 INSERTED.PatientPhoneCallId 
             FROM
                 INSERTED
             WHERE
                 INSERTED.Calldate IS NULL
             AND DueDate IS NOT NULL    
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Log of Phone calls to and from a patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserPhoneCallLog table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'PatientPhoneCallId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Patient user Id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'PatientId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the Call took place', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'CallDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Care provider User ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'CareProviderUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date due for a scheduled phone call', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhoneCallLog', @level2type = N'COLUMN', @level2name = N'DueDate';

