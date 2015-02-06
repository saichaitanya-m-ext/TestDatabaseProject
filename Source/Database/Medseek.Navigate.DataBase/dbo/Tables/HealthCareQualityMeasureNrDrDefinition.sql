CREATE TABLE [dbo].[HealthCareQualityMeasureNrDrDefinition] (
    [HealthCareQualityMeasureNrDrDefinitionID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [HealthCareQualityMeasureID]               [dbo].[KeyID]    NULL,
    [NrDrIndicator]                            CHAR (1)         NULL,
    [CriteriaSQL]                              VARCHAR (MAX)    NULL,
    [CriteriaText]                             VARCHAR (MAX)    NULL,
    [CriteriaTypeID]                           [dbo].[KeyID]    NULL,
    [CreatedByUserId]                          [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                              [dbo].[UserDate] CONSTRAINT [DF_HealthCareQualityMeasureNrDrDefinition_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]                     [dbo].[KeyID]    NULL,
    [LastModifiedDate]                         [dbo].[UserDate] NULL,
    [JoinType]                                 VARCHAR (20)     NULL,
    [JoinStatement]                            VARCHAR (MAX)    NULL,
    [OnClause]                                 VARCHAR (200)    NULL,
    [WhereClause]                              VARCHAR (MAX)    NULL,
    CONSTRAINT [PK_HealthCareQualityMeasureNrDrDefinition] PRIMARY KEY CLUSTERED ([HealthCareQualityMeasureNrDrDefinitionID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_HealthCareQualityMeasureNrDrDefinition_CohortListCriteriaType] FOREIGN KEY ([CriteriaTypeID]) REFERENCES [dbo].[CohortListCriteriaType] ([CohortListCriteriaTypeId]),
    CONSTRAINT [FK_HealthCareQualityMeasureNrDrDefinition_HealthCareQualityMeasure] FOREIGN KEY ([HealthCareQualityMeasureID]) REFERENCES [dbo].[HealthCareQualityMeasure] ([HealthCareQualityMeasureID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureNrDrDefinition', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureNrDrDefinition', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureNrDrDefinition', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureNrDrDefinition', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

