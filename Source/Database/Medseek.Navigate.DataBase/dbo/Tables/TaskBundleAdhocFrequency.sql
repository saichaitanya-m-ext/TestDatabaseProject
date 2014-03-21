CREATE TABLE [dbo].[TaskBundleAdhocFrequency] (
    [TaskBundleAdhocFrequencyID] [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [TaskBundleId]               [dbo].[KeyID]       NULL,
    [AdhocTaskId]                [dbo].[KeyID]       NULL,
    [FrequencyNumber]            INT                 NOT NULL,
    [Frequency]                  VARCHAR (1)         NOT NULL,
    [StatusCode]                 [dbo].[StatusCode]  CONSTRAINT [DF_TaskBundleAdhocFrequency_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]            [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                [dbo].[UserDate]    CONSTRAINT [DF_TaskBundleAdhocFrequency_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedDate]           [dbo].[UserDate]    NULL,
    [LastModifiedByUserId]       [dbo].[KeyID]       NULL,
    [Comments]                   VARCHAR (500)       NULL,
    [ParentTaskBundleID]         [dbo].[KeyID]       NULL,
    [IsConflictResolution]       [dbo].[IsIndicator] NULL,
    [IsSelfTask]                 [dbo].[IsIndicator] NULL,
    [RecurrenceType]             CHAR (1)            CONSTRAINT [DF_TaskBundleAdhocFrequency_RecurrenceType] DEFAULT ('R') NOT NULL,
    CONSTRAINT [PK_TaskBundleAdhocFrequency] PRIMARY KEY CLUSTERED ([TaskBundleAdhocFrequencyID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TaskBundleAdhocFrequency_AdhocTask] FOREIGN KEY ([AdhocTaskId]) REFERENCES [dbo].[AdhocTask] ([AdhocTaskId]),
    CONSTRAINT [FK_TaskBundleAdhocFrequency_TaskBundle] FOREIGN KEY ([TaskBundleId]) REFERENCES [dbo].[TaskBundle] ([TaskBundleId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_TaskBundleAdhocFrequency_AdhocTaskid]
    ON [dbo].[TaskBundleAdhocFrequency]([TaskBundleId] ASC, [AdhocTaskId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Update_TaskBundleAdhocFrequency]
Description: This trigger is used to track the history of a TaskBundle modifications from the TaskBundleAdhocFrequency table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Update_TaskBundleAdhocFrequency] ON dbo.TaskBundleAdhocFrequency
       AFTER UPDATE
AS
BEGIN
      SET NOCOUNT ON

      UPDATE
          TaskBundleHistory
      SET
          AdhocFrequencyList = ISNULL(AdhocFrequencyList , '$$') +  CASE WHEN RIGHT(AdhocFrequencyList,2) <> '$$' THEN '$$' ELSE '' END+
        
			CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleAdhocFrequencyID) + '*'+ CONVERT(VARCHAR(10),inserted.AdhocTaskID) +  '- Name' , isnull(AdhocFrequencyList , '') , 1) = 0 THEN CASE
			WHEN inserted.AdhocTaskID <> deleted.AdhocTaskID THEN CONVERT(VARCHAR,inserted.TaskBundleAdhocFrequencyID) + '*'+ CONVERT(VARCHAR(10),inserted.AdhocTaskID) + '- Name $$'
			ELSE ''
			END
			ELSE ''
			END  + CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleAdhocFrequencyID) + '*'+ CONVERT(VARCHAR(10),inserted.AdhocTaskID) +'- Frequency' , isnull(AdhocFrequencyList , '') , 1) = 0 THEN CASE
			WHEN inserted.FrequencyNumber <> deleted.FrequencyNumber THEN CONVERT(VARCHAR,inserted.TaskBundleAdhocFrequencyID) + '*'+ CONVERT(VARCHAR(10),inserted.AdhocTaskID) +'- Frequency $$'
			ELSE ''
			END
			ELSE ''
			END + CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleAdhocFrequencyID) +'*'+ CONVERT(VARCHAR(10),inserted.AdhocTaskID) + '- UOM' , isnull(AdhocFrequencyList , '') , 1) = 0 THEN CASE
			WHEN inserted.Frequency <> deleted.Frequency THEN CONVERT(VARCHAR,inserted.TaskBundleAdhocFrequencyID) + '*'+ CONVERT(VARCHAR(10),inserted.AdhocTaskID) +'- UOM $$'
			ELSE ''
			END
			ELSE ''
			END + CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleAdhocFrequencyID) + '*'+ CONVERT(VARCHAR(10),inserted.AdhocTaskID) +'- Status' , isnull(AdhocFrequencyList , '') , 1) = 0 THEN CASE
			WHEN inserted.StatusCode <> deleted.StatusCode THEN CONVERT(VARCHAR,inserted.TaskBundleAdhocFrequencyID)+  '*'+ CONVERT(VARCHAR(10),inserted.AdhocTaskID) +'- Status $$'
			ELSE ''
			END
			ELSE ''
			END  + CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleAdhocFrequencyID) + '*'+ CONVERT(VARCHAR(10),inserted.AdhocTaskID) +'- Comments' , isnull(AdhocFrequencyList , '') , 1) = 0 THEN CASE
			WHEN inserted.Comments <> deleted.Comments THEN CONVERT(VARCHAR,inserted.TaskBundleAdhocFrequencyID) + '*'+ CONVERT(VARCHAR(10),inserted.AdhocTaskID) +'- Comments $$'
			ELSE ''
			END
			ELSE ''
			END 
       FROM
          inserted
          INNER JOIN deleted
          ON deleted.TaskBundleId = inserted.TaskBundleId
          INNER JOIN TaskBundle
          ON TaskBundle.TaskBundleId = inserted.TaskBundleId
      WHERE
          TaskBundleHistory.TaskBundleId = inserted.TaskBundleId
          AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , TaskBundle.DefinitionVersion) - .1)
          
          
          -----Updating the individual tasks in the dependent tables which are updating from the update stored procedure of TaskBundleAdhocFrequency
      IF EXISTS ( SELECT
                      1
                  FROM
                      inserted
                  WHERE
                      IsSelfTask = 1 )
         BEGIN
  --- Updating the individual tasks which are included in the TaskBundleCopyInclude
               UPDATE
                   TaskBundleCopyInclude
               SET
                   GeneralizedID = inserted.AdhocTaskID
                  ,FrequencyNumber = inserted.FrequencyNumber
                  ,Frequency = inserted.Frequency
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleAdhocFrequencyID = deleted.TaskBundleAdhocFrequencyID
               WHERE
                   deleted.AdhocTaskID = TaskBundleCopyInclude.GeneralizedID
                   AND TaskBundleCopyInclude.ParentTaskBundleId = inserted.TaskBundleId
                   AND TaskBundleCopyInclude.CopyInclude = 'I'
                   AND TaskBundleCopyInclude.TaskType = 'O'
                   
                   
                   --******Updating the individual tasks which are not included in the TaskBundleCopyInclude 
                   
                UPDATE
                   TaskBundleCopyInclude
               SET
                   GeneralizedID = inserted.AdhocTaskID
                  ,FrequencyNumber = inserted.FrequencyNumber
                  ,Frequency = inserted.Frequency
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleAdhocFrequencyID = deleted.TaskBundleAdhocFrequencyID
               WHERE
                   deleted.AdhocTaskID = TaskBundleCopyInclude.GeneralizedID
                   AND TaskBundleCopyInclude.TaskBundleId = inserted.TaskBundleId
                   AND TaskBundleCopyInclude.CopyInclude IN ('C','O')
                   AND TaskBundleCopyInclude.TaskType = 'O'    
          
          --- Updating the individual tasks which are not included in the ProgramTaskBundle
               UPDATE
                   ProgramTaskBundle
               SET
                   GeneralizedID = inserted.AdhocTaskID
                  ,FrequencyNumber = inserted.FrequencyNumber
                  ,Frequency = inserted.Frequency
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleAdhocFrequencyID = deleted.TaskBundleAdhocFrequencyID
               WHERE
                   deleted.AdhocTaskID = ProgramTaskBundle.GeneralizedID
                   AND ProgramTaskBundle.TaskBundleId = inserted.TaskBundleId
                   AND ProgramTaskBundle.IsInclude = 0
                   AND ProgramTaskBundle.TaskType = 'O'
          --- Updating the individual tasks which are included
               UPDATE
                   ProgramTaskBundle
               SET
                   GeneralizedID = inserted.AdhocTaskID
                  ,FrequencyNumber = inserted.FrequencyNumber
                  ,Frequency = inserted.Frequency
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleAdhocFrequencyID = deleted.TaskBundleAdhocFrequencyID
               WHERE
                   deleted.AdhocTaskID = ProgramTaskBundle.GeneralizedID
                   AND inserted.TaskBundleId = ( SELECT
                                                     ParentTaskBundleID
                                                 FROM
                                                     TaskBundleCopyInclude tbc
                                                 WHERE
                        tbc.TaskBundleID = ProgramTaskBundle.TaskBundleID
                                                     AND tbc.TaskType = ProgramTaskBundle.TaskType
                                                     AND tbc.GeneralizedID = ProgramTaskBundle.GeneralizedID
                                                     AND tbc.CopyInclude = 'I'
                                                     AND tbc.TaskType = 'O' )
                   AND ProgramTaskBundle.IsInclude = 1
                   AND ProgramTaskBundle.TaskType = 'O'



         END
          
      
          --Updating the Frequencyes of self tasks which are updating by the following sp [usp_TaskBundleCopyIncludeDependencies_Insert]
      IF EXISTS ( SELECT
                      1
                  FROM
                      inserted
                  WHERE
                      IsSelfTask = 0 )
         BEGIN
               UPDATE
                   ProgramTaskBundle
               SET
                   FrequencyNumber = inserted.FrequencyNumber
                  ,Frequency = inserted.Frequency
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleAdhocFrequencyID = deleted.TaskBundleAdhocFrequencyID
               WHERE
                   deleted.AdhocTaskID = ProgramTaskBundle.GeneralizedID
                   AND ProgramTaskBundle.TaskBundleId = inserted.TaskBundleId
                   AND ProgramTaskBundle.IsInclude = 0
                   AND ProgramTaskBundle.TaskType = 'O'
         END


END

GO
/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Insert_TaskBundleAdhocFrequency]
Description: This trigger is used to track the history of a AdhocFrequency modifications from the TaskBundleAdhocFrequency table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/
CREATE TRIGGER [dbo].[tr_Insert_TaskBundleAdhocFrequency] ON dbo.TaskBundleAdhocFrequency
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON

	IF EXISTS (
			SELECT 1
			FROM TaskBundleHistory
			INNER JOIN inserted
				ON inserted.TaskBundleId = TaskBundleHistory.TaskBundleId
			)
	BEGIN
	
		UPDATE TaskBundleHistory
		SET AdhocFrequencyList = ISNULL(AdhocFrequencyList, '$$') + CASE 
				WHEN RIGHT(AdhocFrequencyList, 2) <> '$$'
					THEN '$$'
				ELSE ''
				END + ISNULL(CASE 
				WHEN CHARINDEX(CONVERT(VARCHAR(10), inserted.AdhocTaskID) + '- Added', isnull(AdhocFrequencyList, ''), 1) = 0
					THEN CONVERT(VARCHAR(10), inserted.TaskBundleAdhocFrequencyID) + '*' + CONVERT(VARCHAR(10), inserted.AdhocTaskID) + '- Added $$'
				END,'')
		FROM inserted
		INNER JOIN TaskBundle
			ON TaskBundle.TaskBundleId = inserted.TaskBundleId
		WHERE TaskBundleHistory.TaskBundleId = inserted.TaskBundleId
			AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR, CONVERT(DECIMAL(10, 1), TaskBundle.DefinitionVersion) - .1)
	END

	DECLARE @Program TABLE (
		ProgramID INT
		,TaskBundleID INT
		)

	INSERT INTO @Program
	SELECT DISTINCT ptb.ProgramID
		,i.TaskBundleId
	FROM ProgramTaskBundle ptb
	INNER JOIN inserted i
		ON ptb.TaskBundleID = i.TaskBundleId

	IF (
			SELECT COUNT(*)
			FROM @Program
			) > 0
	BEGIN
		--Inserting into the programtaskbundle table which are newly added to the particular task bundle
		INSERT INTO ProgramTaskBundle (
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
		SELECT tb.ProgramID
			,i.TaskBundleId
			,'O'
			,i.AdhocTaskId
			,i.FrequencyNumber
			,i.Frequency
			,'A'
			,i.CreatedByUserId
			,0
		FROM inserted i
		INNER JOIN @Program tb
			ON tb.TaskBundleID = i.TaskBundleId
		WHERE NOT EXISTS (
				SELECT 1
				FROM ProgramTaskBundle ptb
				WHERE ptb.ProgramID = tb.ProgramID
					AND ptb.GeneralizedID = i.AdhocTaskId
					AND ptb.IsInclude = 0
					AND ptb.TaskType = 'O'
					AND ptb.TaskBundleID = i.TaskBundleId
				)
			AND tb.ProgramID IS NOT NULL

		INSERT INTO ProgramPatientTaskConflict (
			ProgramTaskBundleId
			,PatientUserID
			,CreatedByUserId
			)
		SELECT DISTINCT ProgramTaskBundle.ProgramTaskBundleID
			,PatientProgram.PatientID
			,inserted.CreatedByUserId
		FROM PatientProgram
		INNER JOIN ProgramTaskBundle
			ON ProgramTaskBundle.ProgramID = PatientProgram.ProgramId
		INNER JOIN INSERTED
			ON inserted.TaskBundleId = ProgramTaskBundle.TaskBundleID
				AND inserted.AdhocTaskId = ProgramTaskBundle.GeneralizedID
		INNER JOIN @Program p
			ON p.ProgramID = ProgramTaskBundle.ProgramID
		WHERE PatientProgram.StatusCode = 'A'
			AND ProgramTaskBundle.StatusCode = 'A'
			AND ProgramTaskBundle.TaskType = 'O'
			AND PatientProgram.PatientID IS NOT NULL
			AND NOT EXISTS (
				SELECT 1
				FROM ProgramPatientTaskConflict pptc
				WHERE pptc.ProgramTaskBundleId = ProgramTaskBundle.ProgramTaskBundleID
					AND pptc.PatientUserID = PatientProgram.PatientID
				)

		--if the record found in the programtaskbundle with the status as inative then it will enable the statuscode as active
		UPDATE ProgramTaskBundle
		SET StatusCode = 'A'
			,FrequencyNumber = i.FrequencyNumber
			,Frequency = i.Frequency
			,LastModifiedByUserId = i.CreatedByUserId
			,LastModifiedDate = GETDATE()
		FROM inserted i
		INNER JOIN @Program tb
			ON tb.TaskBundleID = i.TaskBundleId
		WHERE ProgramTaskBundle.ProgramID = tb.ProgramID
			AND ProgramTaskBundle.GeneralizedID = i.AdhocTaskId
			AND ProgramTaskBundle.TaskBundleID = i.TaskBundleId
			--AND ProgramTaskBundle.IsInclude = 0
			AND ProgramTaskBundle.TaskType = 'O'
			AND ProgramTaskBundle.StatusCode = 'I'
	END
END

GO
/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Delete_TaskBundleAdhocFrequency]
Description: This trigger is used to track the history of a TaskBundle modifications from the TaskBundle table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Delete_TaskBundleAdhocFrequency] ON dbo.TaskBundleAdhocFrequency
       AFTER DELETE
AS
BEGIN
      SET NOCOUNT ON

      ---- Delete the records in taskbunclecopyinclude table which are included if the reord is deleted from TaskBundleAdhocFrequency
      DELETE  FROM
              TaskBundleCopyInclude
      WHERE
              EXISTS ( SELECT
                           1
                       FROM
                           deleted
                       WHERE
                           deleted.TaskBundleId = TaskBundleCopyInclude.ParentTaskBundleId
                           AND deleted.AdhocTaskID = TaskBundleCopyInclude.GeneralizedID )
              AND TaskBundleCopyInclude.TaskType = 'O'
              AND TaskBundleCopyInclude.CopyInclude = 'I'

      DELETE  FROM
              TaskBundleCopyInclude
      WHERE
              EXISTS ( SELECT
                           1
                       FROM
                           deleted
                       WHERE
                           deleted.TaskBundleId = TaskBundleCopyInclude.TaskBundleID
                           AND deleted.AdhocTaskID = TaskBundleCopyInclude.GeneralizedID )
              AND TaskBundleCopyInclude.TaskType = 'O'
              AND TaskBundleCopyInclude.CopyInclude IN ( 'C' , 'O' )
      
      ---- Delete the records in ProgramTaskBundle table which are self tasks if the reord is deleted from TaskBundleAdhocFrequency

      UPDATE
          ProgramTaskBundle
      SET
          StatusCode = 'I'
         ,LastModifiedDate = GETDATE()
         ,LastModifiedByUserId = deleted.LastModifiedByUserId
      FROM
          deleted
      WHERE
          deleted.TaskBundleId = ProgramTaskBundle.TaskBundleID
          AND deleted.AdhocTaskID = ProgramTaskBundle.GeneralizedID
          AND ProgramTaskBundle.TaskType = 'O'
          AND ProgramTaskBundle.IsInclude = 0
      
      ---- Delete the records in ProgramTaskBundle table which are included tasks if the reord is deleted from TaskBundleAdhocFrequency
      -- through the trigger [tr_Delete_TaskBundleCopyInclude]


END

GO
DISABLE TRIGGER [dbo].[tr_Delete_TaskBundleAdhocFrequency]
    ON [dbo].[TaskBundleAdhocFrequency];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleAdhocFrequency', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleAdhocFrequency', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleAdhocFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleAdhocFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';

