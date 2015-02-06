CREATE TABLE [dbo].[PQRIQualityMeasureGroupToMeasure] (
    [PQRIQualityMeasureGroupId] [dbo].[KeyID] NOT NULL,
    [PQRIQualityMeasureID]      [dbo].[KeyID] NOT NULL,
    [CreatedByUserId]           [dbo].[KeyID] NOT NULL,
    [CreatedDate]               DATETIME      CONSTRAINT [DF_PQRIQualityMeasureGroupToMeasure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PQRIQualityMeasureGroupToMeasure] PRIMARY KEY CLUSTERED ([PQRIQualityMeasureID] ASC, [PQRIQualityMeasureGroupId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PQRIQualityMeasureGroupToMeasure_PQRIQualityMeasure] FOREIGN KEY ([PQRIQualityMeasureID]) REFERENCES [dbo].[PQRIQualityMeasure] ([PQRIQualityMeasureID]),
    CONSTRAINT [FK_PQRIQualityMeasureGroupToMeasure_PQRIQualityMeasureGroup] FOREIGN KEY ([PQRIQualityMeasureGroupId]) REFERENCES [dbo].[PQRIQualityMeasureGroup] ([PQRIQualityMeasureGroupID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureGroupToMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureGroupToMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';

