CREATE TABLE [dbo].[PatientGoalProgressLog] (
    [PatientGoalProgressLogId] [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PatientGoalId]            [dbo].[KeyID]           NOT NULL,
    [PatientActivityId]        [dbo].[KeyID]           NOT NULL,
    [ProgressPercentage]       CHAR (1)                NULL,
    [FollowUpDate]             [dbo].[UserDate]        NULL,
    [FollowUpCompleteDate]     [dbo].[UserDate]        NULL,
    [Comments]                 [dbo].[LongDescription] NULL,
    [StatusCode]               [dbo].[StatusCode]      CONSTRAINT [DF_PatientGoalFollowUpLog_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]          [dbo].[KeyID]           NOT NULL,
    [CreatedDate]              [dbo].[UserDate]        CONSTRAINT [DF_PatientGoalFollowUpLog_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]     [dbo].[KeyID]           NULL,
    [LastModifiedDate]         [dbo].[UserDate]        NULL,
    [AttemptedContactDate]     [dbo].[UserDate]        NULL,
    [ActivityCompletedDate]    [dbo].[UserDate]        NULL,
    [IsAdhoc]                  BIT                     NULL,
    CONSTRAINT [PK_PatientGoalProgressLog] PRIMARY KEY CLUSTERED ([PatientGoalProgressLogId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientGoalProgressLog_PatientActivity] FOREIGN KEY ([PatientActivityId]) REFERENCES [dbo].[PatientActivity] ([PatientActivityId]),
    CONSTRAINT [FK_PatientGoalProgressLog_PatientGoal] FOREIGN KEY ([PatientGoalId]) REFERENCES [dbo].[PatientGoal] ([PatientGoalId])
);


GO
CREATE NONCLUSTERED INDEX [UQ_PatientGoalProgressLog_PatientGoalId]
    ON [dbo].[PatientGoalProgressLog]([PatientGoalId] ASC, [PatientActivityId] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
/*                          
---------------------------------------------------------------------          
Trigger Name: [dbo].[tr_Update_PatientGoalProgressLog]                       
Description:                         
When   Who    Action                          
---------------------------------------------------------------------          
20-Aug-2010 NagaBabu Added TRIM function    
11-Oct-2010 Rathnam added insert condition according to the document.                  
13-Oct-10 Pramod Modified the trigger to include exists clause for creating new goal record  
18-Oct-10 Pramod Modified the trigger to remove the percentage calculation  
20-Oct-2010 Rathnam added ActivityCompletedDate if cluase and update task record at the end.  
24-Feb-2011 NagaBabu Appended '%' to 'ProgressPercentage'value in first select   
16-May-2011 Rathnam added AssignedCareProviderId column to the task table   
02-Dec-2011 NagaBabu Added CASE statement for UserId field in Task table  
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been updating by INSERTED.LastModifiedByUserId  
24-Dec-2012 Mohan Modified  'Closed Complete' to  Pending in TaskStatusText
---------------------------------------------------------------------          
*/  
  
CREATE TRIGGER [dbo].[tr_Update_PatientGoalProgressLog] ON [dbo].[PatientGoalProgressLog]  
       AFTER UPDATE  
AS  
BEGIN  
      IF EXISTS ( SELECT  
                      1  
                  FROM  
                      INSERTED  
                  WHERE  
                      FollowUpCompleteDate IS NOT NULL  
                      OR StatusCode = 'I' )  
         UPDATE  
             Task  
         SET  
            TaskCompletedDate = INSERTED.FollowUpCompleteDate,  
            Comments = INSERTED.Comments,  
            LastModifiedByUserId = INSERTED.LastModifiedByUserId,  
            LastModifiedDate = GETDATE(),  
            TaskStatusId = CASE  
                                 WHEN INSERTED.FollowUpCompleteDate IS NOT NULL THEN  
                                 ( SELECT  
                                       TaskStatusId  
                                   FROM  
                                       TaskStatus  
                                   WHERE  
                                       TaskStatusText = 'Closed Complete' )  
                                 ELSE  
                                 ( SELECT  
                                       TaskStatusId  
                                   FROM  
                                       TaskStatus  
                                   WHERE  
                                       TaskStatusText = 'Closed Incomplete' )  
                            END,  
             AssignedCareProviderId = PatientGoal.AssignedCareProviderId 
         FROM  
             Task  
         INNER JOIN INSERTED  
             ON INSERTED.PatientGoalProgressLogId = Task.PatientGoalProgressLogId  
         INNER JOIN PatientActivity  
              ON PatientActivity.PatientActivityId = INSERTED.PatientActivityId  
         INNER JOIN PatientGoal  
              ON PatientActivity.PatientGoalId = PatientGoal.PatientGoalId  
      IF EXISTS ( SELECT  
                      1  
                  FROM  
                      PatientGoalProgressLog  
                  INNER JOIN INSERTED  
                  ON  PatientGoalProgressLog.PatientGoalId = INSERTED.PatientGoalId  
                  INNER JOIN DELETED  
                  ON  INSERTED.PatientGoalProgressLogId = DELETED.PatientGoalProgressLogId  
                  WHERE  
                      DELETED.FollowUpCompleteDate IS NULL  
                      AND INSERTED.FollowUpCompleteDate IS NOT NULL  
                      AND INSERTED.ActivityCompletedDate IS NULL )  
         BEGIN  
               INSERT INTO  
                   PatientGoalProgressLog  
                   (  
                     PatientGoalId  
                   ,PatientActivityId  
                   ,ProgressPercentage  
                   ,FollowUpDate  
                   ,CreatedByUserId  
                   )  
                   SELECT  
                       PatientActivity.PatientGoalId  
                      ,PatientActivity.PatientActivityId  
                      ,NULL  
                      ,CASE PatientGoal.ContactFrequencyUnits  
                         WHEN 'D' THEN dateadd(Day , PatientGoal.ContactFrequency , INSERTED.FollowUpDate)  
                         WHEN 'W' THEN dateadd(Week , PatientGoal.ContactFrequency , INSERTED.FollowUpDate)  
                         WHEN 'M' THEN dateadd(Month , PatientGoal.ContactFrequency , INSERTED.FollowUpDate)  
                         WHEN 'Q' THEN dateadd(Quarter , PatientGoal.ContactFrequency , INSERTED.FollowUpDate)  
                         WHEN 'Y' THEN dateadd(Year , PatientGoal.ContactFrequency , INSERTED.FollowUpDate)  
                       END  
                      ,PatientActivity.CreatedByUserId  
                   FROM  
                       PatientActivity  
                   INNER JOIN INSERTED  
                   ON  PatientActivity.PatientGoalId = INSERTED.PatientGoalId  
                       AND PatientActivity.PatientActivityId = INSERTED.PatientActivityId  
                   INNER JOIN PatientGoal  
                   ON  INSERTED.PatientGoalId = PatientGoal.PatientGoalId  
         END  
  
      IF EXISTS ( SELECT  
                      1  
                  FROM  
                      INSERTED  
                  WHERE  
                      ActivityCompletedDate IS NOT NULL )  
         UPDATE  
             Task  
         SET  
             TaskCompletedDate = INSERTED.ActivityCompletedDate  
            ,Comments = INSERTED.Comments  
            ,LastModifiedByUserId = INSERTED.LastModifiedByUserId  
            ,LastModifiedDate = GETDATE()  
            ,TaskStatusId = ( SELECT  
                                  TaskStatusId  
                              FROM  
                                  TaskStatus  
                              WHERE  
                                  TaskStatusText = 'Closed Complete'   
                            )  
             ,AssignedCareProviderId = PatientGoal.AssignedCareProviderId  
         FROM  
             Task  
         INNER JOIN INSERTED  
             ON INSERTED.PatientGoalProgressLogId = Task.PatientGoalProgressLogId  
         INNER JOIN PatientActivity  
              ON PatientActivity.PatientActivityId = INSERTED.PatientActivityId  
         INNER JOIN PatientGoal  
              ON PatientActivity.PatientGoalId = PatientGoal.PatientGoalId  
END      
GO
DISABLE TRIGGER [dbo].[tr_Update_PatientGoalProgressLog]
    ON [dbo].[PatientGoalProgressLog];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Progress rate of the Patient over time to accomplish a goal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the PatientGoalProgressLog table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'PatientGoalProgressLogId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the PatientGoal Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'PatientGoalId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the PatientActivity table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'PatientActivityId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The progress the patient made toward the Goal stored as a percentage.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'ProgressPercentage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date for the next follow up', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'FollowUpDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date a Care Provider updated the progress on a goal.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'FollowUpCompleteDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not used', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'AttemptedContactDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the activity was completed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientGoalProgressLog', @level2type = N'COLUMN', @level2name = N'ActivityCompletedDate';

