CREATE TABLE [dbo].[Metric] (
    [MetricId]               [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [Name]                   VARCHAR (100)    NOT NULL,
    [Description]            VARCHAR (500)    NULL,
    [StandardId]             [dbo].[KeyID]    NULL,
    [StandardOrganizationID] [dbo].[KeyID]    NULL,
    [IOMCategoryID]          [dbo].[KeyID]    NULL,
    [InsuranceGroupID]       [dbo].[KeyID]    NULL,
    [DenominatorType]        VARCHAR (1)      NULL,
    [DenominatorID]          [dbo].[KeyID]    NULL,
    [Version]                VARCHAR (5)      CONSTRAINT [DF_Metrics_Version] DEFAULT ('1.0') NULL,
    [StatusCode]             VARCHAR (1)      CONSTRAINT [DF_Metrics_StatusCode] DEFAULT ('A') NOT NULL,
    [NumeratorID]            [dbo].[KeyID]    NULL,
    [ValueAttributeID]       [dbo].[KeyID]    NULL,
    [CreatedByUserId]        [dbo].[KeyID]    NOT NULL,
    [CreatedDate]            [dbo].[UserDate] CONSTRAINT [DF_Metrics_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]    NULL,
    [LastModifiedDate]       [dbo].[UserDate] NULL,
    [ManagedPopulationID]    INT              NULL,
    CONSTRAINT [PK_Metrics] PRIMARY KEY CLUSTERED ([MetricId] ASC),
    CONSTRAINT [FK_Metric_Standard] FOREIGN KEY ([StandardId]) REFERENCES [dbo].[Standard] ([StandardId]),
    CONSTRAINT [FK_Metrics_InsuranceGroup] FOREIGN KEY ([InsuranceGroupID]) REFERENCES [dbo].[InsuranceGroup] ([InsuranceGroupID]),
    CONSTRAINT [FK_Metrics_IOMCategory] FOREIGN KEY ([IOMCategoryID]) REFERENCES [dbo].[IOMCategory] ([IOMCategoryId]),
    CONSTRAINT [FK_Metrics_lookupvalue] FOREIGN KEY ([ValueAttributeID]) REFERENCES [dbo].[LookUpValue] ([LookupValueId]),
    CONSTRAINT [FK_Metrics_PopulationDefinition] FOREIGN KEY ([NumeratorID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID]),
    CONSTRAINT [FK_Metrics_StandardOrganization] FOREIGN KEY ([StandardOrganizationID]) REFERENCES [dbo].[StandardOrganization] ([StandardOrganizationId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Name]
    ON [dbo].[Metric]([Name] ASC, [DenominatorID] ASC, [NumeratorID] ASC, [ManagedPopulationID] ASC) WITH (FILLFACTOR = 80)
    ON [FG_Transactional_NCX];

