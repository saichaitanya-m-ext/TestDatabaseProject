CREATE TABLE [dbo].[PopulationDefinitionCriteria] (
    [PopulationDefinitionCriteriaID]    INT           IDENTITY (1, 1) NOT NULL,
    [PopulationDefinitionID]            INT           NOT NULL,
    [PopulationDefinitionCriteriaSQL]   VARCHAR (MAX) NULL,
    [PopulationDefinitionCriteriaText]  VARCHAR (MAX) NULL,
    [CreatedByUserId]                   INT           NOT NULL,
    [CreatedDate]                       DATETIME      CONSTRAINT [DF_PopulationDefinitionCriteria_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]              INT           NULL,
    [LastModifiedDate]                  DATETIME      NULL,
    [PopulationDefPanelConfigurationID] [dbo].[KeyID] NULL,
    [CohortGeneralizedIdList]           VARCHAR (MAX) NULL,
    [XMLDefenition]                     XML           NULL,
    [IsBuildDraft]                      BIT           NULL,
    CONSTRAINT [PK_PopulationDefinitionCriteria] PRIMARY KEY CLUSTERED ([PopulationDefinitionCriteriaID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PopulationDefinitionCriteria_PopulationDefinition] FOREIGN KEY ([PopulationDefinitionID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID]),
    CONSTRAINT [FK_PopulationDefinitionCriteria_PopulationDefPanelConfiguration] FOREIGN KEY ([PopulationDefPanelConfigurationID]) REFERENCES [dbo].[PopulationDefPanelConfiguration] ([PopulationDefPanelConfigurationID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PopulationDefinitionCriteria_PopDefId_PopDefPanelConfigId]
    ON [dbo].[PopulationDefinitionCriteria]([PopulationDefinitionID] ASC, [PopulationDefPanelConfigurationID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Delete_CohortListCriteria]
Description: This trigger is used to track the history of a cohort modifications from the cohortlistCriteria table.                 
When   Who   Action                    
---------------------------------------------------------------------    
30-Aug-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Delete_CohortListCriteria] ON [dbo].[PopulationDefinitionCriteria]
       AFTER DELETE
AS
BEGIN
      SET NOCOUNT ON


      UPDATE
          CohortListHistory
      SET
          CohortCriteriaModificationList = ISNULL(CohortCriteriaModificationList , '') + CONVERT(VARCHAR , deleted.PopulationDefinitionid) + '-' + CONVERT(VARCHAR , deleted.PopulationDefPanelConfigurationID) + + '*D'+'$$'
      FROM
          PopulationDefinition
          INNER JOIN deleted
          ON deleted.PopulationDefinitionid = PopulationDefinition.PopulationDefinitionid
      WHERE
          CohortListHistory.PopulationDefinitionId = deleted.PopulationDefinitionid
          AND CohortListHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , PopulationDefinition.DefinitionVersion) - .1) 

END








GO



/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Insert_CohortListCriteria]
Description: This trigger is used to track the history of a cohort modifications from the cohortlist table.                 
When   Who   Action                    
---------------------------------------------------------------------    
30-Aug-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Insert_CohortListCriteria] ON [dbo].[PopulationDefinitionCriteria]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON


      UPDATE
          CohortListHistory
      SET
          CohortCriteriaModificationList = ISNULL(CohortCriteriaModificationList , '') + CONVERT(VARCHAR , inserted.PopulationDefinitionID) + '-' + CONVERT(VARCHAR , inserted.PopulationDefPanelConfigurationID) + '*I'+'$$'
      FROM
          inserted
          INNER JOIN populationdefinition
          ON PopulationDefinition.PopulationDefinitionID = inserted.PopulationDefinitionID
      WHERE
          CohortListHistory.PopulationDefinitionID = inserted.PopulationDefinitionID
          AND CohortListHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , PopulationDefinition.DefinitionVersion) - .1) 

END









GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Criteria for a cohort list', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the CohortlistCriteria table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'PopulationDefinitionCriteriaID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CohortList table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'PopulationDefinitionID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The SQL text for the criteria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'PopulationDefinitionCriteriaSQL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Criteria in a more readable form than the SQL text', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'PopulationDefinitionCriteriaText';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefinitionCriteria', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

