CREATE TABLE [dbo].[ReportFrequencyDate] (
    [ReportFrequencyId] [dbo].[KeyID] NOT NULL,
    [AnchorDate]        [dbo].[KeyID] NOT NULL,
    [IsETLCompleted]    BIT           CONSTRAINT [DF_MetricReportConfiguration_IsEtlCompleted] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ReportFrequencyDate] PRIMARY KEY CLUSTERED ([ReportFrequencyId] ASC, [AnchorDate] ASC),
    CONSTRAINT [FK_ReportFrequencyDate_ReportFrequency] FOREIGN KEY ([ReportFrequencyId]) REFERENCES [dbo].[ReportFrequency] ([ReportFrequencyId])
);

