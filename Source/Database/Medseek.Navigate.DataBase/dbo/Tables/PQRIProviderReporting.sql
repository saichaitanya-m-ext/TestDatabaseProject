CREATE TABLE [dbo].[PQRIProviderReporting] (
    [PQRIProviderReportingID]     [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PQRIProviderUserEncounterID] [dbo].[KeyID]    NULL,
    [PQRIQualityMeasureID]        [dbo].[KeyID]    NULL,
    [CreatedByUserId]             [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                 [dbo].[UserDate] CONSTRAINT [DF_PQRIProviderUserEncounterStatistics_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PQRIProviderUserEncounterStatistics] PRIMARY KEY CLUSTERED ([PQRIProviderReportingID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PQRIProviderReporting_PQRIProviderUserEncounter] FOREIGN KEY ([PQRIProviderUserEncounterID]) REFERENCES [dbo].[PQRIProviderUserEncounter] ([PQRIProviderUserEncounterID]),
    CONSTRAINT [FK_PQRIProviderUserEncounterStatistics_PQRIQualityMeasure] FOREIGN KEY ([PQRIQualityMeasureID]) REFERENCES [dbo].[PQRIQualityMeasure] ([PQRIQualityMeasureID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderReporting', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderReporting', @level2type = N'COLUMN', @level2name = N'CreatedDate';

