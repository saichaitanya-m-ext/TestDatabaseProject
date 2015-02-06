CREATE TABLE [dbo].[TaskBundle] (
    [TaskBundleId]         [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [TaskBundleName]       [dbo].[SourceName]       NOT NULL,
    [Description]          [dbo].[ShortDescription] NOT NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_TaskBundle_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_TaskBundle_CreatetdDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    [IsEdit]               [dbo].[IsIndicator]      NULL,
    [DefinitionVersion]    VARCHAR (5)              CONSTRAINT [DF_TaskBundle_DefinitionVersion] DEFAULT ('1.0') NULL,
    [ProductionStatus]     VARCHAR (1)              NULL,
    [ConflictType]         VARCHAR (1)              NULL,
    CONSTRAINT [PK_TaskBundle] PRIMARY KEY CLUSTERED ([TaskBundleId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TaskBundle_TaskBundleName]
    ON [dbo].[TaskBundle]([TaskBundleName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Update_TaskBundle]
Description: This trigger is used to track the history of a TaskBundle modifications from the TaskBundle table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Update_TaskBundle] ON [dbo].[TaskBundle]
       AFTER UPDATE
AS
BEGIN
      SET NOCOUNT ON

      UPDATE
          TaskBundleHistory
      SET
          BundlehistoryList = ISNULL(BundlehistoryList , '') + 
			CASE
			WHEN CHARINDEX('Name Modified' , isnull(BundlehistoryList , '') , 1) = 0 THEN CASE
			WHEN inserted.TaskBundleName <> TaskBundleHistory.TaskBundleName THEN ' Name Modified $$'
			ELSE ''
			END
			ELSE ''
			END + CASE
			WHEN CHARINDEX('Description Modified' , isnull(BundlehistoryList , '') , 1) = 0 THEN CASE
			WHEN inserted.Description <> TaskBundleHistory.Description THEN ' Description Modified $$'
			ELSE ''
			END
			ELSE ''
			END + CASE
			WHEN CHARINDEX('Modifiable Option Modified' , isnull(BundlehistoryList , '') , 1) = 0 THEN CASE
			WHEN inserted.IsEdit <> TaskBundleHistory.IsEdit THEN ' Modifiable Option Modified $$'
			ELSE ''
			END
			ELSE ''
			END + CASE
			WHEN CHARINDEX('Production Status Modified' , isnull(BundlehistoryList , '') , 1) = 0 THEN CASE
			WHEN inserted.ProductionStatus <> TaskBundleHistory.ProductionStatus THEN ' Production Status Modified $$'
			ELSE ''
			END
			ELSE ''
			END 
			+ 
			--CASE
			--WHEN CHARINDEX(' Library Building Block Option Modified' , isnull(BundlehistoryList , '') , 1) = 0 THEN CASE
			--WHEN inserted.IsBuildingBlock <> TaskBundleHistory.IsBuildingBlock THEN ' Library Building Block Option Modified $$'
			--ELSE ''
			--END
			--ELSE ''
			--END 
			 CASE
			WHEN CHARINDEX('Conflict Option Modified' , isnull(BundlehistoryList , '') , 1) = 0 THEN CASE
			WHEN inserted.ConflictType <> TaskBundleHistory.ConflictType THEN ' Conflict Option Modified $$'
			ELSE ''
			END
			ELSE ''
			END
      FROM
          inserted
          INNER JOIN deleted
          ON deleted.TaskBundleId = inserted.TaskBundleId
      WHERE
          TaskBundleHistory.TaskBundleId = inserted.TaskBundleId
          AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , inserted.DefinitionVersion) - .1)

END








GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundle', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundle', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundle', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundle', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

