CREATE TABLE [dbo].[PatientDiagnosisCodeGroup] (
    [PatientDiagnosisCodeID] [dbo].[KeyID]      NOT NULL,
    [CodeGroupingID]         [dbo].[KeyID]      NOT NULL,
    [StatusCode]             [dbo].[StatusCode] CONSTRAINT [DF_PatientDiagnosisCodeGroup_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId]        [dbo].[KeyID]      NOT NULL,
    [CreatedDate]            [dbo].[UserDate]   CONSTRAINT [DF_PatientDiagnosisCodeGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PatientDiagnosisCodeGroup] PRIMARY KEY CLUSTERED ([PatientDiagnosisCodeID] ASC, [CodeGroupingID] ASC),
    CONSTRAINT [FK_PatientDiagnosisCodeGroup_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_PatientDiagnosisCodeGroup_PatientDiagnosisCode] FOREIGN KEY ([PatientDiagnosisCodeID]) REFERENCES [dbo].[PatientDiagnosisCode] ([PatientDiagnosisCodeID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientDiagnosisCodeGroup_StatusCode]
    ON [dbo].[PatientDiagnosisCodeGroup]([CodeGroupingID] ASC, [StatusCode] ASC)
    INCLUDE([PatientDiagnosisCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

