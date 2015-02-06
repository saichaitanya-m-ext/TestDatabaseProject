CREATE TABLE [dbo].[PopulationDefinition] (
    [PopulationDefinitionID]          [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PopulationDefinitionName]        VARCHAR (500)           NULL,
    [PopulationDefinitionDescription] [dbo].[LongDescription] NULL,
    [DefinitionType]                  VARCHAR (1)             CONSTRAINT [DF_PopulationDefinition_DefinitionType] DEFAULT ('P') NULL,
    [LastDateListGenerated]           [dbo].[UserDate]        NOT NULL,
    [RefreshPatientListDaily]         [dbo].[IsIndicator]     NOT NULL,
    [NonModifiable]                   [dbo].[IsIndicator]     CONSTRAINT [DF_PopulationDefinition_NonModifiable] DEFAULT ((1)) NULL,
    [Private]                         [dbo].[IsIndicator]     NULL,
    [ProductionStatus]                VARCHAR (1)             NULL,
    [DefinitionVersion]               VARCHAR (5)             CONSTRAINT [DF_PopulationDefinition_DefinitionVersion] DEFAULT ('1.0') NULL,
    [StandardsId]                     [dbo].[KeyID]           NULL,
    [StandardOrganizationId]          [dbo].[KeyID]           NULL,
    [NumeratorType]                   VARCHAR (1)             NULL,
    [StatusCode]                      VARCHAR (1)             CONSTRAINT [DF_PopulationDefinition_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]                 [dbo].[KeyID]           NOT NULL,
    [CreatedDate]                     [dbo].[UserDate]        CONSTRAINT [DF_PopulationDefinition_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]            [dbo].[KeyID]           NULL,
    [LastModifiedDate]                [dbo].[UserDate]        NULL,
    [ConditionId]                     [dbo].[KeyID]           NULL,
    [IsDisplayInHomePage]             BIT                     NULL,
    [CodeGroupingID]                  [dbo].[KeyID]           NULL,
    [IsIndicator]                     BIT                     CONSTRAINT [DF_PopulationDefinition_IsIndicator] DEFAULT ((0)) NULL,
    [IsADT]                           [dbo].[IsIndicator]     NULL,
    [ADTtype]                         VARCHAR (1)             NULL,
    CONSTRAINT [PK_PopulationDefinition] PRIMARY KEY CLUSTERED ([PopulationDefinitionID] ASC),
    CONSTRAINT [FK_PopulationDefinition_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_PopulationDefinition_Condition] FOREIGN KEY ([ConditionId]) REFERENCES [dbo].[Condition] ([ConditionID]),
    CONSTRAINT [FK_PopulationDefinition_Standard] FOREIGN KEY ([StandardsId]) REFERENCES [dbo].[Standard] ([StandardId]),
    CONSTRAINT [FK_PopulationDefinition_StandardOrganization] FOREIGN KEY ([StandardOrganizationId]) REFERENCES [dbo].[StandardOrganization] ([StandardOrganizationId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PopDefinition_DefType_ID]
    ON [dbo].[PopulationDefinition]([DefinitionType] ASC, [PopulationDefinitionName] ASC, [NumeratorType] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PopulationDefinition_DefType_Include]
    ON [dbo].[PopulationDefinition]([DefinitionType] ASC)
    INCLUDE([PopulationDefinitionID], [PopulationDefinitionName], [PopulationDefinitionDescription], [RefreshPatientListDaily], [NonModifiable], [Private], [ProductionStatus], [DefinitionVersion], [StandardsId], [StandardOrganizationId], [StatusCode], [CreatedByUserId], [CreatedDate], [LastModifiedByUserId], [LastModifiedDate], [ConditionId]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PopulationDefinition_Status_Include]
    ON [dbo].[PopulationDefinition]([StatusCode] ASC, [DefinitionType] ASC)
    INCLUDE([PopulationDefinitionID], [PopulationDefinitionName]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Update_PopulationDefinition]
Description: This trigger is used to track the history of a PopulationDefinition modifications from the PopulationDefinition table.                 
When   Who   Action                    
---------------------------------------------------------------------    
10-Dec-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/

CREATE TRIGGER [dbo].[tr_Update_PopulationDefinition] ON [dbo].[PopulationDefinition]
       AFTER UPDATE
AS
BEGIN
      SET NOCOUNT ON

      UPDATE
          CohortListHistory
      SET
          CohortModificationList = ISNULL(CohortModificationList , '') + 
			CASE
			WHEN CHARINDEX('Name Modified' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.PopulationDefinitionName <> CohortListHistory.CohortListName THEN ' Name Modified $$'
			ELSE ''
			END
			ELSE ''
			END + CASE
			WHEN CHARINDEX('Description Modified' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.PopulationDefinitionDescription <> CohortListHistory.CohortListDescription THEN ' Description Modified $$'
			ELSE ''
			END
			ELSE ''
			END +
			CASE
			WHEN CHARINDEX('Definition Type Modified' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.DefinitionType <> CohortListHistory.DefinitionType THEN ' Definition Type Modified $$'
			ELSE ''
			END
			ELSE ''
			END +
			CASE
			WHEN CHARINDEX('LastDateListGenerated Modified' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.LastDateListGenerated <> CohortListHistory.LastDateListGenerated THEN ' LastDateListGenerated Modified $$'
			ELSE ''
			END
			ELSE ''
			END +
			CASE
			WHEN CHARINDEX('RefreshPatientListDaily Modified' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.RefreshPatientListDaily <> CohortListHistory.RefreshPatientListDaily THEN ' RefreshPatientListDaily Modified $$'
			ELSE ''
			END
			ELSE ''
			END +
			CASE
			WHEN CHARINDEX('NonModifiable Modified' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.NonModifiable <> CohortListHistory.NonModifiable THEN ' NonModifiable Modified $$'
			ELSE ''
			END
			ELSE ''
			END +
			CASE
			WHEN CHARINDEX('Display Status Modified' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.Private <> CohortListHistory.Private THEN ' Display Status Modified $$'
			ELSE ''
			END
			ELSE ''
			END +
			CASE
			WHEN CHARINDEX('ProductionStatus Modified' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.ProductionStatus <> CohortListHistory.ProductionStatus THEN ' ProductionStatus Modified $$'
			ELSE ''
			END
			ELSE ''
			END +
			CASE
			WHEN CHARINDEX('Standard Information Modified' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.StandardsId <> CohortListHistory.StandardId THEN ' Standard Information Modified $$'
			ELSE ''
			END
			ELSE ''
			END +
			CASE
			WHEN CHARINDEX('Standard Organization Information Modified' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.StandardOrganizationId <> CohortListHistory.StandardOrganizationId THEN ' Standard Organization Information Modified $$'
			ELSE ''
			END
			ELSE ''
			END +
			CASE
			WHEN CHARINDEX('NumeratorType Modified' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.NumeratorType <> CohortListHistory.NumeratorType THEN ' NumeratorType Modified $$'
			ELSE ''
			END
			ELSE ''
			END +
			CASE
			WHEN CHARINDEX('Status Updated' , isnull(CohortModificationList , '') , 1) = 0 THEN CASE
			WHEN inserted.StatusCode <> CohortListHistory.StatusCode THEN ' Status Updated $$'
			ELSE ''
			END
			ELSE ''
			END 
      FROM
          inserted
          INNER JOIN deleted
          ON deleted.PopulationDefinitionId = inserted.PopulationDefinitionId
      WHERE
          CohortListHistory.PopulationDefinitionID = inserted.PopulationDefinitionId
          AND CohortListHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , inserted.DefinitionVersion) - .1)

END







