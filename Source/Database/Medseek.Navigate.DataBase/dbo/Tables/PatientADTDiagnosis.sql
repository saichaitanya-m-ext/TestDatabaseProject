CREATE TABLE [dbo].[PatientADTDiagnosis] (
    [PatientADTDiagnosisId] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PatientADTId]          [dbo].[KeyID]    NOT NULL,
    [DiagnosisCodeId]       [dbo].[KeyID]    NOT NULL,
    [CreatedByUserId]       [dbo].[KeyID]    NOT NULL,
    [CreatedDate]           [dbo].[UserDate] CONSTRAINT [DF_PatientADTDiagnosis_CreadtedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]  [dbo].[KeyID]    NULL,
    [LastModifiedDate]      [dbo].[UserDate] NULL,
    [DiagnosedDate]         [dbo].[UserDate] NULL,
    CONSTRAINT [PK_PatientADTDiagnosis] PRIMARY KEY CLUSTERED ([PatientADTDiagnosisId] ASC),
    CONSTRAINT [FK_PatientADTDiagnosis_CodeSetICDDiagnosis] FOREIGN KEY ([DiagnosisCodeId]) REFERENCES [dbo].[CodeSetICDDiagnosis] ([DiagnosisCodeID]),
    CONSTRAINT [FK_PatientADTDiagnosis_PatientADT] FOREIGN KEY ([PatientADTId]) REFERENCES [dbo].[PatientADT] ([PatientADTId])
);

