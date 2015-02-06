CREATE TABLE [dbo].[Questionaire] (
    [QuestionaireId]       [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [QuestionaireName]     [dbo].[ShortDescription] NOT NULL,
    [Description]          [dbo].[LongDescription]  NOT NULL,
    [QuestionaireTypeId]   [dbo].[KeyID]            NOT NULL,
    [DiseaseID]            [dbo].[KeyID]            NULL,
    [CreatedByUserId]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_Questionaire_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_Questionaire_StatusCode] DEFAULT ('A') NOT NULL,
    [MaxScore]             INT                      NULL,
    CONSTRAINT [PK_Questionaire] PRIMARY KEY CLUSTERED ([QuestionaireId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_Questionaire_Disease] FOREIGN KEY ([DiseaseID]) REFERENCES [dbo].[Disease] ([DiseaseId]),
    CONSTRAINT [FK_Questionaire_QuestionaireType] FOREIGN KEY ([QuestionaireTypeId]) REFERENCES [dbo].[QuestionaireType] ([QuestionaireTypeId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Questionaire_QuestionaireName]
    ON [dbo].[Questionaire]([QuestionaireName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO

/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Insert_Questionaire]
Description:                   
When   Who   Action                    
---------------------------------------------------------------------    
19-May-2010  Pramod Dash Created                    
            
---------------------------------------------------------------------    
*/
CREATE TRIGGER [dbo].[tr_Insert_Questionaire] ON [dbo].[Questionaire]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON
      INSERT INTO
          QuestionaireQuestionSet
          (
            QuestionaireId ,
            QuestionSetId ,
            SortOrder ,
            StatusCode ,
            IsShowPanel ,
            IsShowQuestionSetName ,
            CreatedByUserId
          )
          SELECT
              INST.QuestionaireId ,
              ( SELECT
                    QuestionSetId
                FROM
                    QuestionSet
                WHERE
                    QuestionSetName = 'Finish' ) ,
              1 ,
              'A' ,
              0 ,
              0 ,
              INST.CreatedByUserId
          FROM
              INSERTED INST
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A collection of Question sest that are used to assess a patient health risk or condition', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Questionaire';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the Questionnaire table  - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Questionaire', @level2type = N'COLUMN', @level2name = N'QuestionaireId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the Questionnaire', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Questionaire', @level2type = N'COLUMN', @level2name = N'QuestionaireName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for Questionnaire table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Questionaire', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the QuestionnaireType table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Questionaire', @level2type = N'COLUMN', @level2name = N'QuestionaireTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Disease Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Questionaire', @level2type = N'COLUMN', @level2name = N'DiseaseID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Questionaire', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Questionaire', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Questionaire', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Questionaire', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Questionaire', @level2type = N'COLUMN', @level2name = N'StatusCode';

