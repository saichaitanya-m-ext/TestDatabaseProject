CREATE TABLE [dbo].[HealthCareQualityBCategory] (
    [HealthCareQualityBCategoryId]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [HealthCareQualityCategoryId]    [dbo].[KeyID]            NULL,
    [HealthCareQualityBCategoryName] [dbo].[ShortDescription] NULL,
    [CreatedByUserId]                [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                    [dbo].[UserDate]         CONSTRAINT [DF_HealthCareQualityBCategory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_HealthCareQualityBCategory] PRIMARY KEY CLUSTERED ([HealthCareQualityBCategoryId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_HealthCareQualityBCategory_HealthCareQualityCategory] FOREIGN KEY ([HealthCareQualityCategoryId]) REFERENCES [dbo].[HealthCareQualityCategory] ([HealthCareQualityCategoryID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityBCategory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityBCategory', @level2type = N'COLUMN', @level2name = N'CreatedDate';

