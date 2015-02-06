CREATE TABLE [dbo].[HealthCareQualityCategory] (
    [HealthCareQualityCategoryID]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [HealthCareQualityCategoryName] [dbo].[ShortDescription] NOT NULL,
    [CreatedByUserId]               [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                   [dbo].[UserDate]         CONSTRAINT [DF_HealthCareQualityCategory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_HealthCareQualityCategory] PRIMARY KEY CLUSTERED ([HealthCareQualityCategoryID] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_HealthCareQualityCategory_HealthCareQualityCategoryName]
    ON [dbo].[HealthCareQualityCategory]([HealthCareQualityCategoryName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityCategory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityCategory', @level2type = N'COLUMN', @level2name = N'CreatedDate';

