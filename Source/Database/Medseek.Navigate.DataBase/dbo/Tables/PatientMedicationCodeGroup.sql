CREATE TABLE [dbo].[PatientMedicationCodeGroup] (
    [RxClaimId]       [dbo].[KeyID]      NOT NULL,
    [CodeGroupingID]  [dbo].[KeyID]      NOT NULL,
    [StatusCode]      [dbo].[StatusCode] CONSTRAINT [DF_PatientMedicationCodeGroup_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId] [dbo].[KeyID]      NOT NULL,
    [CreatedDate]     [dbo].[UserDate]   CONSTRAINT [DF_PatientMedicationCodeGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PatientMedicationCodeGroup] PRIMARY KEY CLUSTERED ([RxClaimId] ASC, [CodeGroupingID] ASC),
    CONSTRAINT [FK_PatientMedicationCodeGroup_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_PatientMedicationCodeGroup_RxClaim] FOREIGN KEY ([RxClaimId]) REFERENCES [dbo].[RxClaim] ([RxClaimId])
);

