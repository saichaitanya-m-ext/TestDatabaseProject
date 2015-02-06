CREATE TABLE [dbo].[PatientDiagnosisCode] (
    [PatientDiagnosisCodeID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [DiagnosisCodeID]        [dbo].[KeyID]      NOT NULL,
    [PatientID]              [dbo].[KeyID]      NOT NULL,
    [DateOfService]          DATE               NOT NULL,
    [ClaimInfoID]            [dbo].[KeyID]      NOT NULL,
    [StatusCode]             [dbo].[StatusCode] CONSTRAINT [DF_PatientDiagnosisCode_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId]        [dbo].[KeyID]      NOT NULL,
    [CreatedDate]            [dbo].[UserDate]   CONSTRAINT [DF_PatientDiagnosisCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PatientDiagnosisCode] PRIMARY KEY CLUSTERED ([PatientDiagnosisCodeID] ASC),
    CONSTRAINT [FK_PatientDiagnosisCode_ClaimInfo] FOREIGN KEY ([ClaimInfoID]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_PatientDiagnosisCode_DiagnosisCode] FOREIGN KEY ([DiagnosisCodeID]) REFERENCES [dbo].[CodeSetICDDiagnosis] ([DiagnosisCodeID]),
    CONSTRAINT [FK_PatientDiagnosisCode_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientDiagnosisCode_DateOfService]
    ON [dbo].[PatientDiagnosisCode]([DateOfService] ASC)
    INCLUDE([PatientDiagnosisCodeID], [PatientID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX-CLAIMINFOID]
    ON [dbo].[PatientDiagnosisCode]([ClaimInfoID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientDiagnosisCode_PatientDiagnosisCodeID]
    ON [dbo].[PatientDiagnosisCode]([PatientID] ASC, [StatusCode] ASC, [DateOfService] ASC)
    INCLUDE([PatientDiagnosisCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientDiagnosisCode_Include]
    ON [dbo].[PatientDiagnosisCode]([DiagnosisCodeID] ASC)
    INCLUDE([PatientDiagnosisCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

