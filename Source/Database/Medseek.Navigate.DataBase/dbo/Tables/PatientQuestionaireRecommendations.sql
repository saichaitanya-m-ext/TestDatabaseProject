CREATE TABLE [dbo].[PatientQuestionaireRecommendations] (
    [PatientQuestionaireId]    [dbo].[KeyID]    NOT NULL,
    [RecommendationId]         [dbo].[KeyID]    NOT NULL,
    [CreatedByUserId]          [dbo].[KeyID]    NOT NULL,
    [CreatedDate]              [dbo].[UserDate] CONSTRAINT [DF_PatientQuestionaireRecommendations_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [SysRecommendationId]      [dbo].[KeyID]    NULL,
    [FrequencyOfTitrationDays] INT              NOT NULL,
    [ActionComment]            VARCHAR (200)    NULL,
    CONSTRAINT [PK_PatientQuestionaireRecommendations] PRIMARY KEY CLUSTERED ([PatientQuestionaireId] ASC, [RecommendationId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientQuestionaireRecommendations_Recommendations] FOREIGN KEY ([RecommendationId]) REFERENCES [dbo].[Recommendation] ([RecommendationId]),
    CONSTRAINT [FK_PatientQuestionaireRecommendations_SysRecommendation] FOREIGN KEY ([SysRecommendationId]) REFERENCES [dbo].[Recommendation] ([RecommendationId]),
    CONSTRAINT [FK_QuestionaireRecommendations_PatientQuestionaire] FOREIGN KEY ([PatientQuestionaireId]) REFERENCES [dbo].[PatientQuestionaire] ([PatientQuestionaireId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The list of medication titration recommendation resulting from the instance of a questionnaire', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireRecommendations';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the UserQuestionaire table - indicates the Questionnaire', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireRecommendations', @level2type = N'COLUMN', @level2name = N'PatientQuestionaireId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Recommendation table This is the actual recommendation that was either system generated or overridden by the care provider', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireRecommendations', @level2type = N'COLUMN', @level2name = N'RecommendationId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireRecommendations', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireRecommendations', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireRecommendations', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireRecommendations', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the RecommendationId table -This is the Recommendation that the system logic generated', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireRecommendations', @level2type = N'COLUMN', @level2name = N'SysRecommendationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Number of days between medication titration events', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireRecommendations', @level2type = N'COLUMN', @level2name = N'FrequencyOfTitrationDays';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Free Form Comment field', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireRecommendations', @level2type = N'COLUMN', @level2name = N'ActionComment';

