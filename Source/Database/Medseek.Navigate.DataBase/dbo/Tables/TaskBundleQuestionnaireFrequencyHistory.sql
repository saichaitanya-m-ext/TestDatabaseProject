CREATE TABLE [dbo].[TaskBundleQuestionnaireFrequencyHistory] (
    [TaskBundleQuestionnaireFrequencyID] [dbo].[KeyID]       NOT NULL,
    [TaskBundleId]                       [dbo].[KeyID]       NOT NULL,
    [DefinitionVersion]                  VARCHAR (5)         NOT NULL,
    [QuestionaireId]                     [dbo].[KeyID]       NOT NULL,
    [FrequencyNumber]                    INT                 NOT NULL,
    [Frequency]                          VARCHAR (1)         NOT NULL,
    [StatusCode]                         [dbo].[StatusCode]  NOT NULL,
    [IsPreventive]                       [dbo].[IsIndicator] NULL,
    [DiseaseID]                          [dbo].[KeyID]       NULL,
    [CreatedByUserId]                    [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                        [dbo].[UserDate]    CONSTRAINT [DF_TaskBundleQuestionnaireFrequencyHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_TaskBundleQuestionnaireFrequencyHistory] PRIMARY KEY CLUSTERED ([TaskBundleQuestionnaireFrequencyID] ASC, [DefinitionVersion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TaskBundleQuestionnaireFrequencyHistory_DiseaseID] FOREIGN KEY ([DiseaseID]) REFERENCES [dbo].[Disease] ([DiseaseId]),
    CONSTRAINT [FK_TaskBundleQuestionnaireFrequencyHistory_Questionaire] FOREIGN KEY ([QuestionaireId]) REFERENCES [dbo].[Questionaire] ([QuestionaireId]),
    CONSTRAINT [FK_TaskBundleQuestionnaireFrequencyHistory_TaskBundle] FOREIGN KEY ([TaskBundleId]) REFERENCES [dbo].[TaskBundle] ([TaskBundleId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleQuestionnaireFrequencyHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleQuestionnaireFrequencyHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';

