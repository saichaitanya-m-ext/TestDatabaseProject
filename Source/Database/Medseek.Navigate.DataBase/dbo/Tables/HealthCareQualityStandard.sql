CREATE TABLE [dbo].[HealthCareQualityStandard] (
    [HealthCareQualityStandardID]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [HealthCareQualityStandardName] [dbo].[ShortDescription] NOT NULL,
    [CustomMeasureType]             VARCHAR (50)             NULL,
    [CreatedByUserId]               [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                   [dbo].[UserDate]         CONSTRAINT [DF_HealthCareQualityStandard_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_HealthCareQualityStandard] PRIMARY KEY CLUSTERED ([HealthCareQualityStandardID] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_HealthCareQualityStandard_HealthCareQualityStandardName]
    ON [dbo].[HealthCareQualityStandard]([HealthCareQualityStandardName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityStandard', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthCareQualityStandard', @level2type = N'COLUMN', @level2name = N'CreatedDate';

