CREATE TABLE [dbo].[TaskBundleCopyInclude] (
    [TaskBundleCopyIncludeId] [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [TaskBundleID]            [dbo].[KeyID]       NULL,
    [TaskType]                VARCHAR (1)         NULL,
    [GeneralizedID]           [dbo].[KeyID]       NULL,
    [FrequencyNumber]         [dbo].[KeyID]       NULL,
    [Frequency]               VARCHAR (1)         NULL,
    [CopyInclude]             [dbo].[StatusCode]  NULL,
    [StatusCode]              [dbo].[StatusCode]  CONSTRAINT [DF_TaskBundleCopyInclude_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]         [dbo].[KeyID]       NOT NULL,
    [CreatedDate]             [dbo].[UserDate]    CONSTRAINT [DF_TaskBundleCopyInclude_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    [dbo].[KeyID]       NULL,
    [LastModifiedDate]        [dbo].[UserDate]    NULL,
    [ParentTaskBundleId]      [dbo].[KeyID]       NULL,
    [IsConflictResolution]    [dbo].[IsIndicator] NULL,
    [TypeId]                  INT                 NULL,
    CONSTRAINT [PK_TaskBundleCopyInclude] PRIMARY KEY CLUSTERED ([TaskBundleCopyIncludeId] ASC),
    CONSTRAINT [FK_TaskBundleCopyInclude_TaskBundle] FOREIGN KEY ([TaskBundleID]) REFERENCES [dbo].[TaskBundle] ([TaskBundleId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_TaskBundleCopyInclude]
    ON [dbo].[TaskBundleCopyInclude]([TaskBundleID] ASC, [TaskType] ASC, [GeneralizedID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Update_TaskBundleCopyInclude]
Description: This trigger is used to track the history of a TaskBundle modifications from the TaskBundle table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Insert_TaskBundleCopyInclude] ON [dbo].[TaskBundleCopyInclude]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON

      DECLARE @Program TABLE
     (
        ProgramID INT
       ,TaskBundleID INT
     )

      INSERT INTO
          @Program
          SELECT DISTINCT
              ptb.ProgramID
             ,i.TaskBundleId
          FROM
              ProgramTaskBundle ptb
          INNER JOIN inserted i
              ON ptb.TaskBundleID = i.TaskBundleId
          WHERE
              i.CopyInclude = 'I'
      IF
      ( SELECT
            COUNT(*)
        FROM
            @Program ) > 0
         BEGIN

               INSERT INTO
                   ProgramTaskBundle
                   (
                    ProgramID
                   ,TaskBundleID
                   ,TaskType
                   ,GeneralizedID
                   ,FrequencyNumber
                   ,Frequency
                   ,StatusCode
                   ,CreatedByUserId
                   ,IsInclude
                   )
                   SELECT DISTINCT
                       tb.ProgramID
                      ,i.TaskBundleId
                      ,i.TaskType
                      ,i.GeneralizedID
                      ,i.FrequencyNumber
                      ,i.Frequency
                      ,'A'
                      ,i.CreatedByUserId
                      ,1
                   FROM
                       inserted i
                   INNER JOIN @Program tb
                       ON tb.TaskBundleID = i.TaskBundleId
                   WHERE
                       NOT EXISTS ( SELECT
                                        1
                                    FROM
                                        ProgramTaskBundle ptb
                                    WHERE
                                        ptb.ProgramID = tb.ProgramID
                                        AND ptb.GeneralizedID = i.GeneralizedID
                                        --AND ptb.IsInclude = 1 
                                        AND ptb.TaskType = i.TaskType
                                        AND ptb.TaskBundleID = i.TaskBundleID )
                       AND tb.ProgramID IS NOT NULL
                        AND i.copyinclude = 'I'

               UPDATE
                   ProgramTaskBundle
               SET
                   StatusCode = 'A'
                  ,FrequencyNumber = i.FrequencyNumber
                  ,Frequency = i.Frequency
                  ,LastModifiedByUserId = i.CreatedByUserId
                  ,LastModifiedDate = GETDATE()
                  ,IsInclude = 1
               FROM
                   inserted i
                   INNER JOIN @Program tb
                   ON tb.TaskBundleID = i.TaskBundleId
               WHERE
                   ProgramTaskBundle.ProgramID = tb.ProgramID
                   AND ProgramTaskBundle.GeneralizedID = i.GeneralizedID
                   AND ProgramTaskBundle.TaskBundleID = i.TaskBundleId
	      --AND ProgramTaskBundle.IsInclude = 0
                   AND ProgramTaskBundle.TaskType = i.TaskType
                   AND ProgramTaskBundle.StatusCode = 'I'
                   --AND ProgramTaskBundle.IsInclude = 1
                   AND i.copyinclude = 'I'

         END
END

GO
DISABLE TRIGGER [dbo].[tr_Insert_TaskBundleCopyInclude]
    ON [dbo].[TaskBundleCopyInclude];


GO
/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Delete_TaskBundleCopyInclude]
Description: This trigger is used to track the history of a TaskBundle modifications from the TaskBundle table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Delete_TaskBundleCopyInclude] ON [dbo].[TaskBundleCopyInclude]
       AFTER DELETE
AS
BEGIN
      SET NOCOUNT ON


      UPDATE
          ProgramTaskBundle
      SET
          StatusCode = 'I',
          IsInclude = 0
      FROM
          ( SELECT
                ProgramTaskBundleID
            FROM
                ProgramTaskBundle ptb
            INNER JOIN deleted
                ON deleted.TaskBundleId = ptb.TaskBundleID
                   AND deleted.GeneralizedID = ptb.GeneralizedID
                   AND ptb.TaskType = deleted.TaskType
                   --AND ptb.IsInclude = 1
                   AND deleted.CopyInclude = 'I' ) a
      WHERE
          a.ProgramTaskBundleID = ProgramTaskBundle.ProgramTaskBundleID	
     
END

GO
DISABLE TRIGGER [dbo].[tr_Delete_TaskBundleCopyInclude]
    ON [dbo].[TaskBundleCopyInclude];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleCopyInclude', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleCopyInclude', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleCopyInclude', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleCopyInclude', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

