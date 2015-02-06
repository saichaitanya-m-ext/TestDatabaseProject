CREATE TABLE [dbo].[PatientQuestionaire] (
    [PatientQuestionaireId]         [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [PatientId]                     [dbo].[KeyID]       NOT NULL,
    [PatientProgramID]              [dbo].[KeyID]       NULL,
    [QuestionaireId]                [dbo].[KeyID]       NOT NULL,
    [DateTaken]                     [dbo].[UserDate]    NULL,
    [CreatedDate]                   [dbo].[UserDate]    CONSTRAINT [DF_PatientQuestionaire_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedByUserId]               [dbo].[KeyID]       NOT NULL,
    [Comments]                      VARCHAR (4000)      NULL,
    [DateDue]                       [dbo].[UserDate]    NOT NULL,
    [DateAssigned]                  [dbo].[UserDate]    NULL,
    [LastModifiedByUserId]          [dbo].[KeyID]       NULL,
    [LastModifiedDate]              [dbo].[UserDate]    NULL,
    [StatusCode]                    [dbo].[StatusCode]  CONSTRAINT [DF__UserQuest__Statu__2F6FF32E] DEFAULT ('A') NOT NULL,
    [PreviousPatientQuestionaireId] [dbo].[KeyID]       NULL,
    [IsPreventive]                  [dbo].[IsIndicator] CONSTRAINT [DF_PatientQuestionaire_IsPreventive] DEFAULT ('0') NULL,
    [TotalScore]                    SMALLINT            NULL,
    [ProgramId]                     [dbo].[KeyID]       NULL,
    [IsAdhoc]                       BIT                 NULL,
    [IsEnrollment]                  BIT                 CONSTRAINT [DF_PatientQuestionaire_IsEnrollment] DEFAULT ((0)) NULL,
    [AssignedCareProviderId]        INT                 NULL,
    [IsProgramTask]                 BIT                 NULL,
    CONSTRAINT [PK_PatientQuestionaire] PRIMARY KEY CLUSTERED ([PatientQuestionaireId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PatientQuestionaire_AssignedCareProvider] FOREIGN KEY ([AssignedCareProviderId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientQuestionaire_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientQuestionaire_PatientProgram] FOREIGN KEY ([PatientProgramID]) REFERENCES [dbo].[PatientProgram] ([PatientProgramID]),
    CONSTRAINT [FK_PatientQuestionaire_PrevUserQuestionaire] FOREIGN KEY ([PreviousPatientQuestionaireId]) REFERENCES [dbo].[PatientQuestionaire] ([PatientQuestionaireId]),
    CONSTRAINT [FK_PatientQuestionaire_Program] FOREIGN KEY ([ProgramId]) REFERENCES [dbo].[Program] ([ProgramId]),
    CONSTRAINT [FK_PatientQuestionaire_Questionaire] FOREIGN KEY ([QuestionaireId]) REFERENCES [dbo].[Questionaire] ([QuestionaireId]),
    CONSTRAINT [FK_UserQuestionaire_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientQuestionaire_QuestionaireId]
    ON [dbo].[PatientQuestionaire]([QuestionaireId] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientQuestionaire_ProgramID]
    ON [dbo].[PatientQuestionaire]([ProgramId] ASC, [PatientId] ASC, [QuestionaireId] ASC)
    INCLUDE([PatientQuestionaireId]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientQuestionaire_QuestionaireId_UserId]
    ON [dbo].[PatientQuestionaire]([PatientId] ASC, [QuestionaireId] ASC, [ProgramId] ASC)
    INCLUDE([DateAssigned], [IsEnrollment], [IsProgramTask]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PatientQuestionaire]
    ON [dbo].[PatientQuestionaire]([PatientId] ASC, [QuestionaireId] ASC, [DateDue] ASC, [PatientProgramID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Insert_UserQuestionaire]
Description:                     
When   Who    Action                      
29/Apr/2010  Balla Kalyan  Created                      
---------------------------------------------------------------------      
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
24-June-2010 Ratnam   Modified code for TaskStatusId in CASE Statement
20-Aug-2010 Rathnam Trim Functions Added.
24-Feb-2011 NagaBabu adding a ': ' after 'Questionnaire' and before 'Questionaire.QuestionaireName' 
16-May-2011 Rathnam added AssignedCareProviderId column to the task table
09-Jun-2011 Rathnam Added DiseaseID, Ispreventive column to the insert statement 
09-Nov-2011 NagaBabu Added Programid Column to the Task table INSERT statement
02-Dec-2011 NagaBabu Replaced NULL by INSERTED.CreatedByUserId for UserId field in Task table   
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been INSERTing by INSERTED.LastModifiedByUserId                 
10-Feb-2012 Rathnam added IsAdhoc column to the task table
28-June-2012 Rathnam added Typeid,IsProgramTask column to the task table
25-July-2013 Rathnamd droped the column Patientquestionaireid from task table
---------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Insert_PatientQuestionaire] ON [dbo].[PatientQuestionaire]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @i_ScheduledDays INT
		,@v_QuestionaireType VARCHAR(1)

	/*
      IF EXISTS ( SELECT
                      1
                  FROM
                      Questionaire q
                  INNER JOIN QuestionaireType qt
                      ON q.QuestionaireTypeId = qt.QuestionaireTypeId
                  INNER JOIN inserted uq
                      ON uq.QuestionaireId = q.QuestionaireId
                  WHERE
                      qt.QuestionaireTypeName = 'Medication Titration' )
         BEGIN
               SET @v_QuestionaireType = 'M'
               SELECT
                   @i_ScheduledDays = ScheduledDays
               FROM
                   TaskType
               WHERE
                   TasktypeId = [dbo].[ReturnTaskTypeID]('Medication Titration')
         END
      ELSE
         BEGIN
               SET @v_QuestionaireType = 'Q'
               SELECT
                   @i_ScheduledDays = ScheduledDays
               FROM
                   TaskType
               WHERE
                   TasktypeId = [dbo].[ReturnTaskTypeID]('Questionnaire')
         END
         */
	SELECT @i_ScheduledDays = ScheduledDays
	FROM TaskType
	WHERE TasktypeId = [dbo].[ReturnTaskTypeID]('Questionnaire')

	IF EXISTS (
			SELECT 1
			FROM INSERTED
			WHERE INSERTED.DateDue IS NOT NULL
				AND INSERTED.DateTaken IS NULL
			)
	BEGIN
		INSERT INTO TASK (
			PatientId
			,TasktypeId
			,TaskDueDate
			,TaskStatusId
			,PatientTaskID
			,CreatedByUserId
			,AssignedCareProviderId
			,ProgramID
			,Isadhoc
			,TypeID
			,IsEnrollment
			,IsProgramTask
			,IsBatchProgram
			,PatientADTID
			)
		SELECT INSERTED.PatientId
			,[dbo].[ReturnTaskTypeID]('Questionnaire')
			/*
                      ,CASE
                            WHEN @v_QuestionaireType = 'Q' THEN [dbo].[ReturnTaskTypeID]('Questionnaire')
                            ELSE [dbo].[ReturnTaskTypeID]('Medication Titration')
                       END
                       */
			,INSERTED.DateDue
			,
			/*CASE 
						WHEN DATEADD(DD,@i_ScheduledDays, INSERTED.DateDue) >= GETDATE() THEN   
					(SELECT TaskStatusId FROM TaskStatus WHERE TaskStatusText = 'Open')  
					ELSE  
					(SELECT TaskStatusId FROM TaskStatus WHERE TaskStatusText = 'Scheduled')  
					END,*/
			CASE 
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
			,INSERTED.PatientQuestionaireId
			,INSERTED.CreatedByUserId
			,INSERTED.AssignedCareProviderId
			,INSERTED.ProgramId
			,INSERTED.IsAdhoc
			,inserted.QuestionaireId
			,inserted.IsEnrollment
			,Inserted.IsProgramTask
			,CASE 
				WHEN inserted.IsProgramTask = 1
					THEN 1
				ELSE 0
				END
				,(SELECT PatientADTID FROM PatientProgram pp WHERE pp.PatientProgramID = INSERTED.PatientProgramID)
		FROM INSERTED
		WHERE INSERTED.DateDue IS NOT NULL
			AND INSERTED.DateTaken IS NULL
	END
END



GO
/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Update_UserQuestionaire]  
Description:                       
When   Who    Action                        
---------------------------------------------------------------------        
29/Apr/2010  Balla Kalyan  Created                        
23/Jun/10    Pramod Modified the trigger to include condition for close task  
24-June-2010 Ratnam Modified TaskStatusId in Update Statement  
20-Aug-2010  Rathnam added Trim Function.  
24-Feb-2011 NagaBabu adding a ': ' after 'Questionnaire' and before 'Questionaire.QuestionaireName'   
16-May-2011 Rathnam added AssignedCareProviderId column to the task table    
09-Jun-2011 Rathanm Added DiseaseID, Ispreventive column to the update task statement  
09-Nov-2011 NagaBabu Added Programid Column to the Task table UPDATE statement     
23-NOv-2011 Rathnam added UPDATE(DateTaken) OR UPDATE(StatusCode)     
02-Dec-2011 NagaBabu Added CASE statement for UserId field in Task table    
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been updating by INSERTED.LastModifiedByUserId                   
17-May-2012 NagaBabu Added where clause for UPDATE(DUEDATE) condition to Task table update Statement    
25-May-2012 Sivakrishna Added where Condition(Taskstatusid in(1,2) to restrict the update TaskCompleted date for Pending For Claims and closed incomplete  
24-Dec-2012 Mohan Modified  'Closed Complete' to  Pending in TaskStatusText 
25-July-2013 Rathnam dropped the column from PatientQuestionaireId task table
---------------------------------------------------------------------        
*/
CREATE TRIGGER [dbo].[tr_Update_PatientQuestionaire] ON [dbo].[PatientQuestionaire]
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @i_ScheduledDays INT

	SELECT @i_ScheduledDays = ScheduledDays
	FROM TaskType
	WHERE TasktypeId = [dbo].[ReturnTaskTypeID]('Questionnaire')

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
			,AssignedCareProviderId = INSERTED.AssignedCareProviderId
			,ProgramID = INSERTED.ProgramID
		FROM INSERTED
		WHERE Task.PatientTaskID = INSERTED.PatientQuestionaireId
			AND Task.PatientId = INSERTED.PatientId
			AND Task.TypeID = inserted.QuestionaireId
			AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Questionnaire')
			AND INSERTED.DateTaken IS NULL
			AND Task.TaskStatusId IN (SELECT TaskStatusId FROM TaskStatus ts WHERE TaskStatusText IN ('Scheduled','Open')
				
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
			,AssignedCareProviderId = INSERTED.AssignedCareProviderId
		FROM INSERTED
		WHERE Task.PatientTaskID = INSERTED.PatientQuestionaireId
			AND Task.PatientId = INSERTED.PatientId
			AND Task.TypeID = INSERTED.QuestionaireId
			AND (
				INSERTED.DateTaken IS NOT NULL
				OR INSERTED.StatusCode = 'I'
				)
			AND Task.TaskStatusId IN (
SELECT TaskStatusId FROM TaskStatus ts WHERE TaskStatusText IN ('Scheduled','Open'))
AND Task.TaskTypeId = [dbo].[ReturnTaskTypeID]('Questionnaire')
	END
END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'List of questionnaires that a patient is scheduled to take or has taken', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserQuestionaire table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'PatientQuestionaireId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table - indicates the patient that has taken or is scheduled to take the Questionnaire', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'PatientId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Questionnaire table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'QuestionaireId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the patient took answered the questionnaire', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'DateTaken';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Due Date for the Questionnaire to be completed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'DateDue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not Used', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'DateAssigned';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaire', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

