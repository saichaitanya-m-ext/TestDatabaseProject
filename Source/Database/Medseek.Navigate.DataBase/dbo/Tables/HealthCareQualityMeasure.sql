CREATE TABLE [dbo].[HealthCareQualityMeasure] (
    [HealthCareQualityMeasureID]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [HealthCareQualityBCategoryId] [dbo].[KeyID]            NULL,
    [HealthCareQualityMeasureName] VARCHAR (400)            NULL,
    [NumeratorValue]               DECIMAL (10, 2)          NULL,
    [DenominatorValue]             DECIMAL (10, 2)          NULL,
    [CreatedByUserId]              [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                  [dbo].[UserDate]         CONSTRAINT [DF_HealthCareQualityMeasure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]         [dbo].[KeyID]            NULL,
    [LastModifiedDate]             [dbo].[UserDate]         NULL,
    [IsCustom]                     [dbo].[IsIndicator]      CONSTRAINT [DF_HealthCareQualityMeasure_IsCustom] DEFAULT ((1)) NULL,
    [NumeratorCount]               INT                      NULL,
    [DenominatorCount]             INT                      NULL,
    [HealthCareQualityStandardId]  INT                      NULL,
    [StatusCode]                   [dbo].[StatusCode]       CONSTRAINT [DF_HealthCareQualityMeasure_StatusCode] DEFAULT ('A') NOT NULL,
    [ReportingYear]                INT                      NULL,
    [ReportingPeriod]              VARCHAR (10)             NULL,
    [AdminOrClincFlag]             CHAR (1)                 NULL,
    [SpecialityIDList]             [dbo].[LongDescription]  NULL,
    [ProviderIDList]               [dbo].[LongDescription]  NULL,
    [AdminClassificationIDList]    [dbo].[LongDescription]  NULL,
    [ProgramID]                    [dbo].[KeyID]            NULL,
    [DiseaseID]                    [dbo].[KeyID]            NULL,
    [CloneMeasureName]             [dbo].[ShortDescription] NULL,
    [CopyType]                     CHAR (1)                 NULL,
    CONSTRAINT [PK_HealthCareQualityMeasure] PRIMARY KEY CLUSTERED ([HealthCareQualityMeasureID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_HealthCareQualityBCategory_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId]),
    CONSTRAINT [FK_HealthCareQualityMeasure_Disease] FOREIGN KEY ([DiseaseID]) REFERENCES [dbo].[Disease] ([DiseaseId]),
    CONSTRAINT [FK_HealthCareQualityMeasure_HealthCareQualityBCategory] FOREIGN KEY ([HealthCareQualityBCategoryId]) REFERENCES [dbo].[HealthCareQualityBCategory] ([HealthCareQualityBCategoryId]),
    CONSTRAINT [FK_HealthCareQualityMeasure_HealthCareQualityStandard] FOREIGN KEY ([HealthCareQualityStandardId]) REFERENCES [dbo].[HealthCareQualityStandard] ([HealthCareQualityStandardID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

