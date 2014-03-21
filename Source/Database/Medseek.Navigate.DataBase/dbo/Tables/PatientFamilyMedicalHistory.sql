CREATE TABLE [dbo].[PatientFamilyMedicalHistory] (
    [PatientFamilyMedicalHistoryID] [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PatientID]                     [dbo].[KeyID]           NULL,
    [DiseaseID]                     [dbo].[KeyID]           NULL,
    [RelationID]                    [dbo].[KeyID]           NOT NULL,
    [Comments]                      [dbo].[LongDescription] NULL,
    [StartDate]                     DATE                    NULL,
    [EndDate]                       DATE                    NULL,
    [CreatedByUserId]               [dbo].[KeyID]           NOT NULL,
    [CreatedDate]                   [dbo].[UserDate]        CONSTRAINT [DF_UserFamilyMedicalHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          [dbo].[KeyID]           NULL,
    [LastModifiedDate]              [dbo].[UserDate]        NULL,
    [StatusCode]                    [dbo].[StatusCode]      CONSTRAINT [DF_UserFamilyMedicalHistory_StatusCode] DEFAULT ('A') NOT NULL,
    [DataSourceId]                  [dbo].[KeyID]           NULL,
    CONSTRAINT [PK_PatientFamilyMedicalHistory] PRIMARY KEY CLUSTERED ([PatientFamilyMedicalHistoryID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_PatientFamilyMedicalHistory_CodeSetDataSource] FOREIGN KEY ([DataSourceId]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientFamilyMedicalHistory_DiseaseID] FOREIGN KEY ([DiseaseID]) REFERENCES [dbo].[Disease] ([DiseaseId]),
    CONSTRAINT [FK_PatientFamilyMedicalHistory_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientFamilyMedicalHistory_Provider] FOREIGN KEY ([CreatedByUserId]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_UserFamilyMedicalHistory]
    ON [dbo].[PatientFamilyMedicalHistory]([PatientID] ASC, [DiseaseID] ASC, [RelationID] ASC, [StartDate] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientFamilyMedicalHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientFamilyMedicalHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientFamilyMedicalHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientFamilyMedicalHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

