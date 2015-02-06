CREATE TABLE [dbo].[HealthCareQualityMeasureNumeratorTrend] (
    [HealthCareQualityMeasureNumeratorTrendID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [HealthCareQualityMeasureID]               [dbo].[KeyID]    NULL,
    [PatientUserID]                            [dbo].[KeyID]    NULL,
    [ProviderUserID]                           [dbo].[KeyID]    NULL,
    [GeneratedYear]                            INT              NULL,
    [GeneratedMonth]                           SMALLINT         NULL,
    [CreatedByUserId]                          [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                              [dbo].[UserDate] CONSTRAINT [DF_HealthCareQualityMeasureNumeratorTrend_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_HealthCareQualityMeasureNumeratorTrend] PRIMARY KEY CLUSTERED ([HealthCareQualityMeasureNumeratorTrendID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_HealthCareQualityMeasureNumeratorTrend_HealthCareQualityMeasure] FOREIGN KEY ([HealthCareQualityMeasureID]) REFERENCES [dbo].[HealthCareQualityMeasure] ([HealthCareQualityMeasureID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureNumeratorTrend', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureNumeratorTrend', @level2type = N'COLUMN', @level2name = N'CreatedDate';

