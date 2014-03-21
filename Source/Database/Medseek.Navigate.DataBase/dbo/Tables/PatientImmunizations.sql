CREATE TABLE [dbo].[PatientImmunizations] (
    [PatientImmunizationID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [ImmunizationID]          [dbo].[KeyID]           NOT NULL,
    [PatientID]               [dbo].[KeyID]           NULL,
    [ImmunizationDate]        [dbo].[UserDate]        NULL,
    [Comments]                [dbo].[LongDescription] NULL,
    [IsPatientDeclined]       [dbo].[IsIndicator]     NULL,
    [AdverseReactionComments] VARCHAR (500)           NULL,
    [CreatedByUserId]         [dbo].[KeyID]           NOT NULL,
    [CreatedDate]             [dbo].[UserDate]        CONSTRAINT [DF_PatientImmunizations_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    [dbo].[KeyID]           NULL,
    [LastModifiedDate]        [dbo].[UserDate]        NULL,
    [StatusCode]              [dbo].[StatusCode]      CONSTRAINT [DF_PatientImmunizations_StatusCode] DEFAULT ('A') NOT NULL,
    [DueDate]                 [dbo].[UserDate]        NULL,
    [IsPreventive]            [dbo].[IsIndicator]     NULL,
    [IsAdhoc]                 BIT                     NULL,
    [DataSourceID]            INT                     NULL,
    [AssignedCareProviderId]  INT                     NULL,
    [ProgramID]               INT                     NULL,
    CONSTRAINT [PK_PatientImmunizations] PRIMARY KEY CLUSTERED ([PatientImmunizationID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientImmunizations_AssignedCareProvider] FOREIGN KEY ([AssignedCareProviderId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientImmunizations_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientImmunizations_Immunizations] FOREIGN KEY ([ImmunizationID]) REFERENCES [dbo].[Immunizations] ([ImmunizationID]),
    CONSTRAINT [FK_PatientImmunizations_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientImmunizations_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PatientImmunizations]
    ON [dbo].[PatientImmunizations]([ImmunizationID] ASC, [PatientID] ASC, [DueDate] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Insert_UserImmunizations]                  
Description:                   
When   Who    Action                    
---------------------------------------------------------------------    
28/Apr/2010  Balla Kalyan  Created 
24-June-2010 Nagababu  Modified TaskStatusId field in Case statement 
20-Aug-2010 NagaBabu Added TRIM function  
24-Feb-2011 NagaBabu Added a ': ' after 'Immunization Type' and before the type name And deleted '.'
16-May-2011 Rathnam added AssignedCareProviderId column to the task table    
19-sep-2011 Rathnam added ispreventive – All the Immunization are preventive in nature while inserting into the task table              
10-Nov-2011 NagaBabu Added IsPreventive Column to the Task table INSERT statement
02-Dec-2011 NagaBabu Replaced NULL by INSERTED.CreatedByUserId for UserId field in Task table  
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been INSERTing by INSERTED.LastModifiedByUserId
10-Feb-2012 Rathnam added isadhoc column to the task table and duedat is not null conditin
28-June-2012 Rathnam added Typeid column to the task table
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Insert_PatientImmunizations] ON [dbo].[PatientImmunizations]
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
          TasktypeId = [dbo].[ReturnTaskTypeID]('Immunization')
      INSERT INTO
          TASK
          (
            PatientId ,
            TasktypeId ,
            TaskDueDate ,
            TaskStatusId ,
            CreatedByUserId ,
            PatientImmunizationID ,
            AssignedCareProviderId,
            Isadhoc,
            TypeID,
            ProgramID
          )
          SELECT
              INSERTED.PatientID ,
              [dbo].[ReturnTaskTypeID]('Immunization') ,
              INSERTED.DueDate ,
              CASE 
					--WHEN DATEADD(DD,@ScheduledDays, INSERTED.DueDate) >= GETDATE() THEN   
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
              INSERTED.PatientImmunizationID,
              INSERTED.AssignedCareProviderId ,
              inserted.IsAdhoc,
              inserted.ImmunizationID,
             inserted.ProgramID
          FROM
              INSERTED
          WHERE
              INSERTED.ImmunizationDate IS NULL
          AND inserted.DueDate IS NOT NULL    

END


GO
/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Update_UserImmunizations]                    
Description:                     
When   Who    Action                      
---------------------------------------------------------------------      
28/Apr/2010  Balla Kalyan  Created                      
23/Jun/10 Pramod Included optout in the OR clause  
24-June-2010 Nagababu  Modified TaskStatusId field in Update statement  
20-Aug-2010 NagaBabu Added TRIM function  
11-Oct-2010 Rathnam  modified case statement as INSERTED.ImmunizationDate IS NOT NULL   
                     insetead of using INSERTED.Duedate IS NOT NULL   
24-Feb-2011 NagaBabu Added a ': ' after 'Immunization Type' and before the type name And deleted '.'      
16-May-2011 Rathnam added AssignedCareProviderId column to the task table    
10-Nov-2011 NagaBabu Added IsPreventive Column to the Task table UPDATE statement   
02-Dec-2011 NagaBabu Added CASE statement for UserId field in Task table     
20-Dec-2011 NagaBabu Removed JOIN with users table while AssignedCareProviderId field has been updating by INSERTED.LastModifiedByUserId      
14-May-2012 Rathnam   AND INSERTED.StatusCode  =  'A'   AND deleted.StatusCode = 'I' condition while updating the duedate  
25-May-2012 Sivakrishna Added where Condition(Taskstatusid in(1,2) to restrict the update TaskCompleted date to Task table update Statement for Pending For Claims and closed incomplete 
24-Dec-2012 Mohan Modified  'Closed Complete' to  Pending in TaskStatusText   
---------------------------------------------------------------------      
*/  
CREATE TRIGGER [dbo].[tr_Update_PatientImmunizations] ON [dbo].[PatientImmunizations]  
       AFTER UPDATE  
AS  
BEGIN  
      SET NOCOUNT ON  
   
      DECLARE @i_ScheduledDays INT  
      SELECT  
          @i_ScheduledDays = ScheduledDays  
      FROM  
          TaskType  
      WHERE  
          TasktypeId = [dbo].[ReturnTaskTypeID]('Immunization')  
  
      IF UPDATE(DueDate)  
         BEGIN  
               UPDATE  
                   Task  
               SET  
                   TaskDueDate = INSERTED.DueDate ,  
                   LastModifiedByUserId = INSERTED.LastModifiedByUserId ,  
                   LastModifiedDate = INSERTED.LastModifiedDate ,  
                   TaskStatusId = CASE   
          --WHEN DATEADD(DD,@ScheduledDays, INSERTED.DueDate) >= GETDATE() THEN  
                                       WHEN INSERTED.DueDate - @i_ScheduledDays > GETDATE() THEN  
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
                   Task  
               INNER JOIN INSERTED  
                   ON Task.PatientImmunizationID = INSERTED.PatientImmunizationID  
                  AND Task.PatientId = INSERTED.PatientId  
       --        INNER JOIN deleted  
       --ON deleted.UserImmunizationID = inserted.ImmunizationID     
             --  INNER JOIN Users   
             --ON Users.UserId = INSERTED.UserId      
               WHERE  
                   INSERTED.ImmunizationDate IS NULL  
               AND Task.TaskStatusId IN (1,2)  
               --AND ((INSERTED.StatusCode  =  'A' AND deleted.StatusCode = 'I') OR (INSERTED.StatusCode  =  'A' AND deleted.StatusCode = 'A'))  
                  
         END  
      IF EXISTS ( SELECT  
                      1  
                  FROM  
                      INSERTED  
                  WHERE  
                      ImmunizationDate IS NOT NULL  
                   OR StatusCode = 'I'  
                   OR IsPatientDeclined = 1 )  
         BEGIN  
           
               UPDATE  
                   Task  
               SET  
                   TaskCompletedDate = INSERTED.ImmunizationDate ,  
                   Comments = INSERTED.Comments ,  
                   TaskStatusId = CASE  
                                       WHEN INSERTED.ImmunizationDate IS NOT NULL THEN  
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
                                  END ,  
                   LastModifiedByUserId = INSERTED.LastModifiedByUserId ,  
                   LastModifiedDate = INSERTED.LastModifiedDate ,  
                   AssignedCareProviderId = INSERTED.AssignedCareProviderId 
               FROM  
                   Task  
               INNER JOIN INSERTED  
                   ON Task.PatientImmunizationID = INSERTED.PatientImmunizationID  
                  AND Task.PatientId = INSERTED.PatientID  
                  AND Task.TaskStatusId IN(1,2)  
             --  INNER JOIN Users   
             --ON Users.UserId = INSERTED.UserId      
         END  
  
  
END  
  

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'List of immunixations given to a patient or declined by the patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserImmunizations Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'PatientImmunizationID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Immunization Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'ImmunizationID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table - Indicates the Patient user id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'PatientID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date of the administration of the Immunization', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'ImmunizationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag indicating that the patient declined the Immunization', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'IsPatientDeclined';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Free form comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'AdverseReactionComments';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Due Date for the administration of the Immunization', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientImmunizations', @level2type = N'COLUMN', @level2name = N'DueDate';

