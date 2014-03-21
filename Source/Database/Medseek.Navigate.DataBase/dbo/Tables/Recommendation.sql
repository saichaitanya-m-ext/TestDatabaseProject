CREATE TABLE [dbo].[Recommendation] (
    [RecommendationId]                [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [RecommendationName]              VARCHAR (400)      NOT NULL,
    [Description]                     VARCHAR (400)      NULL,
    [DefaultFrequencyOfTitrationDays] INT                NULL,
    [SortOrder]                       [dbo].[KeyID]      CONSTRAINT [DF_Recommendation_SortOrder] DEFAULT ((1)) NOT NULL,
    [StatusCode]                      [dbo].[StatusCode] CONSTRAINT [DF_Recommendations_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedDate]                     [dbo].[UserDate]   CONSTRAINT [DF_Recommendations_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedByUserId]                 [dbo].[KeyID]      NOT NULL,
    [LastModifiedByUserId]            [dbo].[KeyID]      NULL,
    [LastModifiedDate]                [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_Recommendation] PRIMARY KEY CLUSTERED ([RecommendationId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Recommendation_RecommendationName]
    ON [dbo].[Recommendation]([RecommendationName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The collection of recommendations that can result from Medication Titration', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Recommendation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the Recommendation Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Recommendation', @level2type = N'COLUMN', @level2name = N'RecommendationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the recommendation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Recommendation', @level2type = N'COLUMN', @level2name = N'RecommendationName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for Recommendation table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Recommendation', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The default number of days between Medication Titration events', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Recommendation', @level2type = N'COLUMN', @level2name = N'DefaultFrequencyOfTitrationDays';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alternate Sort order for Recommendation table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Recommendation', @level2type = N'COLUMN', @level2name = N'SortOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Recommendation', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Recommendation', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Recommendation', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Recommendation', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Recommendation', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

