CREATE TABLE [dbo].[QuestionaireRecommendation] (
    [QuestionaireRecommendationId] [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [QuestionaireId]               [dbo].[KeyID]       NOT NULL,
    [RecommendationId]             [dbo].[KeyID]       NOT NULL,
    [StopMedication]               [dbo].[IsIndicator] NULL,
    [DaysToNextQuestionnaire]      CHAR (2)            NULL,
    [StatusCode]                   [dbo].[StatusCode]  CONSTRAINT [DF_QuestionaireRecommendation_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]              [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                  [dbo].[UserDate]    CONSTRAINT [DF_QuestionaireRecommendation_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]         [dbo].[KeyID]       NULL,
    [LastModifiedDate]             [dbo].[UserDate]    NULL,
    [NextQuestionaireId]           INT                 NULL,
    CONSTRAINT [PK_QuestionaireRecommendation] PRIMARY KEY CLUSTERED ([QuestionaireRecommendationId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_QuestionaireRecommendation_NextQuestionaireId] FOREIGN KEY ([NextQuestionaireId]) REFERENCES [dbo].[Questionaire] ([QuestionaireId]),
    CONSTRAINT [FK_QuestionaireRecommendation_Questionaire] FOREIGN KEY ([QuestionaireId]) REFERENCES [dbo].[Questionaire] ([QuestionaireId]),
    CONSTRAINT [FK_QuestionaireRecommendation_Recommendation] FOREIGN KEY ([RecommendationId]) REFERENCES [dbo].[Recommendation] ([RecommendationId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_QuestionaireRecommendation_QuestionaireId]
    ON [dbo].[QuestionaireRecommendation]([QuestionaireId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

