CREATE TABLE [dbo].[TaskBundleEducationMaterial] (
    [TaskBundleEducationMaterialId] INT                 IDENTITY (1, 1) NOT NULL,
    [TaskBundleId]                  [dbo].[KeyID]       NULL,
    [EducationMaterialID]           [dbo].[KeyID]       NOT NULL,
    [StatusCode]                    [dbo].[StatusCode]  CONSTRAINT [DF_TaskBundleEducationMaterial_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]               [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                   [dbo].[UserDate]    CONSTRAINT [DF_TaskBundleEducationMaterial_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          [dbo].[KeyID]       NULL,
    [LastModifiedDate]              [dbo].[UserDate]    NULL,
    [ParentTaskBundleID]            [dbo].[KeyID]       NULL,
    [Comments]                      VARCHAR (500)       NULL,
    [IsConflictResolution]          BIT                 NULL,
    [IsSelfTask]                    [dbo].[IsIndicator] NULL,
    CONSTRAINT [PK_TaskBundleEducationMaterial] PRIMARY KEY CLUSTERED ([TaskBundleEducationMaterialId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TaskBundleEducationMaterial_EducationMaterial] FOREIGN KEY ([EducationMaterialID]) REFERENCES [dbo].[EducationMaterial] ([EducationMaterialID]),
    CONSTRAINT [FK_TaskBundleEducationMaterial_TaskBundle] FOREIGN KEY ([TaskBundleId]) REFERENCES [dbo].[TaskBundle] ([TaskBundleId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TaskBundleEducationMaterial_TaskBundleId_EducationMaterialID]
    ON [dbo].[TaskBundleEducationMaterial]([TaskBundleId] ASC, [EducationMaterialID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Update_TaskbundleEducationMaterial]
Description: This trigger is used to track the history of a Library modifications from the TaskBundleEducationMaterial table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Update_TaskbundleEducationMaterial] ON [dbo].[TaskBundleEducationMaterial]
       AFTER UPDATE
AS
BEGIN
      SET NOCOUNT ON

      UPDATE
          TaskBundleHistory
      SET
          PEMList = ISNULL(PEMList , '') +ISNULL(PEMList , '$$') +  CASE WHEN RIGHT(PEMList,2) <> '$$' THEN '$$' ELSE '' END+
          CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleEducationMaterialID) + '*'+ CONVERT(VARCHAR(10),inserted.EducationMaterialID) +  '- Name' , isnull(PEMList , '') , 1) = 0 THEN CASE
			WHEN inserted.EducationMaterialID <> deleted.EducationMaterialID THEN CONVERT(VARCHAR,inserted.TaskBundleEducationMaterialID) + '*'+ CONVERT(VARCHAR(10),inserted.EducationMaterialID) + '- Name $$'
			ELSE ''
			END
			ELSE ''
			END  +
			CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleEducationMaterialID) + '*'+ CONVERT(VARCHAR(10),inserted.EducationMaterialID) +'- Status' , isnull(PEMList , '') , 1) = 0 THEN CASE
			WHEN inserted.StatusCode <> deleted.StatusCode THEN CONVERT(VARCHAR,inserted.TaskBundleEducationMaterialID)+  '*'+ CONVERT(VARCHAR(10),inserted.EducationMaterialID) +'- Status $$'
			ELSE ''
			END
			ELSE ''
			END  + CASE
			WHEN CHARINDEX(CONVERT(VARCHAR,inserted.TaskBundleEducationMaterialID) + '*'+ CONVERT(VARCHAR(10),inserted.EducationMaterialID) +'- Comments' , isnull(PEMList , '') , 1) = 0 THEN CASE
			WHEN inserted.Comments <> deleted.Comments THEN CONVERT(VARCHAR,inserted.TaskBundleEducationMaterialID) + '*'+ CONVERT(VARCHAR(10),inserted.EducationMaterialID) +'- Comments $$'
			ELSE ''
			END
			ELSE ''
			END 
      FROM
          inserted
          INNER JOIN deleted
          ON deleted.EducationMaterialID = inserted.EducationMaterialID
          INNER JOIN TaskBundle
          ON TaskBundle.TaskBundleId = inserted.TaskBundleId
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
                   GeneralizedID = inserted.EducationMaterialID
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleEducationMaterialId = deleted.TaskBundleEducationMaterialId
               WHERE
                   deleted.EducationMaterialID = TaskBundleCopyInclude.GeneralizedID
                   AND TaskBundleCopyInclude.ParentTaskBundleId = inserted.TaskBundleId
                   AND TaskBundleCopyInclude.CopyInclude = 'I'
                   AND TaskBundleCopyInclude.TaskType = 'E'
                   
                   
                   --******Updating the individual tasks which are not included in the TaskBundleCopyInclude 
                   
                UPDATE
                   TaskBundleCopyInclude
               SET
                   GeneralizedID = inserted.EducationMaterialID
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleEducationMaterialId = deleted.TaskBundleEducationMaterialId
               WHERE
                   deleted.EducationMaterialID = TaskBundleCopyInclude.GeneralizedID
                   AND TaskBundleCopyInclude.TaskBundleId = inserted.TaskBundleId
                   AND TaskBundleCopyInclude.CopyInclude IN ('C','O')
                   AND TaskBundleCopyInclude.TaskType = 'E'    
          
          --- Updating the individual tasks which are not included in the ProgramTaskBundle
               UPDATE
                   ProgramTaskBundle
               SET
                   GeneralizedID = inserted.EducationMaterialID
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleEducationMaterialId = deleted.TaskBundleEducationMaterialId
               WHERE
                   deleted.EducationMaterialID = ProgramTaskBundle.GeneralizedID
                   AND ProgramTaskBundle.TaskBundleId = inserted.TaskBundleId
                   AND ProgramTaskBundle.IsInclude = 0
                   AND ProgramTaskBundle.TaskType = 'E'
          --- Updating the individual tasks which are included
               UPDATE
                   ProgramTaskBundle
               SET
                   GeneralizedID = inserted.EducationMaterialID
                  ,StatusCode = inserted.StatusCode
                  ,LastModifiedByUserId = inserted.LastModifiedByUserId
                  ,LastModifiedDate = GETDATE()
               FROM
                   inserted
                   INNER JOIN deleted
                   ON inserted.TaskBundleEducationMaterialId = deleted.TaskBundleEducationMaterialId
               WHERE
                   deleted.EducationMaterialID = ProgramTaskBundle.GeneralizedID
                   AND inserted.TaskBundleId = ( SELECT
                                                     ParentTaskBundleID
                                                 FROM
                                                     TaskBundleCopyInclude tbc
                                                 WHERE
                                                     tbc.TaskBundleID = ProgramTaskBundle.TaskBundleID
                                                     AND tbc.TaskType = ProgramTaskBundle.TaskType
                                                     AND tbc.GeneralizedID = ProgramTaskBundle.GeneralizedID
                                                     AND tbc.CopyInclude = 'I'
                                                     AND tbc.TaskType = 'E' )
                   AND ProgramTaskBundle.IsInclude = 1
                   AND ProgramTaskBundle.TaskType = 'E'



         END
          
END













GO

/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Insert_TaskBundleEducationMaterial]
Description: This trigger is used to track the history of a AdhocFrequency modifications from the TaskBundleEducationMaterial table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/
CREATE TRIGGER [dbo].[tr_Insert_TaskBundleEducationMaterial] ON [dbo].[TaskBundleEducationMaterial]
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
		SET PEMList = ISNULL(PEMList, '$$') + CASE 
				WHEN RIGHT(PEMList, 2) <> '$$'
					THEN '$$'
				ELSE ''
				END + ISNULL(CASE 
				WHEN CHARINDEX(CONVERT(VARCHAR(10), inserted.EducationMaterialID) + '- Added', isnull(PEMList, ''), 1) = 0
					THEN CONVERT(VARCHAR(10), inserted.TaskBundleEducationMaterialID) + '*' + CONVERT(VARCHAR(10), inserted.EducationMaterialID) + '- Added $$'
				END,'')
		FROM inserted
		INNER JOIN TaskBundle
			ON TaskBundle.TaskBundleId = inserted.TaskBundleId
		WHERE TaskBundleHistory.TaskBundleId = inserted.TaskBundleId
			AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR, CONVERT(DECIMAL(10, 1), TaskBundle.DefinitionVersion) - .1)
	END

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
			--,FrequencyNumber
			--,Frequency
			,StatusCode
			,CreatedByUserId
			,IsInclude
			)
		SELECT tb.ProgramID
			,i.TaskBundleId
			,'E'
			,i.EducationMaterialID
			--,i.FrequencyNumber
			--,i.Frequency
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
					AND ptb.GeneralizedID = i.EducationMaterialID
					AND ptb.IsInclude = 0
					AND ptb.TaskType = 'E'
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
				AND inserted.EducationMaterialID = ProgramTaskBundle.GeneralizedID
		INNER JOIN @Program p
			ON p.ProgramID = ProgramTaskBundle.ProgramID
		WHERE PatientProgram.StatusCode = 'A'
			AND ProgramTaskBundle.StatusCode = 'A'
			AND ProgramTaskBundle.TaskType = 'E'
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
			,LastModifiedByUserId = i.CreatedByUserId
			,LastModifiedDate = GETDATE()
		FROM inserted i
		INNER JOIN @Program tb
			ON tb.TaskBundleID = i.TaskBundleId
		WHERE ProgramTaskBundle.ProgramID = tb.ProgramID
			AND ProgramTaskBundle.GeneralizedID = i.EducationMaterialID
			AND ProgramTaskBundle.TaskBundleID = i.TaskBundleId
			--AND ProgramTaskBundle.IsInclude = 0
			AND ProgramTaskBundle.TaskType = 'E'
			AND ProgramTaskBundle.StatusCode = 'I'
	END
END

GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Delete_TaskBundleEducationMaterial]
Description: This trigger is used to track the history of a TaskBundle modifications from the TaskBundle table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Delete_TaskBundleEducationMaterial] ON [dbo].[TaskBundleEducationMaterial]
       AFTER DELETE
AS
BEGIN
      SET NOCOUNT ON

      ---- Delete the records in taskbunclecopyinclude table which are included if the reord is deleted from TaskBundleEducationMaterial
      DELETE  FROM
              TaskBundleCopyInclude
      WHERE
              EXISTS ( SELECT
                           1
                       FROM
                           deleted
                       WHERE
                           deleted.TaskBundleId = TaskBundleCopyInclude.ParentTaskBundleId
                           AND deleted.EducationMaterialID = TaskBundleCopyInclude.GeneralizedID )
              AND TaskBundleCopyInclude.TaskType = 'E'
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
                           AND deleted.EducationMaterialID = TaskBundleCopyInclude.GeneralizedID )
              AND TaskBundleCopyInclude.TaskType = 'E'
              AND TaskBundleCopyInclude.CopyInclude IN ( 'C' , 'O' )
      
      ---- Delete the records in ProgramTaskBundle table which are self tasks if the reord is deleted from TaskBundleEducationMaterial

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
          AND deleted.EducationMaterialID = ProgramTaskBundle.GeneralizedID
          AND ProgramTaskBundle.TaskType = 'E'
          AND ProgramTaskBundle.IsInclude = 0
      
      ---- Delete the records in ProgramTaskBundle table which are included tasks if the reord is deleted from TaskBundleEducationMaterial
      -- through the trigger [tr_Delete_TaskBundleCopyInclude]


END














GO
DISABLE TRIGGER [dbo].[tr_Delete_TaskBundleEducationMaterial]
    ON [dbo].[TaskBundleEducationMaterial];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleEducationMaterial', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleEducationMaterial', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleEducationMaterial', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleEducationMaterial', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

