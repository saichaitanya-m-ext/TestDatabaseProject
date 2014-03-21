CREATE TABLE [dbo].[PatientQuestionaireDrugs] (
    [PatientQuestionaireDrugID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PatientDrugID]             [dbo].[KeyID]    NULL,
    [CreatedByUserId]           [dbo].[KeyID]    NOT NULL,
    [CreatedDate]               [dbo].[UserDate] CONSTRAINT [DF_PatientQuestionaireDrugs_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [PatientQuestionaireID]     [dbo].[KeyID]    NULL,
    CONSTRAINT [PK_PatientQuestionaireDrugs] PRIMARY KEY CLUSTERED ([PatientQuestionaireDrugID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientQuestionaireDrugs_PatientDrugCodes] FOREIGN KEY ([PatientDrugID]) REFERENCES [dbo].[PatientDrugCodes] ([PatientDrugId]),
    CONSTRAINT [FK_PatientQuestionaireDrugs_PatientQuestionaire] FOREIGN KEY ([PatientQuestionaireID]) REFERENCES [dbo].[PatientQuestionaire] ([PatientQuestionaireId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireDrugs', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientQuestionaireDrugs', @level2type = N'COLUMN', @level2name = N'CreatedDate';

