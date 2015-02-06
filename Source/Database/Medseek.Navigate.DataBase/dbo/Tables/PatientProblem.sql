CREATE TABLE [dbo].[PatientProblem] (
    [PatientProblemID]               [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PatientID]                      [dbo].[KeyID]           NOT NULL,
    [MedicalProblemId]               [dbo].[KeyID]           NULL,
    [Comments]                       [dbo].[LongDescription] NULL,
    [ProblemStartDate]               [dbo].[UserDate]        NULL,
    [ProblemEndDate]                 [dbo].[UserDate]        NULL,
    [StatusCode]                     [dbo].[StatusCode]      CONSTRAINT [DF_UserProbem_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]                [dbo].[KeyID]           NOT NULL,
    [CreatedDate]                    [dbo].[UserDate]        CONSTRAINT [DF_UserProbem_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]           [dbo].[KeyID]           NULL,
    [LastModifiedDate]               [dbo].[UserDate]        NULL,
    [MedicalProblemClassificationId] [dbo].[KeyID]           NULL,
    [DataSourceId]                   [dbo].[KeyID]           NULL,
    CONSTRAINT [PK_UserProbem] PRIMARY KEY CLUSTERED ([PatientProblemID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientProbem_MedicalProblem] FOREIGN KEY ([MedicalProblemId]) REFERENCES [dbo].[MedicalProblem] ([MedicalProblemId]),
    CONSTRAINT [FK_PatientProblem_DataSource] FOREIGN KEY ([DataSourceId]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientProblem_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_UserProblem_DataSourceId] FOREIGN KEY ([DataSourceId]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_UserProblem_MedicalProblemClassification] FOREIGN KEY ([MedicalProblemClassificationId]) REFERENCES [dbo].[MedicalProblemClassification] ([MedicalProblemClassificationId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'List of medical problems suffered by a patient.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserProblem Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'PatientProblemID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users Table (patient User ID)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'PatientID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the MedicalProblems Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'MedicalProblemId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the Patient started to have the problem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'ProblemStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the problem was resolved', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'ProblemEndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Medical ProblemClassification Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientProblem', @level2type = N'COLUMN', @level2name = N'MedicalProblemClassificationId';

