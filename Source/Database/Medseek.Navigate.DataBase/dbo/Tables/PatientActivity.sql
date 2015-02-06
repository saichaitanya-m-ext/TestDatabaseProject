CREATE TABLE [dbo].[PatientActivity] (
    [PatientActivityId]    [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [ActivityId]           [dbo].[KeyID]           NOT NULL,
    [PatientGoalId]        [dbo].[KeyID]           NOT NULL,
    [Description]          [dbo].[LongDescription] NULL,
    [CreatedByUserId]      [dbo].[KeyID]           NOT NULL,
    [CreatedDate]          [dbo].[UserDate]        CONSTRAINT [DF_PatientActivity_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]           NULL,
    [LastModifiedDate]     [dbo].[UserDate]        NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_PatientActivity_StatusCode] DEFAULT ('A') NOT NULL,
    [IsAdhoc]              [dbo].[IsIndicator]     NULL,
    [ProgressPercentage]   CHAR (1)                NULL,
    CONSTRAINT [PK_PatientActivity] PRIMARY KEY CLUSTERED ([PatientActivityId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientActivity_Activity] FOREIGN KEY ([ActivityId]) REFERENCES [dbo].[Activity] ([ActivityId]),
    CONSTRAINT [FK_PatientActivity_PatientGoal] FOREIGN KEY ([PatientGoalId]) REFERENCES [dbo].[PatientGoal] ([PatientGoalId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PatientActivity_ActivityGoal]
    ON [dbo].[PatientActivity]([ActivityId] ASC, [PatientGoalId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                    
---------------------------------------------------------------------    
TriggerName: [dbo].[tr_Update_PatientActivity]                  
Description: This trigger fires when the PatientActivity.StatusCode changes to 'I' and updates StatusCode as 'I'
				 in PatientGoalProgressLog table for PatientGoalProgressLog.PatientActivityId   
Created By : NagaBabu
CreatedDate: 23-June-2011                      
---------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
                 
---------------------------------------------------------------------    
*/
CREATE TRIGGER [dbo].[tr_Update_PatientActivity] ON [dbo].[PatientActivity]
       FOR UPDATE
AS 
BEGIN
	UPDATE
		PatientGoalProgressLog
	SET
		StatusCode = 'I' ,
		LastModifiedByUserId = INSERTED.LastModifiedByUserId ,
		LastModifiedDate = GETDATE()
	FROM
		PatientGoalProgressLog
	INNER JOIN INSERTED
		ON PatientGoalProgressLog.PatientActivityId = INSERTED.PatientActivityId
	INNER JOIN DELETED
		ON DELETED.PatientActivityId = INSERTED.PatientActivityId
    WHERE 
		INSERTED.StatusCode = 'I'
	AND DELETED.StatusCode = 'A'
			   
END  


GO
DISABLE TRIGGER [dbo].[tr_Update_PatientActivity]
    ON [dbo].[PatientActivity];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A Activity assigned to a Patient to help the patient achieve a goal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the PatientActivity table - identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'PatientActivityId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Activity table defines the Activity assigned to the patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'ActivityId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the PatientGoal table - defines the goal the activity was assigned to for the specific patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'PatientGoalId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for PatientActivity table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientActivity', @level2type = N'COLUMN', @level2name = N'StatusCode';

