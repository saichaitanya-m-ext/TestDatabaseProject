CREATE TABLE [dbo].[HealthCareQualityMeasureHistory] (
    [HealthCareQualityMeasureHistoryId] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [HealthCareQualityMeasureID]        [dbo].[KeyID]    NULL,
    [NumeratorValue]                    DECIMAL (10, 2)  NULL,
    [DenominatorValue]                  DECIMAL (10, 2)  NULL,
    [NumeratorCount]                    INT              NULL,
    [DenominatorCount]                  INT              NULL,
    [FromDate]                          [dbo].[UserDate] NULL,
    [ToDate]                            [dbo].[UserDate] NULL,
    [EligiblePatients]                  INT              NULL,
    [PerformanceMet]                    INT              NULL,
    [PerformanceExclusions]             INT              NULL,
    [PerformanceNotMet]                 INT              NULL,
    [CreatedByUserId]                   [dbo].[KeyID]    NULL,
    [CreatedDate]                       [dbo].[UserDate] CONSTRAINT [DF_HealthCareQualityMeasureHistory_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModifiedByUserId]              [dbo].[KeyID]    NULL,
    [LastModifiedDate]                  [dbo].[UserDate] NULL,
    CONSTRAINT [PK_HealthCareQualityMeasureHistory] PRIMARY KEY CLUSTERED ([HealthCareQualityMeasureHistoryId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_HealthCareQualityMeasureHistory_HealthCareQualityMeasure] FOREIGN KEY ([HealthCareQualityMeasureID]) REFERENCES [dbo].[HealthCareQualityMeasure] ([HealthCareQualityMeasureID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityMeasureHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

