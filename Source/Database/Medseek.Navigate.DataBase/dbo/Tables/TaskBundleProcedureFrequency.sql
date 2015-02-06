CREATE TABLE [dbo].[TaskBundleProcedureFrequency] (
    [TaskBundleProcedureFrequencyId] [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [TaskBundleId]                   [dbo].[KeyID]       NOT NULL,
    [CodeGroupingId]                 [dbo].[KeyID]       NOT NULL,
    [StatusCode]                     [dbo].[StatusCode]  CONSTRAINT [DF_TaskBundleProcedureFrequency_StatusCode] DEFAULT ('A') NOT NULL,
    [FrequencyNumber]                [dbo].[KeyID]       NULL,
    [Frequency]                      VARCHAR (1)         NULL,
    [NeverSchedule]                  BIT                 NULL,
    [ExclusionReason]                VARCHAR (100)       NULL,
    [IsPreventive]                   [dbo].[IsIndicator] CONSTRAINT [DF_TaskBundleProcedureFrequency_IsPreventive] DEFAULT ((0)) NULL,
    [FrequencyCondition]             [dbo].[SourceName]  NULL,
    [CreatedByUserId]                [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                    [dbo].[UserDate]    CONSTRAINT [DF_TaskBundleProcedureFrequency_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]           [dbo].[KeyID]       NULL,
    [LastModifiedDate]               [dbo].[UserDate]    NULL,
    [ParentTaskBundleID]             [dbo].[KeyID]       NULL,
    [IsConflictResolution]           [dbo].[IsIndicator] NULL,
    [IsSelfTask]                     [dbo].[IsIndicator] NULL,
    [RecurrenceType]                 CHAR (1)            CONSTRAINT [DF_TaskBundleProcedureFrequency_RecurrenceType] DEFAULT ('R') NOT NULL,
    CONSTRAINT [PK_TaskBundleProcedureFrequency] PRIMARY KEY CLUSTERED ([TaskBundleProcedureFrequencyId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TaskBundleProcedureFrequency_CodeGrouping] FOREIGN KEY ([CodeGroupingId]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_TaskBundleProcedureFrequency_TaskBundle] FOREIGN KEY ([TaskBundleId]) REFERENCES [dbo].[TaskBundle] ([TaskBundleId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TaskBundleProcedureFrequency_TaskbundleID_ProcedureID]
    ON [dbo].[TaskBundleProcedureFrequency]([TaskBundleId] ASC, [CodeGroupingId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Delete_TaskBundleProcedureFrequency]
Description: This trigger is used to track the history of a TaskBundle modifications from the TaskBundle table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Delete_TaskBundleProcedureFrequency] ON [dbo].[TaskBundleProcedureFrequency]
       AFTER DELETE
AS
BEGIN
      SET NOCOUNT ON

      ---- Delete the records in taskbunclecopyinclude table which are included if the reord is deleted from TaskBundleProcedureFrequency
      DELETE  FROM
              TaskBundleCopyInclude
      WHERE
              EXISTS ( SELECT
                           1
                       FROM
                           deleted
                       WHERE
                           deleted.TaskBundleId = TaskBundleCopyInclude.ParentTaskBundleId
                           AND deleted.CodeGroupingId = TaskBundleCopyInclude.GeneralizedID )
              AND TaskBundleCopyInclude.TaskType = 'P'
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
                           AND deleted.CodeGroupingId = TaskBundleCopyInclude.GeneralizedID )
              AND TaskBundleCopyInclude.TaskType = 'P'
              AND TaskBundleCopyInclude.CopyInclude IN ( 'C' , 'O' )
      
      ---- Delete the records in ProgramTaskBundle table which are self tasks if the reord is deleted from TaskBundleProcedureFrequency

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
          AND deleted.CodeGroupingId = ProgramTaskBundle.GeneralizedID
          AND ProgramTaskBundle.TaskType = 'P'
          AND ProgramTaskBundle.IsInclude = 0
      
      ---- Delete the records in ProgramTaskBundle table which are included tasks if the reord is deleted from TaskBundleProcedureFrequency
      -- through the trigger [tr_Delete_TaskBundleCopyInclude]


END














GO

/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_INSERT_TaskBundleProcedureFrequency]
Description: This trigger is used to track the history of a TaskBundle modifications from the TaskBundle table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/
CREATE TRIGGER [dbo].[tr_Insert_TaskBundleProcedureFrequency] ON [dbo].[TaskBundleProcedureFrequency]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON

	UPDATE TaskBundleHistory
	SET CPTList = ISNULL(CPTList, '$$') + CASE 
			WHEN RIGHT(CPTList, 2) <> '$$'
				THEN '$$'
			ELSE ''
			END + ISNULL(CASE 
			WHEN CHARINDEX(CONVERT(VARCHAR(10), inserted.CodeGroupingId) + '- Added', isnull(CPTList, ''), 1) = 0
				THEN CONVERT(VARCHAR(10), inserted.TaskBundleProcedureFrequencyID) + '*' + CONVERT(VARCHAR(10), inserted.CodeGroupingId) + '- Added $$'
			END,'')
	FROM inserted
	INNER JOIN TaskBundle
		ON TaskBundle.TaskBundleId = inserted.TaskBundleId
	WHERE TaskBundleHistory.TaskBundleId = inserted.TaskBundleId
		AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR, CONVERT(DECIMAL(10, 1), TaskBundle.DefinitionVersion) - .1)

	--Getting the dependent Program List to assign the newly added task for that task bundle
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
	INNER JOIN Program P
		ON p.ProgramId = ptb.ProgramID
	WHERE p.StatusCode = 'A'

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
			,'P'
			,i.CodeGroupingId
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
					AND ptb.GeneralizedID = i.CodeGroupingId
					AND ptb.IsInclude = 0
					AND ptb.TaskType = 'P'
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
				AND inserted.CodeGroupingId = ProgramTaskBundle.GeneralizedID
		INNER JOIN @Program p
			ON p.ProgramID = ProgramTaskBundle.ProgramID
		WHERE PatientProgram.StatusCode = 'A'
			AND ProgramTaskBundle.StatusCode = 'A'
			AND ProgramTaskBundle.TaskType = 'P'
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
			AND ProgramTaskBundle.GeneralizedID = i.CodeGroupingId
			AND ProgramTaskBundle.TaskBundleID = i.TaskBundleId
			--AND ProgramTaskBundle.IsInclude = 0
			AND ProgramTaskBundle.TaskType = 'P'
			AND ProgramTaskBundle.StatusCode = 'I'
	END
END

GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Update_TaskBundleProcedureFrequency]
Description: This trigger is used to track the history of a TaskBundle modifications from the TaskBundle table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Update_TaskBundleProcedureFrequency] ON [dbo].[TaskBundleProcedureFrequency]
       AFTER UPDATE
AS
BEGIN
      SET NOCOUNT ON

      UPDATE
          TaskBundleHistory
      SET
          CPTList = ISNULL(CPTList , '$$') +  CASE WHEN RIGHT(CPTList,2) <> '$$' THEN '$$' ELSE '' END+
        
			CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId) + '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId) + '- Name' , isnull(CPTList , '') , 1) = 0 THEN CASE
			WHEN inserted.CodeGroupingId <> deleted.CodeGroupingId THEN CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId)+ '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId)+ '- Name $$'
			ELSE ''
			END
			ELSE ''
			END  + CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId) + '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId)+ '- Frequency' , isnull(CPTList , '') , 1) = 0 THEN CASE
			WHEN inserted.FrequencyNumber <> deleted.FrequencyNumber THEN CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId) + '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId)+ '- Frequency $$'
			ELSE ''
			END
			ELSE ''
			END + CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId) + '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId)+ '- UOM' , isnull(CPTList , '') , 1) = 0 THEN CASE
			WHEN inserted.Frequency <> deleted.Frequency THEN CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId)+ '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId) + '- UOM $$'
			ELSE ''
			END
			ELSE ''
			END + CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId) + '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId)+ '- Status' , isnull(CPTList , '') , 1) = 0 THEN CASE
			WHEN inserted.StatusCode <> deleted.StatusCode THEN CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId)+ '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId) + '- Status $$'
			ELSE ''
			END
			ELSE ''
			END  + CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId)+ '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId) + '- Never Schedule' , isnull(CPTList , '') , 1) = 0 THEN CASE
			WHEN inserted.NeverSchedule <> deleted.NeverSchedule THEN CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId) + '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId)+ '- Never Schedule $$'
			ELSE ''
			END
			ELSE ''
			END  + CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId)+ '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId) + '- Exclusion Reason' , isnull(CPTList , '') , 1) = 0 THEN CASE
			WHEN inserted.ExclusionReason <> deleted.ExclusionReason THEN CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId) + '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId)+ '- Exclusion Reason $$'
			ELSE ''
			END
			ELSE ''
			END + CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId) + '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId)+ '- Preventive' , isnull(CPTList , '') , 1) = 0 THEN CASE
			WHEN inserted.IsPreventive <> deleted.IsPreventive THEN CONVERT(VARCHAR,inserted.TaskBundleProcedureFrequencyId) + '*'+ CONVERT(VARCHAR(10),inserted.CodeGroupingId)+ '- Preventive $$'
			ELSE ''
			END
			ELSE ''
			END 
      FROM
          inserted
          INNER JOIN deleted
          ON deleted.TaskBundleId = inserted.TaskBundleId
          inner join TaskBundle
          on TaskBundle.TaskBundleId = inserted.TaskBundleId
      WHERE
          TaskBundleHistory.TaskBundleId = inserted.TaskBundleId
          AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , TaskBundle.DefinitionVersion) - .1)
		 -----Updating the individual tasks in the dependent tables which are updating from the update stored procedure of TaskBundleQuestionnaireFrequency
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
                   GeneralizedID = inserted.CodeGroupingId
                  ,FrequencyNumber = inserted.FrequencyNumber
                  ,Frequency = inserted.Frequency
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleProcedureFrequencyID = deleted.TaskBundleProcedureFrequencyID
               WHERE
                   deleted.CodeGroupingId = TaskBundleCopyInclude.GeneralizedID
                   AND TaskBundleCopyInclude.ParentTaskBundleId = inserted.TaskBundleId
                   AND TaskBundleCopyInclude.CopyInclude = 'I'
                   AND TaskBundleCopyInclude.TaskType = 'P'
                   
                   
                   --******Updating the individual tasks which are not included in the TaskBundleCopyInclude 
                   
                UPDATE
                   TaskBundleCopyInclude
               SET
                   GeneralizedID = inserted.CodeGroupingId
                  ,FrequencyNumber = inserted.FrequencyNumber
                  ,Frequency = inserted.Frequency
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleProcedureFrequencyID = deleted.TaskBundleProcedureFrequencyID
               WHERE
                   deleted.CodeGroupingId = TaskBundleCopyInclude.GeneralizedID
                   AND TaskBundleCopyInclude.TaskBundleId = inserted.TaskBundleId
                   AND TaskBundleCopyInclude.CopyInclude IN ('C','O')
                   AND TaskBundleCopyInclude.TaskType = 'P'    
          
          --- Updating the individual tasks which are not included in the ProgramTaskBundle
               UPDATE
                   ProgramTaskBundle
               SET
                   GeneralizedID = inserted.CodeGroupingId
                  ,FrequencyNumber = inserted.FrequencyNumber
                  ,Frequency = inserted.Frequency
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleProcedureFrequencyID = deleted.TaskBundleProcedureFrequencyID
               WHERE
                   deleted.CodeGroupingId = ProgramTaskBundle.GeneralizedID
                   AND ProgramTaskBundle.TaskBundleId = inserted.TaskBundleId
                   AND ProgramTaskBundle.IsInclude = 0
                   AND ProgramTaskBundle.TaskType = 'P'
          --- Updating the individual tasks which are included
               UPDATE
                   ProgramTaskBundle
               SET
                   GeneralizedID = inserted.CodeGroupingId
                  ,FrequencyNumber = inserted.FrequencyNumber
                  ,Frequency = inserted.Frequency
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleProcedureFrequencyID = deleted.TaskBundleProcedureFrequencyID
               WHERE
                   deleted.CodeGroupingId = ProgramTaskBundle.GeneralizedID
                   AND inserted.TaskBundleId = ( SELECT
                                                     ParentTaskBundleID
                                                 FROM
                                                     TaskBundleCopyInclude tbc
                                                 WHERE
                                                     tbc.TaskBundleID = ProgramTaskBundle.TaskBundleID
                                                     AND tbc.TaskType = ProgramTaskBundle.TaskType
                                                     AND tbc.GeneralizedID = ProgramTaskBundle.GeneralizedID
                                                     AND tbc.CopyInclude = 'I'
                                                     AND tbc.TaskType = 'P' )
                   AND ProgramTaskBundle.IsInclude = 1
                   AND ProgramTaskBundle.TaskType = 'P'



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
                   ON inserted.TaskBundleProcedureFrequencyID = deleted.TaskBundleProcedureFrequencyID
               WHERE
                   deleted.CodeGroupingId = ProgramTaskBundle.GeneralizedID
                   AND ProgramTaskBundle.TaskBundleId = inserted.TaskBundleId
                   AND ProgramTaskBundle.IsInclude = 0
                   AND ProgramTaskBundle.TaskType = 'P'
         END
END








GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureFrequency', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureFrequency', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

