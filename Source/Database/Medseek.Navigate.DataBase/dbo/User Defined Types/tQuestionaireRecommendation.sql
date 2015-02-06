CREATE TYPE [dbo].[tQuestionaireRecommendation] AS TABLE (
    [DrugCodeId]              INT      NULL,
    [RecommendationNumber]    INT      NULL,
    [RecommendationFrequency] CHAR (1) NULL,
    [DurationNumber]          INT      NULL,
    [DurationFrequency]       CHAR (1) NULL);

