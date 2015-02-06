CREATE TABLE [dbo].[MedicalProblemClassification] (
    [MedicalProblemClassificationId] [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ProblemClassName]               [dbo].[ShortDescription] NOT NULL,
    [Description]                    [dbo].[LongDescription]  NULL,
    [StatusCode]                     [dbo].[StatusCode]       CONSTRAINT [DF_MedicalProblemClassification_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]                [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                    [dbo].[UserDate]         CONSTRAINT [DF_MedicalProblemClassification_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]           [dbo].[KeyID]            NULL,
    [LastModifiedDate]               [dbo].[UserDate]         NULL,
    [isPatientViewable]              [dbo].[IsIndicator]      DEFAULT ('True') NULL,
    CONSTRAINT [PK_MedicalProblemClassification] PRIMARY KEY CLUSTERED ([MedicalProblemClassificationId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_MedicalProblemClassification_ProblemClassName]
    ON [dbo].[MedicalProblemClassification]([ProblemClassName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Classification system for medical problems', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the MedicalProblemClassification Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'MedicalProblemClassificationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the Medical Classification', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'ProblemClassName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for MedicalProblemClassification table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblemClassification', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

