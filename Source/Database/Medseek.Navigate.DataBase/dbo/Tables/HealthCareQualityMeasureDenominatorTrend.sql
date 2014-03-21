CREATE TABLE [dbo].[HealthCareQualityMeasureDenominatorTrend] (
    [HealthCareQualityMeasureDenominatorTrendID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [HealthCareQualityMeasureID]                 [dbo].[KeyID]    NULL,
    [PatientUserID]                              [dbo].[KeyID]    NULL,
    [ProviderUserID]                             [dbo].[KeyID]    NULL,
    [GeneratedYear]                              INT              NULL,
    [GeneratedMonth]                             SMALLINT         NULL,
    [CreatedByUserId]                            [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                                [dbo].[UserDate] CONSTRAINT [DF_HealthCareQualityMeasureDenominatorTrend_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_HealthCareQualityMeasureDenominatorTrend] PRIMARY KEY CLUSTERED ([HealthCareQualityMeasureDenominatorTrendID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_HealthCareQualityMeasureDenominatorTrend_HealthCareQualityMeasure] FOREIGN KEY ([HealthCareQualityMeasureID]) REFERENCES [dbo].[HealthCareQualityMeasure] ([HealthCareQualityMeasureID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureDenominatorTrend', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureDenominatorTrend', @level2type = N'COLUMN', @level2name = N'CreatedDate';

