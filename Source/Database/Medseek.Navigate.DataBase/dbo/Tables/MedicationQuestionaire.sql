CREATE TABLE [dbo].[MedicationQuestionaire] (
    [MedicationQuestionaireID]     INT         IDENTITY (1, 1) NOT NULL,
    [QuestionaireRecommendationId] INT         NOT NULL,
    [DrugCodeId]                   INT         NOT NULL,
    [RecommendationNumber]         INT         NOT NULL,
    [RecommendationFrequency]      CHAR (1)    NOT NULL,
    [DurationNumber]               INT         NOT NULL,
    [DurationFrequency]            CHAR (1)    NOT NULL,
    [StatusCode]                   VARCHAR (1) CONSTRAINT [DF_MedicationQuestionaire_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]              INT         NOT NULL,
    [CreatedDate]                  DATETIME    CONSTRAINT [DF_MedicationQuestionaire_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]         INT         NULL,
    [LastModifiedDate]             DATETIME    NULL,
    CONSTRAINT [PK_MedicationQuestionaire] PRIMARY KEY CLUSTERED ([MedicationQuestionaireID] ASC),
    CONSTRAINT [FK_MedicationQuestionaire_CodeSetDrug] FOREIGN KEY ([DrugCodeId]) REFERENCES [dbo].[CodeSetDrug] ([DrugCodeId])
);

