CREATE TABLE [dbo].[PatientDrugCodes] (
    [PatientDrugId]            [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PatientID]                [dbo].[KeyID]           NOT NULL,
    [DrugCodeId]               [dbo].[KeyID]           NOT NULL,
    [NumberOfDays]             INT                     NULL,
    [TimesPerDay]              SMALLINT                NULL,
    [DeliveryMethod]           VARCHAR (50)            NULL,
    [Refills]                  [dbo].[KeyID]           NULL,
    [DiscontinuedDate]         DATETIME                NULL,
    [StatusCode]               [dbo].[StatusCode]      CONSTRAINT [DF_PatientDrugCodes_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]          [dbo].[KeyID]           NOT NULL,
    [CreatedDate]              [dbo].[UserDate]        CONSTRAINT [DF_PatientDrugCodes_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]     [dbo].[KeyID]           NULL,
    [LastModifiedDate]         [dbo].[UserDate]        NULL,
    [IsTitration]              [dbo].[IsIndicator]     CONSTRAINT [DF_PatientDrugCodes_IsTitration] DEFAULT ((0)) NULL,
    [StartDate]                [dbo].[UserDate]        NULL,
    [EndDate]                  [dbo].[UserDate]        NULL,
    [Comments]                 [dbo].[LongDescription] NULL,
    [ProviderID]               [dbo].[KeyID]           NULL,
    [FrequencyOfTitrationDays] [dbo].[KeyID]           NULL,
    [DatePrescribed]           [dbo].[UserDate]        NOT NULL,
    [DateFilled]               [dbo].[UserDate]        NULL,
    [CareTeamUserID]           [dbo].[KeyID]           NULL,
    [IsAdhoc]                  BIT                     NULL,
    [GPI14]                    VARCHAR (50)            NULL,
    [RxClaimId]                [dbo].[KeyID]           NULL,
    [DataSourceId]             [dbo].[KeyID]           NULL,
    [ProgramID]                INT                     NULL,
    [PatientProgramId]         [dbo].[KeyID]           NULL,
    CONSTRAINT [PK_PatientDrugCodes] PRIMARY KEY CLUSTERED ([PatientDrugId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientDrugCodes_CareTeamUserId] FOREIGN KEY ([CareTeamUserID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientDrugCodes_DataSource] FOREIGN KEY ([DataSourceId]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientDrugCodes_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientDrugCodes_PatientProgram] FOREIGN KEY ([PatientProgramId]) REFERENCES [dbo].[PatientProgram] ([PatientProgramID]),
    CONSTRAINT [FK_PatientDrugCodes_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId]),
    CONSTRAINT [FK_PatientDrugCodes_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientDrugCodes_RxClaim] FOREIGN KEY ([RxClaimId]) REFERENCES [dbo].[RxClaim] ([RxClaimId])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientDrugCodes_PatientID_StatusCode_DateFilled]
    ON [dbo].[PatientDrugCodes]([PatientID] ASC, [StatusCode] ASC, [DateFilled] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientDrugCodes_RxClaimID]
    ON [dbo].[PatientDrugCodes]([PatientID] ASC)
    INCLUDE([RxClaimId]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientDrugCodes_UserId]
    ON [dbo].[PatientDrugCodes]([PatientID] ASC, [StatusCode] ASC, [PatientDrugId] ASC, [DrugCodeId] ASC, [ProviderID] ASC)
    INCLUDE([NumberOfDays], [FrequencyOfTitrationDays], [CareTeamUserID], [StartDate]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PatientDrugCodes]
    ON [dbo].[PatientDrugCodes]([PatientID] ASC, [DrugCodeId] ASC, [DatePrescribed] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO


/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Insert_UserDrugCodes]                   
Description:                     
When   Who    Action                      
---------------------------------------------------------------------      
28/Apr/2010  Balla Kalyan  Created                      
22/Jun/2010 Pramod tasktypeid change related to "Medication Prescription" 
		(Changed from ) "Drug Titration Follow Up Call"
11-Oct-2010 Rathnam added case statement in select condition.
24-Feb-2011 NagaBabu Added INSERT statement to 'UserTimeLineLog' table		
16-May-2011 Rathnam added AssignedCareProviderId column to the task table 
10-Nov-2011 NagaBabu Added Diseaseid field into the task table insert statement 
01-Dec-2011 NagaBabu Replaced NULL by INSERTED.CreatedByUserId for UserId field in Task table   
19-Dec-2011 NagaBabu Replaced 'Users.AssignedCareProviderId' by 'INSERTED.CreatedByUserId' for AssignedCareProviderId
						Field in Task table.   
10-Feb-2012 Rathnam added IsAdhoc column to the task table		
28-June-2012 Rathnam added Typeid column to the task table				                         
---------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Insert_PatientDrugCodes] ON [dbo].[PatientDrugCodes]
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
          TasktypeId = [dbo].[ReturnTaskTypeID]('Medication Prescription')

      INSERT INTO
          TASK
          (
           PatientID
          ,TasktypeId
          ,TaskDueDate
          ,PatientTaskID
          ,TaskStatusId
          ,CreatedByUserId
          ,AssignedCareProviderId
          ,Isadhoc
          ,TypeID
          ,ProgramID
          ,PatientADTId
          )
          SELECT
              INSERTED.PatientID
             ,[dbo].[ReturnTaskTypeID]('Medication Prescription')
             ,INSERTED.DatePrescribed
             ,INSERTED.PatientDrugId
             ,CASE 
					--WHEN DATEADD(DD,@ScheduledDays, INSERTED.DueDate) >= GETDATE() THEN   
                   WHEN INSERTED.DatePrescribed - @i_ScheduledDays > GETDATE() THEN( SELECT
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
             ,INSERTED.CareTeamUserID
             ,INSERTED.IsAdhoc
             ,inserted.DrugCodeId
             ,inserted.ProgramID
             ,(SELECT pp.PatientADTId FROM PatientProgram pp WHERE PP.PatientProgramID = INSERTED.PatientProgramID)
          FROM
              INSERTED
          WHERE
              INSERTED.DateFilled IS NULL
              AND INSERTED.DatePrescribed IS NOT NULL

END





GO

/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Update_UserDrugCodes]                    
Description:                     
When   Who    Action                      
---------------------------------------------------------------------      
28/Apr/2010  Balla Kalyan  Created                      
24-Feb-2011  NagaBabu Added two insert statements UserTimeLineLog  
31-March-2011 Rathnam added UPDATE(DatePrescribed) if clause.  
01-April-2011 Rathnam removed where clause from first update statement.   
16-May-2011 Rathnam added AssignedCareProviderId column to the task table   
10-Nov-2011 NagaBabu Added Diseaseid field into the task table Update statement  
01-Dec-2011 NagaBabu Added CASE statement for UserId field in Task table   
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been updating by INSERTED.LastModifiedByUserId                   
17-May-2012 NagaBabu Added where clause for UPDATE(DUEDATE) condition to Task table update Statement    
24-Dec-2012 Mohan Modified  'Closed Complete' to  Pending in TaskStatusText 
25-July-2013 Rathnam dropped the patientdurg column from the task table
---------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Update_PatientDrugCodes] ON [dbo].[PatientDrugCodes]
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @i_ScheduledDays INT

	SELECT @i_ScheduledDays = ScheduledDays
	FROM TaskType
	WHERE TasktypeId = [dbo].[ReturnTaskTypeID]('Medication Prescription')

	IF 
		UPDATE (DatePrescribed)

	BEGIN
		UPDATE Task
		SET TaskDueDate = INSERTED.DatePrescribed
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
			,TaskStatusId = CASE 
				--WHEN DATEADD(DD,@ScheduledDays, INSERTED.DueDate) >= GETDATE() THEN  
				WHEN INSERTED.DatePrescribed - @i_ScheduledDays > GETDATE()
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
			,AssignedCareProviderId = INSERTED.CareTeamUserID
		FROM INSERTED
		WHERE Task.PatientTaskID = INSERTED.PatientDrugId
			AND Task.PatientId = INSERTED.PatientID
			AND Task.TypeID = inserted.DrugCodeId
			AND Task.TaskTypeId = DBO.[ReturnTaskTypeID]('Medication Prescription')
			AND INSERTED.DateFilled IS NULL
			AND Task.TaskStatusId IN (
				1
				,2
				)
	END

	IF EXISTS (
			SELECT 1
			FROM INSERTED
			WHERE DateFilled IS NOT NULL
				OR StatusCode = 'I'
			)
	BEGIN
		UPDATE Task
		SET TaskCompletedDate = INSERTED.DateFilled
			,Comments = INSERTED.Comments
			,TaskStatusId = CASE 
				WHEN INSERTED.DateFilled IS NOT NULL
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
			,LastModifiedByUserId = INSERTED.LastModifiedByUserId
			,LastModifiedDate = INSERTED.LastModifiedDate
			,AssignedCareProviderId = INSERTED.CareTeamUserID
		FROM INSERTED
		WHERE Task.PatientTaskID = INSERTED.PatientDrugId
			AND Task.PatientID = INSERTED.PatientID
			AND (
				DateFilled IS NOT NULL
				OR StatusCode = 'I'
				)
			AND Task.TypeID = inserted.DrugCodeId
			AND Task.TaskTypeId = DBO.[ReturnTaskTypeID]('Medication Prescription')
	END
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'List of drug prescribed for a patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserDrugCodes table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'PatientDrugId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table - Identifies the Patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'PatientID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CodeSetDrug Table - Identifies the Drug prescribed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'DrugCodeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The number of days the prescription covers', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'NumberOfDays';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The number of times a day the patient should take the medication', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'TimesPerDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'method of drug delivery', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'DeliveryMethod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'# of refills for the medication', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'Refills';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the prescription was discontinued', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'DiscontinuedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Is the medication titrated', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'IsTitration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the patient started the medication', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'StartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the Patient stop taking the medicine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Provider that prescribed the medication', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'ProviderID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The period of time between titration', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'FrequencyOfTitrationDays';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the Drug was prescribed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'DatePrescribed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the drug RX was filled', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugCodes', @level2type = N'COLUMN', @level2name = N'DateFilled';

