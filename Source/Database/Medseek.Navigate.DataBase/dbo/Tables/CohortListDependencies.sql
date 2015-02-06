CREATE TABLE [dbo].[CohortListDependencies] (
    [CohortDependencyId]     [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [PopulationDefinitionID] [dbo].[KeyID]       NOT NULL,
    [IncludedCohortListId]   [dbo].[KeyID]       NOT NULL,
    [CreatedByUserId]        [dbo].[KeyID]       NOT NULL,
    [CreatedDate]            [dbo].[UserDate]    CONSTRAINT [DF_CohortListDependencies_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]       NULL,
    [LastModifiedDate]       [dbo].[UserDate]    NULL,
    [Type]                   VARCHAR (1)         NULL,
    [IsDraft]                [dbo].[IsIndicator] NULL,
    CONSTRAINT [PK_CohortListDependencies] PRIMARY KEY CLUSTERED ([CohortDependencyId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_CohortListDependencies_PopulationDefinition] FOREIGN KEY ([PopulationDefinitionID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID])
);


GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Insert_CohortListDependencies]
Description: This trigger is used to track the history of a cohort modifications from the cohortlistDependency table.                 
When   Who   Action                    
---------------------------------------------------------------------    
30-Aug-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Insert_CohortListDependencies] ON [dbo].[CohortListDependencies]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON


      UPDATE
          CohortListHistory
      SET
          CohortDependencyModificationList = 
          ISNULL(CohortDependencyModificationList , '') +
           STUFF(( SELECT 
                          '$$' +CONVERT(VARCHAR , inserted.IncludedCohortListId) + '-' + CONVERT(VARCHAR , inserted.Type) + '*I'
                      FROM
                         PopulationDefinition
      
          INNER JOIN inserted
          ON inserted.PopulationDefinitionid = PopulationDefinition.PopulationDefinitionid
                      FOR
                          XML PATH('') ) , 1 , 0 , '') 
          
      FROM
          PopulationDefinition
          INNER JOIN inserted
          ON inserted.PopulationDefinitionid = PopulationDefinition.PopulationDefinitionid
      WHERE
          CohortListHistory.PopulationDefinitionId = inserted.PopulationDefinitionid
          AND CohortListHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , PopulationDefinition.DefinitionVersion) - .1) 
          
          
          
      --     UPDATE
      --    CohortListHistory
      --SET
      --    CohortDependencyModificationList = 
      --    ISNULL(CohortDependencyModificationList , '') + CONVERT(VARCHAR , inserted.IncludedCohortListId) + '-' + CONVERT(VARCHAR , inserted.Type) + '*I'+'$$'
          
      --    --ISNULL(CohortDependencyModificationList , '') + 
      --    --CASE WHEN CHARINDEX(CONVERT(VARCHAR , inserted.IncludedCohortListId) + '-' + CONVERT(VARCHAR , inserted.Type) + '*I',
      --    -- ISNULL(CohortDependencyModificationList , ''),1) = 0 THEN
      --    --CONVERT(VARCHAR , inserted.IncludedCohortListId) + '-' + CONVERT(VARCHAR , inserted.Type) + '*I'+ '$$'
      --    --ELSE '' END
      --FROM
      --    CohortList
      --    INNER JOIN inserted
      --    ON inserted.cohortlistid = CohortList.cohortlistid
      --WHERE
      --    CohortListHistory.CohortListId = inserted.CohortListid
      --    AND CohortListHistory.DefinitionVersion = REPLACE(CONVERT(VARCHAR , CONVERT(DECIMAL(10,2) , CohortList.DefinitionVersion) - .01) , '.99' , '.09')

END








GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Delete_CohortListDependencies]
Description: This trigger is used to track the history of a cohort modifications from the cohortlistDependency table.                 
When   Who   Action                    
---------------------------------------------------------------------    
30-Aug-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Delete_CohortListDependencies] ON [dbo].[CohortListDependencies]
       AFTER DELETE
AS
BEGIN
      SET NOCOUNT ON
  UPDATE
          CohortListHistory
      SET
          CohortDependencyModificationList = 
          ISNULL(CohortDependencyModificationList , '') + 
           STUFF(( SELECT 
                          '$$' + CONVERT(VARCHAR , deleted.IncludedCohortListId) + '-' + CONVERT(VARCHAR , deleted.Type) + '*D'
                      FROM
                         PopulationDefinition
      
          INNER JOIN deleted
          ON deleted.PopulationDefinitionid = PopulationDefinition.PopulationDefinitionid
                      FOR
                          XML PATH('') ) , 1 , 0 , '') 
         
      FROM
          PopulationDefinition
          INNER JOIN deleted
          ON deleted.PopulationDefinitionid = PopulationDefinition.PopulationDefinitionid
      WHERE
          CohortListHistory.PopulationDefinitionId = deleted.PopulationDefinitionid
          AND CohortListHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , PopulationDefinition.DefinitionVersion) - .1) 


      --UPDATE
      --    CohortListHistory
      --SET
      --    CohortDependencyModificationList = 
      --    --ISNULL(CohortDependencyModificationList , '') + 
      --    --CASE WHEN CHARINDEX(CONVERT(VARCHAR , deleted.IncludedCohortListId) + '-' + CONVERT(VARCHAR , deleted.Type) + '*D',
      --    -- ISNULL(CohortDependencyModificationList , ''),1) = 0 THEN
      --    --CONVERT(VARCHAR , deleted.IncludedCohortListId) + '-' + CONVERT(VARCHAR , deleted.Type) + '*D'+ '$$'
      --    --ELSE '' END
          
          
      --    ISNULL(CohortDependencyModificationList , '') + CONVERT(VARCHAR , deleted.IncludedCohortListId) + '-' + CONVERT(VARCHAR , deleted.Type) + '*D'+'$$'
      --FROM
      --    CohortList
      --    INNER JOIN deleted
      --    ON deleted.cohortlistid = CohortList.cohortlistid
      --WHERE
      --    CohortListHistory.CohortListId = deleted.CohortListid
      --    AND CohortListHistory.DefinitionVersion = REPLACE(CONVERT(VARCHAR , CONVERT(DECIMAL(10,2) , CohortList.DefinitionVersion) - .01) , '.99' , '.09')


END









GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListDependencies', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListDependencies', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListDependencies', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListDependencies', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

