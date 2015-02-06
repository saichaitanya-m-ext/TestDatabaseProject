CREATE TABLE [dbo].[PQRIProviderQualityMeasure] (
    [PQRIProviderPersonalizationID] [dbo].[KeyID]    NOT NULL,
    [PQRIQualityMeasureID]          [dbo].[KeyID]    NOT NULL,
    [CreatedByUserId]               [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                   [dbo].[UserDate] CONSTRAINT [DF_PQRIProviderQualityMeasure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PQRIProviderQualityMeasure] PRIMARY KEY CLUSTERED ([PQRIProviderPersonalizationID] ASC, [PQRIQualityMeasureID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PQRIProviderQualityMeasure_PQRIProviderPersonalization] FOREIGN KEY ([PQRIProviderPersonalizationID]) REFERENCES [dbo].[PQRIProviderPersonalization] ([PQRIProviderPersonalizationID]),
    CONSTRAINT [FK_PQRIProviderQualityMeasure_PQRIQualityMeasure] FOREIGN KEY ([PQRIQualityMeasureID]) REFERENCES [dbo].[PQRIQualityMeasure] ([PQRIQualityMeasureID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderQualityMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderQualityMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';

