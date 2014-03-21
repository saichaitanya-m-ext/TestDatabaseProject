CREATE TABLE [dbo].[MedicalProblem] (
    [MedicalProblemId]               [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ProblemName]                    [dbo].[ShortDescription] NOT NULL,
    [Description]                    [dbo].[LongDescription]  NULL,
    [MedicalProblemClassificationId] [dbo].[KeyID]            NULL,
    [StatusCode]                     [dbo].[StatusCode]       CONSTRAINT [DF_MedicalProblem_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]                [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                    [dbo].[UserDate]         CONSTRAINT [DF_MedicalProblem_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]           [dbo].[KeyID]            NULL,
    [LastModifiedDate]               [dbo].[UserDate]         NULL,
    [IsShowPatientCriteria]          [dbo].[IsIndicator]      NULL,
    CONSTRAINT [PK_MedicalProblem] PRIMARY KEY CLUSTERED ([MedicalProblemId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_MedicalProblem_MedicalProblemClassification] FOREIGN KEY ([MedicalProblemClassificationId]) REFERENCES [dbo].[MedicalProblemClassification] ([MedicalProblemClassificationId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_MedicalProblem_ProblemName]
    ON [dbo].[MedicalProblem]([ProblemName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A medical problem like ulcer or a broken bone unlike a disease a problem is a temperary medical condition', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the MedicalProblem Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'MedicalProblemId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Medical Problem Name  different than disease problem can be cured (ulcer, indigestion)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'ProblemName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for MedicalProblem table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the MedicalProblemClassification Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'MedicalProblemClassificationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalProblem', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

