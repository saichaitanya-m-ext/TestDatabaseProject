CREATE TABLE [dbo].[RecommendationRule] (
    [RecommendationRuleID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [RecommendationID]     [dbo].[KeyID]      NULL,
    [StopMedication]       CHAR (1)           NULL,
    [NextQuestionaireID]   [dbo].[KeyID]      NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_RecommendationRule_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_RecommendationRule_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_RecommendationRule] PRIMARY KEY CLUSTERED ([RecommendationRuleID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_RecommendationRule_Questionaire] FOREIGN KEY ([NextQuestionaireID]) REFERENCES [dbo].[Questionaire] ([QuestionaireId]),
    CONSTRAINT [FK_RecommendationRule_Recommendation] FOREIGN KEY ([RecommendationID]) REFERENCES [dbo].[Recommendation] ([RecommendationId])
);

