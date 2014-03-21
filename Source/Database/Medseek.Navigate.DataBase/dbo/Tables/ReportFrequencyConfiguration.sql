CREATE TABLE [dbo].[ReportFrequencyConfiguration] (
    [ReportFrequencyConfigurationId] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [MetricId]                       [dbo].[KeyID]      NULL,
    [ReportFrequencyId]              [dbo].[KeyID]      NOT NULL,
    [IsPrimary]                      BIT                CONSTRAINT [DF_ReportFrequencyConfiguration_IsPrimary] DEFAULT ((0)) NOT NULL,
    [DrID]                           [dbo].[KeyID]      NOT NULL,
    [StatusCode]                     [dbo].[StatusCode] CONSTRAINT [DF_ReportFrequencyConfiguration_StatusCode] DEFAULT ('A') NOT NULL,
    CONSTRAINT [PK_ReportFrequencyConfiguration] PRIMARY KEY CLUSTERED ([ReportFrequencyConfigurationId] ASC),
    CONSTRAINT [FK_ReportFrequencyConfiguration_Metrics] FOREIGN KEY ([MetricId]) REFERENCES [dbo].[Metric] ([MetricId]),
    CONSTRAINT [FK_ReportFrequencyConfiguration_ReportFrequency] FOREIGN KEY ([ReportFrequencyId]) REFERENCES [dbo].[ReportFrequency] ([ReportFrequencyId])
);

