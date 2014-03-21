CREATE TABLE [dbo].[PatientHealthStatusScore] (
    [PatientHealthStatusId]  [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PatientID]              [dbo].[KeyID]            NOT NULL,
    [Score]                  DECIMAL (10, 2)          NULL,
    [ScoreText]              [dbo].[ShortDescription] NULL,
    [Comments]               VARCHAR (200)            NULL,
    [DateDetermined]         [dbo].[UserDate]         NULL,
    [HealthStatusScoreId]    [dbo].[KeyID]            NULL,
    [DateDue]                [dbo].[UserDate]         NOT NULL,
    [StatusCode]             [dbo].[StatusCode]       CONSTRAINT [DF_PatientHealthStatusScore_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]        [dbo].[KeyID]            NOT NULL,
    [CreatedDate]            [dbo].[UserDate]         CONSTRAINT [DF_PatientHealthStatusScore_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]            NULL,
    [LastModifiedDate]       [dbo].[UserDate]         NULL,
    [IsAdhoc]                BIT                      NULL,
    [AssignedCareProviderId] INT                      NULL,
    [ProgramID]              INT                      NULL,
    CONSTRAINT [PK_PatientHealthStatusScore] PRIMARY KEY CLUSTERED ([PatientHealthStatusId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientHealthStatusScore_AssignedCareProvider] FOREIGN KEY ([AssignedCareProviderId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientHealthStatusScore_HealthStatusScoreType] FOREIGN KEY ([HealthStatusScoreId]) REFERENCES [dbo].[HealthStatusScoreType] ([HealthStatusScoreId]),
    CONSTRAINT [FK_PatientHealthStatusScore_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientHealthStatusScore_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientHealthStatusScore_PatientID_HealthStatusScoreId_StatusCode_DateDetermined]
    ON [dbo].[PatientHealthStatusScore]([PatientID] ASC, [HealthStatusScoreId] ASC, [StatusCode] ASC, [DateDetermined] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientHealthStatusScore_PatientID_HealthStatusScoreId]
    ON [dbo].[PatientHealthStatusScore]([PatientID] ASC, [HealthStatusScoreId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO



/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Insert_UserHealthStatusScore]   
Description:                       
When   Who    Action                        
---------------------------------------------------------------------        
29/Apr/2010  ADITYA   Created
29-Jun-2010 Rathnam Enhanced                        
20-Aug-2010 NagaBabu Added TRIM function 
24-Feb-2011 NagaBabu Replaced  'Type: ' by ': ' in First select Statement  
16-May-2011 Rathnam added AssignedCareProviderId column to the task table   
02-Dec-2011 NagaBabu Added UserId field in INSERT statement of Task table  
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been INSERTing by INSERTED.LastModifiedByUserId          
10-Feb-2012 Rathnam added Isadhoc column to the task table
28-June-2012 Rathnam added Typeid column to the task table
---------------------------------------------------------------------        
*/

CREATE TRIGGER [dbo].[tr_Insert_PatientHealthStatusScore] ON [dbo].[PatientHealthStatusScore]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON
      DECLARE @ScheduledDays INT
      SELECT
          @ScheduledDays = ScheduledDays
      FROM
          TaskType
      WHERE
          TasktypeId = [dbo].[ReturnTaskTypeID]('Schedule Health Risk Score')

      IF EXISTS ( SELECT
                      1
                  FROM
                      INSERTED
                  WHERE
                      INSERTED.DateDetermined IS NULL )

         INSERT INTO
             TASK
             (
               PatientId ,
               TasktypeId ,
               TaskDueDate ,
               TaskStatusId ,
               CreatedByUserId ,
               PatientHealthStatusId ,
               AssignedCareProviderId ,
               Isadhoc,
               TypeID
             )
             SELECT
                 INSERTED.PatientID ,
                 [dbo].[ReturnTaskTypeID]('Schedule Health Risk Score') ,
                 INSERTED.DateDue ,
                 CASE
                      WHEN INSERTED.DateDue - @ScheduledDays > GETDATE() THEN( SELECT
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
                 INSERTED.PatientHealthStatusId ,
                 INSERTED.AssignedCareProviderId ,
                 INSERTED.IsAdhoc ,
                 INSERTED.HealthStatusScoreId
             FROM
                 INSERTED
             WHERE
                 INSERTED.DateDetermined IS NULL
                 

			
			
				

                 
                 

END






GO


/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Update_UserHealthStatusScore]                    
Description:                     
When   Who    Action                      
---------------------------------------------------------------------      
28/Apr/2010  Balla Kalyan  Created   
29-Jun-2010 Rathnam Enhanced                     
20-Aug-2010 NagaBabu Added TRIM function              
1-Oct-10 Pramod Included condition DateDetermined IS NOT NULL  
24-Feb-2011 NagaBabu Replaced  'Type: ' by ': ' in First select Statement   
16-May-2011 Rathnam added AssignedCareProviderId column to the task table    
02-Dec-2011 NagaBabu Added CASE statement for UserId field in Task table  
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been updating by INSERTED.LastModifiedByUserId  
17-May-2012 NagaBabu Added where clause for UPDATE(DUEDATE) condition to Task table update Statement 
24-Dec-2012 Mohan Modified  'Closed Complete' to  Pending in TaskStatusText        
---------------------------------------------------------------------      
*/  
CREATE TRIGGER [dbo].[tr_Update_PatientHealthStatusScore] ON [dbo].[PatientHealthStatusScore]  
       AFTER UPDATE  
AS  
BEGIN  
      SET NOCOUNT ON  
      
               UPDATE  
                   TASK  
               SET  
                   TaskCompletedDate = GETDATE() ,  
                   Comments = NULL ,  
                   LastModifiedByUserId = INSERTED.LastModifiedByUserId ,  
        LastModifiedDate = INSERTED.LastModifiedDate ,  
                   TaskStatusID = ( SELECT  
                                          TaskStatusId  
                                    FROM  
                                          TaskStatus  
                                    WHERE TaskStatusText = 'Closed Complete'  
                                   ),  
                   AssignedCareProviderId = INSERTED.AssignedCareProviderId 
               FROM  
                   INSERTED  
               INNER JOIN TASK  
                   ON TASK.PatientID = INSERTED.PatientID  
                  AND TASK.PatientHealthStatusId = INSERTED.PatientHealthStatusId  
                  AND INSERTED.DateDetermined IS NOT NULL  
               --INNER JOIN Users   
               --    ON Users.UserId = INSERTED.UserId     
           
  
      DECLARE @ScheduledDays INT  
      SELECT  
          @ScheduledDays = ScheduledDays  
      FROM  
          TaskType  
      WHERE  
          TasktypeId = [dbo].[ReturnTaskTypeID]('Schedule Health Risk Score')  
  
      IF ( UPDATE(DateDue) )  
  
         BEGIN  
               UPDATE  
                   TASK  
               SET  
                   TaskDueDate = INSERTED.DateDue ,  
                   LastModifiedByUserId = INSERTED.LastModifiedByUserId ,  
                   LastModifiedDate = INSERTED.LastModifiedDate ,  
                   TaskStatusID = CASE  
                                       WHEN INSERTED.DateDue - @ScheduledDays > GETDATE() THEN  
                                       ( SELECT  
                                             TaskStatusId  
                                         FROM  
                                             TaskStatus  
                                         WHERE  
                                             TaskStatusText = 'Scheduled' )  
                                       ELSE  
                                       ( SELECT  
                                             TaskStatusId  
                                         FROM  
                                             TaskStatus  
                                         WHERE  
                                             TaskStatusText = 'Open' )  
                                  END,
                   AssignedCareProviderId = INSERTED.AssignedCareProviderId  
               FROM  
                   INSERTED  
               INNER JOIN TASK  
                   ON TASK.PatientHealthStatusId = INSERTED.PatientHealthStatusId  
                  AND TASK.PatientID = INSERTED.PatientID  
                  AND INSERTED.DateDetermined IS NULL  
                  AND Task.TaskStatusId IN (1,2)         
         END  
  
      IF EXISTS ( SELECT  
                      1  
                  FROM  
                      INSERTED  
                  INNER JOIN DELETED  
                      ON DELETED.HealthStatusScoreId = INSERTED.HealthStatusScoreId  
                  WHERE  
                      DELETED.StatusCode = 'A'  
                      AND INSERTED.StatusCode = 'I' )  
         BEGIN  
  
               UPDATE  
                   TASK  
               SET  
                   TaskStatusID = ( SELECT  
                                        TaskStatusId  
                                    FROM  
                                        TaskStatus  
                                    WHERE  
                                        TaskStatusText = 'Closed Incomplete'  
                                   ),  
                    LastModifiedByUserId = INSERTED.LastModifiedByUserId ,  
                 LastModifiedDate = INSERTED.LastModifiedDate,  
                   AssignedCareProviderId = INSERTED.AssignedCareProviderId 
               FROM  
                   INSERTED  
               INNER JOIN TASK  
                   ON TASK.PatientID = INSERTED.PatientID  
                  AND TASK.PatientHealthStatusId = INSERTED.PatientHealthStatusId  
               WHERE INSERTED.StatusCode = 'I'  
  
         END  
         
			
  
  
END  


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The score derived for a specific Health risk evaluation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the UserHealthStatusScore table - identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'PatientHealthStatusId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table - identifies the patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'PatientID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The score in numeric format', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'Score';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The score in text format', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'ScoreText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the test was given', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'DateDetermined';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key  to the HealthStatusScoreType table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'HealthStatusScoreId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Due Date for determining the Health Risk Score', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'DateDue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthStatusScore', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

