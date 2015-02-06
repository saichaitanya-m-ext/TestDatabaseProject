CREATE TABLE [dbo].[RecommendationDrugs] (
    [RecommendationDrugsID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [RecommendationID]      [dbo].[KeyID]      NOT NULL,
    [DrugCodeID]            [dbo].[KeyID]      NOT NULL,
    [Frequency]             CHAR (1)           NOT NULL,
    [FrequencyNumber]       INT                NOT NULL,
    [StatusCode]            [dbo].[StatusCode] CONSTRAINT [DF_RecommendationDrugs_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]       [dbo].[KeyID]      NOT NULL,
    [CreatedDate]           [dbo].[UserDate]   CONSTRAINT [DF_RecommendationDrugs_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]  [dbo].[KeyID]      NULL,
    [LastModifiedDate]      [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_RecommendationDrugs] PRIMARY KEY CLUSTERED ([RecommendationDrugsID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_RecommendationDrugs_CodeSetDrug] FOREIGN KEY ([DrugCodeID]) REFERENCES [dbo].[CodeSetDrug] ([DrugCodeId]),
    CONSTRAINT [FK_RecommendationDrugs_Recommendation] FOREIGN KEY ([RecommendationID]) REFERENCES [dbo].[Recommendation] ([RecommendationId])
);

