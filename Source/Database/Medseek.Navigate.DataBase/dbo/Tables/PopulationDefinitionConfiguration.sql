CREATE TABLE [dbo].[PopulationDefinitionConfiguration] (
    [PopulationDefinitionConfigurationID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [DrID]                                [dbo].[KeyID]      NOT NULL,
    [NoOfCodes]                           SMALLINT           CONSTRAINT [DF_PopulationDefinitionConfiguration_NoOfCodes] DEFAULT ((1)) NOT NULL,
    [TimeInDays]                          INT                CONSTRAINT [DF_PopulationDefinitionConfiguration_TimeInDays] DEFAULT ((730)) NULL,
    [LastRunDate]                         [dbo].[UserDate]   NULL,
    [StatusCode]                          [dbo].[StatusCode] CONSTRAINT [DF_PopulationDefinitionConfiguration_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedDate]                         DATETIME           CONSTRAINT [DF_PopulationDefinitionConfiguration_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CodeGroupingID]                      INT                NULL,
    [MetricID]                            INT                NULL,
    [ConditionIdList]                     VARCHAR (100)      NULL,
    [CodeGroupingIDList]                  VARCHAR (100)      NULL,
    [DrProcName]                          VARCHAR (200)      NULL,
    [NrProcName]                          VARCHAR (200)      NULL,
    [IsConflictParameter]                 BIT                CONSTRAINT [DF_PopulationDefinitionConfiguration_IsConflictParameter] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_PopulationDefinitionConfiguration] PRIMARY KEY CLUSTERED ([PopulationDefinitionConfigurationID] ASC),
    CONSTRAINT [FK_PopulationDefinitionConfiguration_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_PopulationDefinitionConfiguration_Metrics] FOREIGN KEY ([MetricID]) REFERENCES [dbo].[Metric] ([MetricId])
);

