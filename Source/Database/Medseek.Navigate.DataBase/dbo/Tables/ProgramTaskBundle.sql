CREATE TABLE [dbo].[ProgramTaskBundle] (
    [ProgramTaskBundleID]  [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [ProgramID]            [dbo].[KeyID]       NOT NULL,
    [TaskBundleID]         [dbo].[KeyID]       NOT NULL,
    [TaskType]             VARCHAR (1)         NOT NULL,
    [GeneralizedID]        INT                 NOT NULL,
    [FrequencyNumber]      INT                 NULL,
    [Frequency]            VARCHAR (1)         NULL,
    [StatusCode]           [dbo].[StatusCode]  CONSTRAINT [DF_ProgramTaskBundle_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_ProgramTaskBundle_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    [IsInclude]            [dbo].[IsIndicator] NULL,
    CONSTRAINT [PK_ProgramTaskBundle] PRIMARY KEY CLUSTERED ([ProgramTaskBundleID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_ProgramTaskBundle_ProgramID] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId]),
    CONSTRAINT [FK_ProgramTaskBundle_TaskBundleID] FOREIGN KEY ([TaskBundleID]) REFERENCES [dbo].[TaskBundle] ([TaskBundleId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ProgramTaskBundle]
    ON [dbo].[ProgramTaskBundle]([ProgramID] ASC, [TaskBundleID] ASC, [TaskType] ASC, [GeneralizedID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Insert_ProgramTaskBundle]
Description:  This trigger is used to wirte the tasks for Patient Adhoc tasks                   
When   Who    Action                      
29/Apr/2010  Rathnam  Created                      
---------------------------------------------------------------------      
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
---------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Insert_ProgramTaskBundle] ON [dbo].[ProgramTaskBundle]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON

      INSERT INTO
          ProgramTaskTypeCommunication
          (
            ProgramTaskBundleID
          ,ProgramID
          ,TaskTypeID
          ,GeneralizedID
          ,CommunicationSequence
          ,CommunicationTypeID
          ,CommunicationAttemptDays
          ,NoOfDaysBeforeTaskClosedIncomplete
          ,CommunicationTemplateID
          ,StatusCode
          ,CreatedByUserId
          ,CreatedDate
          ,RemainderState
          )
          SELECT DISTINCT
              ptb.ProgramTaskBundleID
             ,ptb.ProgramID
             ,ttc.TaskTypeID
             ,ptb.GeneralizedID
             ,ttc.CommunicationSequence
             ,ttc.CommunicationTypeID
             ,ttc.CommunicationAttemptDays
             ,ttc.NoOfDaysBeforeTaskClosedIncomplete
             ,ttc.CommunicationTemplateID
             ,'A'
             ,ptb.CreatedByUserID
             ,Getdate()
             ,ttc.RemainderState
          FROM
              TaskTypeCommunications ttc
          INNER JOIN INSERTED ptb
              ON ttc.TaskTypeID = CASE WHEN ptb.TaskType = 'O' THEN (SELECT TaskTypeID FROM TaskType WHERE TaskTypeName = 'Other Tasks')
									   WHEN ptb.TaskType = 'P' THEN (SELECT TaskTypeID FROM TaskType WHERE TaskTypeName = 'Schedule Procedure')
									   WHEN ptb.TaskType = 'Q' THEN (SELECT TaskTypeID FROM TaskType WHERE TaskTypeName = 'Questionnaire')
									   WHEN ptb.TaskType = 'E' THEN (SELECT TaskTypeID FROM TaskType WHERE TaskTypeName = 'Patient Education Material')
								   END
          WHERE
              ttc.TaskTypeGeneralizedID IS NOT NULL
              AND ttc.StatusCode = 'A'
              AND ttc.TaskTypeGeneralizedID = ptb.GeneralizedID
              AND NOT EXISTS ( SELECT
                                   1
                               FROM
                                   ProgramTaskTypeCommunication ptc
                               WHERE
                                   ptc.ProgramID = ptb.ProgramID
                                   AND ptc.GeneralizedID = ptb.GeneralizedID
                                   AND ptc.TaskTypeID = ttc.TaskTypeID )
END

GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramTaskBundle', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramTaskBundle', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramTaskBundle', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramTaskBundle', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

