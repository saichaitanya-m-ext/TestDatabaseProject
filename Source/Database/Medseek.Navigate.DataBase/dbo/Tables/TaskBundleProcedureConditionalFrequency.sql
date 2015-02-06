CREATE TABLE [dbo].[TaskBundleProcedureConditionalFrequency] (
    [TaskBundleProcedureConditionalFrequencyID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [TaskBundleProcedureFrequencyId]            [dbo].[KeyID]      NOT NULL,
    [MeasureID]                                 [dbo].[KeyID]      NULL,
    [FromOperatorforMeasure]                    VARCHAR (5)        NULL,
    [FromValueforMeasure]                       DECIMAL (10, 2)    NULL,
    [ToOperatorforMeasure]                      VARCHAR (5)        NULL,
    [ToValueforMeasure]                         DECIMAL (10, 2)    NULL,
    [MeasureTextValue]                          [dbo].[SourceName] NULL,
    [FromOperatorforAge]                        VARCHAR (5)        NULL,
    [FromValueforAge]                           SMALLINT           NULL,
    [ToOperatorforAge]                          VARCHAR (5)        NULL,
    [ToValueforAge]                             SMALLINT           NULL,
    [FrequencyUOM]                              VARCHAR (1)        NOT NULL,
    [Frequency]                                 SMALLINT           NOT NULL,
    [CreatedByUserId]                           [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                               [dbo].[UserDate]   CONSTRAINT [DF_TaskBundleProcedureConditionalFrequency_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]                      [dbo].[KeyID]      NULL,
    [LastModifiedDate]                          [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_TaskBundleProcedureConditionalFrequency] PRIMARY KEY CLUSTERED ([TaskBundleProcedureConditionalFrequencyID] ASC),
    CONSTRAINT [FK_TaskBundleProcedureConditionalFrequency_Measure] FOREIGN KEY ([MeasureID]) REFERENCES [dbo].[Measure] ([MeasureId]),
    CONSTRAINT [FK_TaskBundleProcedureConditionalFrequency_TaskBundleProcedureFrequency] FOREIGN KEY ([TaskBundleProcedureFrequencyId]) REFERENCES [dbo].[TaskBundleProcedureFrequency] ([TaskBundleProcedureFrequencyId])
);


GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Update_TaskBundleProcedureConditionalFrequency]
Description: This trigger is used to track the history of a TaskBundle modifications from the TaskBundle table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Update_TaskBundleProcedureConditionalFrequency] ON [dbo].[TaskBundleProcedureConditionalFrequency]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON


    IF EXISTS (SELECT 1 FROM inserted WHERE MeasureID IS NOT NULL)
BEGIN

      UPDATE
          TaskBundleHistory
      SET
          CPTList = ISNULL(CPTList , '$$') +  CASE WHEN RIGHT(CPTList,2) <> '$$' THEN '$$' ELSE '' END+
         STUFF(( SELECT 
                          '$$' +CONVERT(VARCHAR (10), inserted.TaskBundleProcedureFrequencyId) + '*' + CONVERT(VARCHAR , inserted.MeasureID) + '-I'
                      FROM
                         inserted
                      FOR
                          XML PATH('') ) , 1 , 0 , '') 
			
      FROM
          inserted
          INNER JOIN TaskBundleProcedureFrequency
          ON TaskBundleProcedureFrequency.TaskBundleProcedureFrequencyId = inserted.TaskBundleProcedureFrequencyId
          inner join TaskBundle
          on TaskBundle.TaskBundleId = TaskBundleProcedureFrequency.TaskBundleId
      WHERE
          TaskBundleHistory.TaskBundleId = TaskBundle.TaskBundleId
          AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , TaskBundle.DefinitionVersion) - .1)
END
ELSE 

BEGIN
 UPDATE
          TaskBundleHistory
      SET
          CPTList = ISNULL(CPTList , '$$') +  CASE WHEN RIGHT(CPTList,2) <> '$$' THEN '$$' ELSE '' END+
         STUFF(( SELECT 
                          '$$' +CONVERT(VARCHAR (10), inserted.TaskBundleProcedureFrequencyId) + '*'  + '- Added AgeOnly'
                      FROM
                         inserted
                      FOR
                          XML PATH('') ) , 1 , 0 , '') 
			
      FROM
          inserted
          INNER JOIN TaskBundleProcedureFrequency
          ON TaskBundleProcedureFrequency.TaskBundleProcedureFrequencyId = inserted.TaskBundleProcedureFrequencyId
          inner join TaskBundle
          on TaskBundle.TaskBundleId = TaskBundleProcedureFrequency.TaskBundleId
      WHERE
          TaskBundleHistory.TaskBundleId = TaskBundle.TaskBundleId
          AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , TaskBundle.DefinitionVersion) - .1)

END
END








GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Update_TaskBundleProcedureConditionalFrequency]
Description: This trigger is used to track the history of a TaskBundle modifications from the TaskBundle table.                 
When   Who   Action                    
---------------------------------------------------------------------    
13-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Delete_TaskBundleProcedureConditionalFrequency] ON [dbo].[TaskBundleProcedureConditionalFrequency]
       AFTER DELETE
AS
BEGIN
      SET NOCOUNT ON


    IF EXISTS (SELECT 1 FROM deleted WHERE MeasureID IS NOT NULL)
BEGIN

      UPDATE
          TaskBundleHistory
      SET
          CPTList = ISNULL(CPTList , '$$') +  CASE WHEN RIGHT(CPTList,2) <> '$$' THEN '$$' ELSE '' END+
         STUFF(( SELECT 
                          '$$' +CONVERT(VARCHAR (10), deleted.TaskBundleProcedureFrequencyId) + '*' + CONVERT(VARCHAR , deleted.MeasureID) + '-D'
                      FROM
                         inserted
                      FOR
                          XML PATH('') ) , 1 , 0 , '') 
			
      FROM
          deleted
          INNER JOIN TaskBundleProcedureFrequency
          ON TaskBundleProcedureFrequency.TaskBundleProcedureFrequencyId = deleted.TaskBundleProcedureFrequencyId
          inner join TaskBundle
          on TaskBundle.TaskBundleId = TaskBundleProcedureFrequency.TaskBundleId
      WHERE
          TaskBundleHistory.TaskBundleId = TaskBundle.TaskBundleId
          AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , TaskBundle.DefinitionVersion) - .1)
END
ELSE 

BEGIN
 UPDATE
          TaskBundleHistory
      SET
          CPTList = ISNULL(CPTList , '$$') +  CASE WHEN RIGHT(CPTList,2) <> '$$' THEN '$$' ELSE '' END+
         STUFF(( SELECT 
                          '$$' +CONVERT(VARCHAR (10), deleted.TaskBundleProcedureFrequencyId) + '*'  + '-Removed AgeOnly'
                      FROM
                         inserted
                      FOR
                          XML PATH('') ) , 1 , 0 , '') 
			
      FROM
          deleted
          INNER JOIN TaskBundleProcedureFrequency
          ON TaskBundleProcedureFrequency.TaskBundleProcedureFrequencyId = deleted.TaskBundleProcedureFrequencyId
          inner join TaskBundle
          on TaskBundle.TaskBundleId = TaskBundleProcedureFrequency.TaskBundleId
      WHERE
          TaskBundleHistory.TaskBundleId = TaskBundle.TaskBundleId
          AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , TaskBundle.DefinitionVersion) - .1)

END
END








GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

