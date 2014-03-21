CREATE TABLE [dbo].[PQRIProviderQualityMeasureGroup] (
    [PQRIProviderPersonalizationID] [dbo].[KeyID]    NOT NULL,
    [PQRIQualityMeasureGroupID]     [dbo].[KeyID]    NOT NULL,
    [CreatedByUserId]               [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                   [dbo].[UserDate] CONSTRAINT [DF_PQRIProviderQualityMeasureGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PQRIProviderQualityMeasureGroup] PRIMARY KEY CLUSTERED ([PQRIProviderPersonalizationID] ASC, [PQRIQualityMeasureGroupID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PQRIProviderQualityMeasureGroup_PQRIProviderPersonalization] FOREIGN KEY ([PQRIProviderPersonalizationID]) REFERENCES [dbo].[PQRIProviderPersonalization] ([PQRIProviderPersonalizationID]),
    CONSTRAINT [FK_PQRIProviderQualityMeasureGroup_PQRIQualityMeasureGroup] FOREIGN KEY ([PQRIQualityMeasureGroupID]) REFERENCES [dbo].[PQRIQualityMeasureGroup] ([PQRIQualityMeasureGroupID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderQualityMeasureGroup', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderQualityMeasureGroup', @level2type = N'COLUMN', @level2name = N'CreatedDate';

