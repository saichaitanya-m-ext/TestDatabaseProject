CREATE TABLE [dbo].[PatientProgram] (
    [PatientProgramID]            [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [ProgramID]                   [dbo].[KeyID]       NOT NULL,
    [PatientID]                   [dbo].[KeyID]       NOT NULL,
    [EnrollmentStartDate]         [dbo].[UserDate]    NOT NULL,
    [EnrollmentEndDate]           [dbo].[UserDate]    NULL,
    [IsPatientDeclinedEnrollment] [dbo].[IsIndicator] NULL,
    [DeclinedDate]                DATETIME            NULL,
    [DueDate]                     [dbo].[UserDate]    NULL,
    [ProgramExcludeID]            [dbo].[KeyID]       NULL,
    [IsAdhoc]                     BIT                 NULL,
    [IsAutoEnrollment]            [dbo].[IsIndicator] NULL,
    [IdentificationDate]          DATETIME            NULL,
    [IsCommunicated]              [dbo].[IsIndicator] CONSTRAINT [DF_PatientProgram_IsCommunicated] DEFAULT ((0)) NULL,
    [IsEnrollConfirmationSent]    BIT                 CONSTRAINT [DF_PatientProgram_IsEnrollConfirmationSent] DEFAULT ((0)) NULL,
    [ProviderID]                  [dbo].[KeyID]       NULL,
    [DataSourceFileID]            [dbo].[KeyID]       NULL,
    [DataSourceID]                [dbo].[KeyID]       NULL,
    [StatusCode]                  [dbo].[StatusCode]  CONSTRAINT [DF_PatientProgram_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]             [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                 [dbo].[UserDate]    CONSTRAINT [DF_PatientProgram_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]        [dbo].[KeyID]       NULL,
    [LastModifiedDate]            [dbo].[UserDate]    NULL,
    [PatientADTId]                INT                 NULL,
    CONSTRAINT [PK_PatientProgram] PRIMARY KEY CLUSTERED ([PatientProgramID] ASC),
    CONSTRAINT [FK_PatientProgram_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientProgram_DataSourceId] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientProgram_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientProgram_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId]),
    CONSTRAINT [FK_PatientProgram_ProgramExclusionReasons] FOREIGN KEY ([ProgramExcludeID]) REFERENCES [dbo].[ProgramExclusionReasons] ([ProgramExcludeID]),
    CONSTRAINT [FK_PatientProgram_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE NONCLUSTERED INDEX [IX_Patientprogram_PatientID_ProgramID_EnrollmentStartDate]
    ON [dbo].[PatientProgram]([ProgramID] ASC, [PatientID] ASC, [EnrollmentStartDate] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [<IX_STATUSCODE>]
    ON [dbo].[PatientProgram]([StatusCode] ASC)
    INCLUDE([ProgramID], [PatientID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO

/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Insert_UserPrograms]   
Description:                       
When   Who    Action                        
---------------------------------------------------------------------        
29/Apr/2010  ADITYA   Created   
18/June/2010 NagaBabu  Replaced Program Enrollment Task By Program Enrollment                       
24-June-2010 Nagababu  Modified TaskStatusId field Case statement 
20-Aug-2010 NagaBabu Added TRIM function 
24-Feb-2011 NagaBabu added ': ' after 'Started Program' and before 'Program.ProgramName'
						And changed date formate from 113 to 101 and deleted '.'
16-May-2011 Rathnam added AssignedCareProviderId in the task table.	
02-Dec-2011 NagaBabu Replaced NULL by INSERTED.CreatedByUserId for UserId field in Task table  	
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been INSERTing by INSERTED.LastModifiedByUserId				
10-Feb-2012 Rathnam added IsAdhoc column to the task table
29-Feb-2012 Rathnam replaced the PatientGoalProgressLogid with PatientGoalID
28-June-2012 Rathnam added Typeid column to the task table
---------------------------------------------------------------------        
*/
CREATE TRIGGER [dbo].[tr_Insert_PatientProgram] ON [dbo].[PatientProgram]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON
      --INSERT INTO
      --    UserTimelineLog
      --    (
      --      UserID ,
      --      Comments ,
      --      TimelineDate ,
      --      SubjectText ,
      --      TimelineTypeID ,
      --      CreatedByUserId
      --    )
      --    SELECT
      --        INSERTED.UserID ,
      --        'Started Program: ' + LTRIM(RTRIM(Program.ProgramName)) + ' on ' + CONVERT(VARCHAR(17) , INSERTED.EnrollmentStartDate , 101),
      --        INSERTED.EnrollmentStartDate ,
      --        'Started Program: ' + LTRIM(RTRIM(Program.ProgramName)) + ' on ' + CONVERT(VARCHAR(17) , INSERTED.EnrollmentStartDate , 101),
      --        dbo.ReturnTimeLineTypeID('Programs') ,
      --        INSERTED.CreatedByUserId
      --    FROM
      --        INSERTED
      --    INNER JOIN Program
      --        ON Program.ProgramId = INSERTED.ProgramId
      --    WHERE
      --        ( INSERTED.EnrollmentStartDate IS NOT NULL )

      --DECLARE @ScheduledDays INT
      --SELECT
      --    @ScheduledDays = ScheduledDays
      --FROM
      --    TaskType
      --WHERE
      --    TasktypeId = [dbo].[ReturnTaskTypeID]('Program Enrollment')

      --INSERT INTO
      --    TASK
      --    (
      --      PatientUserId ,
      --      TasktypeId ,
      --      TaskDueDate ,
      --      TaskCompletedDate ,
      --      Comments ,
      --      UserDrugID1 ,
      --      UserDrugID2 ,
      --      TaskStatusId ,
      --      UserQuestionaireId ,
      --      UserProcedureId ,
      --      PatientGoalId ,
      --      UserEncounterId ,
      --      CreatedByUserId ,
      --      UserID ,
      --      UserProgramID ,
      --      UserHealthStatusId ,
      --      UserImmunizationID ,
      --      AssignedCareProviderId,
      --      IsAdhoc,
      --      TypeID
      --    )
      --    SELECT
      --        INSERTED.UserId ,
      --        [dbo].[ReturnTaskTypeID]('Program Enrollment') ,
      --        INSERTED.DueDate ,
      --        NULL ,
      --        NULL ,
      --        NULL ,
      --        NULL ,
      --        CASE   
      --            --WHEN DATEADD(DD,@ScheduledDays, INSERTED.DueDate) >= GETDATE() THEN  
      --             WHEN INSERTED.DueDate - @ScheduledDays > GETDATE() THEN( SELECT
      --                                                                          TaskStatusId
      --                                                                      FROM
      --                                                                          TaskStatus
      --                                                                      WHERE
      --                                                                          TaskStatusText = 'Scheduled' )
      --             ELSE( SELECT
      --                       TaskStatusId
      --                   FROM
      --                       TaskStatus
      --                   WHERE
      --                       TaskStatusText = 'Open' )
      --        END ,
      --        NULL ,
      --        NULL ,
      --        NULL ,
      --        NULL ,
      --        INSERTED.CreatedByUserId ,
      --        INSERTED.CreatedByUserId ,
      --        INSERTED.UserProgramId ,
      --        NULL ,
      --        NULL ,
      --        INSERTED.CreatedByUserId,
      --        INSERTED.IsAdhoc,
      --        inserted.ProgramId
      --    FROM
      --        INSERTED
      --    --INNER JOIN Users 
      --    --    ON Users.UserId = INSERTED.UserId    
      --    WHERE
      --        INSERTED.DueDate IS NOT NULL
      --    AND INSERTED.EnrollmentStartDate IS NULL
      --    AND INSERTED.IsPatientDeclinedEnrollment = 0
          
          
          MERGE INTO PatientSummary AS MPS
						USING 
						( SELECT
							  INSERTED.PatientID
							,STUFF((
									  SELECT DISTINCT
										  ', ' + CAST(pr.ProgramId AS VARCHAR)
									  FROM
										UserPrograms up WITH(NOLOCK)
									   INNER JOIN Program pr
									     ON pr.ProgramId = up.ProgramId
									   WHERE up.UserId = INSERTED.UserId
									     AND up.StatusCode = 'A'
									     AND pr.StatusCode = 'A'
									   FOR
										  XML PATH('')
								       ) , 1 , 2 , ''
								     ) AS Populations
								    ,(SELECT 
										  SUM(CASE WHEN Pr.ProgramId IS NOT NULL THEN 1 ELSE 0 END)
									  FROM 
										PatientProgram up WITH(NOLOCK)
									   INNER JOIN Program pr
									     ON pr.ProgramId = up.ProgramId
									   WHERE up.UserId = INSERTED.UserId
									     AND up.StatusCode = 'A'
									     AND pr.StatusCode = 'A'
									    ) AS PopulationCnt
									    	
						  FROM
							  INSERTED 
                         )AS IUE
						ON MPS.PatientUserId= IUE.UserID
						WHEN MATCHED
							THEN
								--Row exists and data is different
						UPDATE SET MPS.Populations =  IUE.Populations,
						           MPS.PopulationCnt =  IUE.PopulationCnt,
						           MPS.LastModifiedDate = GETDATE()
							
						WHEN NOT MATCHED
							  THEN 
								--Row exists in source but not in target
						INSERT  VALUES
						(
						  IUE.UserID
						 ,NULL
						 ,NULL
						 ,NULL
						 ,NULL
						 ,IUE.Populations
						 ,NULL
						 ,NULL
						 ,NULL
						 ,NULL
						 ,NULL
						 ,NULL
						 ,NULL
						 ,GETDATE()
						 ,NULL
						 ,IUE.PopulationCnt 
                        );

END


GO
DISABLE TRIGGER [dbo].[tr_Insert_PatientProgram]
    ON [dbo].[PatientProgram];


GO

  
 /*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Update_UserPrograms]   
Description:                       
When   Who    Action                        
---------------------------------------------------------------------        
29/Apr/2010  ADITYA   Created                        
16-Jul-10 Pramod Corrected the 2nd update in trigger  
20-Aug-2010 Rathnam Trim Functions added.  
1-Oct-10 Pramod Included ISNERTED.EnrollmentStartDate IS NOT NULL  
08-Oct-2010 Rathnam added IF UPDATE(DueDate) clause and added   
                    INSERTED.IsPatientDeclinedEnrollment = 1 in exist clause  
12-Oct-2010 Rathnam added 2nd update statement and commented the existing update.   
24-Feb-2011 NagaBabu added ': ' after 'Started Program' and before 'Program.ProgramName'  
      And changed date formate from 113 to 101 and deleted '.'   
16-May-2011 Rathnam added AssignedCareProviderId column to the task table      
02-Dec-2011 NagaBabu Added CASE statement for UserId field in Task table  
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been updating by INSERTED.LastModifiedByUserId                         
17-May-2012 NagaBabu Added where clause for UPDATE(DUEDATE) condition to Task table update Statement    
25-May-2012 Sivakrishna Added where Condition(Taskstatusid in(1,2) to restrict the update TaskCompleted date for Pending For Claims and closed incomplete 
24-Dec-2012 Mohan Modified  'Closed Complete' to  Pending in TaskStatusText  
---------------------------------------------------------------------        
*/  
CREATE TRIGGER [dbo].[tr_Update_PatientProgram] ON [dbo].[PatientProgram]  
       AFTER UPDATE  
AS  
BEGIN  
      SET NOCOUNT ON  
      --INSERT INTO  
      --    UserTimelineLog  
      --    (  
      --      UserID  
      --    ,Comments  
      --    ,TimelineDate  
      --    ,SubjectText  
      --    ,TimelineTypeID  
      --    ,CreatedByUserId  
      --    )  
      --    SELECT  
      --        INSERTED.UserID  
      --       ,'Started Program:  ' + LTRIM(RTRIM(Program.ProgramName)) + ' on ' + CONVERT(VARCHAR(17) , INSERTED.EnrollmentStartDate , 101)  
      --       ,INSERTED.EnrollmentStartDate  
      --       ,'Started Program:  ' + LTRIM(RTRIM(Program.ProgramName)) + ' on ' + CONVERT(VARCHAR(17) , INSERTED.EnrollmentStartDate , 101)  
      --       ,dbo.ReturnTimeLineTypeID('Programs')  
      --       ,ISNULL(INSERTED.LastModifiedByUserId , INSERTED.CreatedByUserId)  
      --    FROM  
      --        INSERTED  
      --    INNER JOIN Program  
      --    ON  Program.ProgramId = INSERTED.ProgramId  
      --    INNER JOIN DELETED  
      --    ON  DELETED.ProgramId = INSERTED.ProgramId  
      --    WHERE  
      --        ( DELETED.EnrollmentStartDate IS NULL )  
      --    AND ( INSERTED.EnrollmentStartDate IS NOT NULL )  
  
      --DECLARE @i_ScheduledDays INT  
      --SELECT  
      --    @i_ScheduledDays = ScheduledDays  
      --FROM  
      --    TaskType  
      --WHERE  
      --    TasktypeId = [dbo].[ReturnTaskTypeID]('Program Enrollment')  
  
      --IF UPDATE(DueDate)  
      --   BEGIN  
      --         UPDATE  
      --             Task  
      --         SET  
      --             TaskDueDate = INSERTED.DueDate  
      --            ,LastModifiedByUserId = INSERTED.LastModifiedByUserId  
      --            ,LastModifiedDate = INSERTED.LastModifiedDate  
      --            ,TaskStatusId = CASE   
      --     WHEN DATEADD(DD,@i_ScheduledDays, INSERTED.DateDue) >= GETDATE() THEN  
      --                                 WHEN INSERTED.DueDate - @i_ScheduledDays > GETDATE() THEN  
      --                                 ( SELECT  
      --                                       TaskStatusId  
      --                                   FROM  
      --                                       TaskStatus  
      --                                   WHERE  
      --                                       TaskStatusText = 'Scheduled' )  
      --                                 ELSE  
      --                                 ( SELECT  
      --                                       TaskStatusId  
      --        FROM  
      --                                       TaskStatus  
      --                                   WHERE  
      --                                       TaskStatusText = 'Open' )  
      --                            END,  
      --             AssignedCareProviderId = INSERTED.LastModifiedByUserId ,  
      --             UserID = CASE WHEN Task.UserID IS NULL THEN INSERTED.LastModifiedByUserId  
      --  ELSE Task.UserID   
      -- END                                       
      --         FROM  
      --             Task  
      --         INNER JOIN INSERTED  
      --             ON Task.UserProgramId = INSERTED.UserProgramId  
      --         INNER JOIN Users   
      --             ON Users.UserId = INSERTED.UserID      
      --            AND Task.PatientUserId = INSERTED.UserID  
      --         WHERE  
      --             INSERTED.EnrollmentStartDate IS NULL  
      --         AND Task.TaskStatusId IN (1,2)  
      --   END  
      --IF EXISTS ( SELECT  
      --                1  
      --            FROM  
      --                INSERTED  
      --            WHERE  
      --                EnrollmentStartDate IS NOT NULL  
      --             OR StatusCode = 'I'  
      --             OR IsPatientDeclinedEnrollment = 1 )  
  
      --   BEGIN  
      --         UPDATE  
      --             TASK  
      --         SET  
      --             TaskCompletedDate = INSERTED.LastModifiedDate  
      --            ,Comments = NULL  
      --            ,LastModifiedByUserId = INSERTED.LastModifiedByUserId  
      --            ,LastModifiedDate = INSERTED.LastModifiedDate  
      --            ,TaskStatusId = CASE  
      --                                 WHEN INSERTED.EnrollmentStartDate IS NOT NULL THEN  
      --                                 ( SELECT  
      --                                       TaskStatusId  
      --                                   FROM  
      --                                       TaskStatus  
      --                                   WHERE  
      --                                       TaskStatusText = 'Closed Complete' )  
      --                                 ELSE  
      --                                 ( SELECT  
      --                                       TaskStatusId  
      --                                   FROM  
      --                                       TaskStatus  
      --                                   WHERE  
      --                                       TaskStatusText = 'Closed Incomplete' )  
      --                            END,  
      --             AssignedCareProviderId = INSERTED.LastModifiedByUserId ,  
      --             UserID = CASE WHEN Task.UserID IS NULL THEN INSERTED.LastModifiedByUserId  
      --  ELSE Task.UserID   
      -- END                                                     
      --         FROM  
      --             INSERTED  
      --INNER JOIN TASK  
      --             ON TASK.PatientUserId = INSERTED.UserId  
      --AND TASK.UserProgramID = INSERTED.UserProgramId  
      --AND Task.TaskStatusId IN(1,2)  
      ----INNER JOIN Users   
      ----             ON Users.UserId = INSERTED.UserID      
  
      --   END  
      --IF EXISTS ( SELECT  
      --                1  
      --            FROM  
      --                INSERTED  
      --            INNER JOIN TASK  
      -- ON TASK.PatientUserId = INSERTED.UserId  
      --               AND TASK.UserProgramID = INSERTED.UserProgramId  
      --            WHERE  
      --                (  
      --                INSERTED.StatusCode = 'I'  
      --                AND TASK.TaskStatusID = ( SELECT  
      --                                              TaskStatusId  
      --                                          FROM  
      --                                              TaskStatus  
      --                                          WHERE  
      --                                              TaskStatusText = 'Open' )  
      --                )  
      --                OR ( INSERTED.IsPatientDeclinedEnrollment = 1 ) )  
      --   BEGIN  
      --         UPDATE  
      --             TASK  
      --         SET  
      --             TaskCompletedDate = INSERTED.LastModifiedDate  
      --            ,Comments = NULL  
      --            ,LastModifiedByUserId = INSERTED.LastModifiedByUserId  
      --            ,LastModifiedDate = INSERTED.LastModifiedDate  
      --            ,TaskStatusID = ( SELECT  
      --                                  TaskStatusId  
      --                              FROM  
      --                                  TaskStatus  
      --                              WHERE  
      --                                  TaskStatusText = 'Closed Incomplete' )  
      --         FROM  
      --             INSERTED  
      --         INNER JOIN TASK  
      --             ON TASK.PatientUserId = INSERTED.UserId  
      --            AND TASK.UserProgramID = INSERTED.UserProgramId  
  
      --   END  
      --ELSE  
      --   IF EXISTS ( SELECT  
      --                   1  
      --               FROM  
      --                   DELETED  
      --               INNER JOIN INSERTED  
      --                   ON  DELETED.UserProgramID = INSERTED.UserProgramId  
      --               WHERE  
      --                   (  
      --                   DELETED.EnrollmentStartDate IS NULL  
      --                   AND ( INSERTED.EnrollmentStartDate IS NOT NULL )  
      --                   OR INSERTED.IsPatientDeclinedEnrollment = 0  
      --                   ) )  
      --      BEGIN  
      --            UPDATE  
      --                TASK  
      --            SET  
      --                TaskCompletedDate = INSERTED.LastModifiedDate  
      --               ,Comments = NULL  
      --               ,LastModifiedByUserId = INSERTED.LastModifiedByUserId  
      --               ,LastModifiedDate = INSERTED.LastModifiedDate  
      --               ,TaskStatusID = ( SELECT  
      --                                     TaskStatusId  
      --                                 FROM  
      --                                     TaskStatus  
      --                                 WHERE  
      --                                     TaskStatusText = 'Pending For Claims' )  
      --            FROM  
      --                INSERTED  
      --            INNER JOIN TASK  
      --                ON TASK.PatientUserId = INSERTED.UserId  
      --AND TASK.UserProgramID = INSERTED.UserProgramId  
      --               AND INSERTED.EnrollmentStartDate IS NOT NULL  
      --      END  
      
				MERGE INTO PatientSummary AS MPS
						USING 
						( SELECT
							  INSERTED.PatientID
							,STUFF((
									  SELECT DISTINCT
										  ', ' + CAST(pr.ProgramId AS VARCHAR)
									  FROM
										PatientProgram up WITH(NOLOCK)
									   INNER JOIN Program pr
									     ON pr.ProgramId = up.ProgramId
									   WHERE up.PatientID = INSERTED.PatientID
									     AND up.StatusCode = 'A'
									     AND pr.StatusCode = 'A'
									   FOR
										  XML PATH('')
								       ) , 1 , 2 , ''
								     ) AS Populations
								    ,(SELECT 
										  SUM(CASE WHEN Pr.ProgramId IS NOT NULL THEN 1 ELSE 0 END)
									  FROM 
										UserPrograms up WITH(NOLOCK)
									   INNER JOIN Program pr
									     ON pr.ProgramId = up.ProgramId
									   WHERE up.UserId = INSERTED.UserId
									     AND up.StatusCode = 'A'
									     AND pr.StatusCode = 'A'
									    ) AS PopulationCnt
									    	
						  FROM
							  INSERTED 
                         )AS IUE
						ON MPS.PatientUserId= IUE.UserID
						WHEN MATCHED
							THEN
								--Row exists and data is different
						UPDATE SET MPS.Populations =  IUE.Populations,
						           MPS.PopulationCnt =  IUE.PopulationCnt,
						           MPS.LastModifiedDate = GETDATE()
							
						WHEN NOT MATCHED
							  THEN 
								--Row exists in source but not in target
						INSERT  VALUES
						(
						  IUE.UserID
						 ,NULL
						 ,NULL
						 ,NULL
						 ,NULL
						 ,IUE.Populations
						 ,NULL
						 ,NULL
						 ,NULL
						 ,NULL
						 ,NULL
						 ,NULL
						 ,NULL
						 ,GETDATE()
						 ,NULL
						 ,IUE.PopulationCnt 
                        );
      
END  
  
  

GO
DISABLE TRIGGER [dbo].[tr_Update_PatientProgram]
    ON [dbo].[PatientProgram];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The list of programs a patient is enrolled in cross reference between patients (Users) and Programs', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for table UserPrograms - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'PatientProgramID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Program Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'ProgramID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users Table (Patient User ID )', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'PatientID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the Patient was enrolled in the program', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'EnrollmentStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the patient Left the program', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'EnrollmentEndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag to indicate that the patient declined enrollment in the program', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'IsPatientDeclinedEnrollment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date the user declined to be enrolled in the program', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'DeclinedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Due date to enroll the patient in the program', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'DueDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProgram', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

