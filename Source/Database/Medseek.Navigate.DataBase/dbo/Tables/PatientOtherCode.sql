CREATE TABLE [dbo].[PatientOtherCode] (
    [PatientOtherCodeID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [PatientID]          [dbo].[KeyID]      NOT NULL,
    [DateOfService]      DATE               NOT NULL,
    [LkUpCodeTypeID]     [dbo].[KeyID]      NOT NULL,
    [OtherCodeID]        [dbo].[KeyID]      NOT NULL,
    [ClaimInfoId]        [dbo].[KeyID]      NOT NULL,
    [StatusCode]         [dbo].[StatusCode] CONSTRAINT [DF_PatientOtherCode_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId]    [dbo].[KeyID]      NOT NULL,
    [CreatedDate]        [dbo].[UserDate]   CONSTRAINT [DF_PatientOtherCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PPatientOtherCode] PRIMARY KEY CLUSTERED ([PatientOtherCodeID] ASC),
    CONSTRAINT [FK_PatientOtherCode_ClaimInfo] FOREIGN KEY ([ClaimInfoId]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_PatientOtherCode_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientMeasure_DateOfService]
    ON [dbo].[PatientOtherCode]([DateOfService] ASC)
    INCLUDE([PatientOtherCodeID], [PatientID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientOtherCode_Include]
    ON [dbo].[PatientOtherCode]([PatientID] ASC, [StatusCode] ASC, [DateOfService] ASC)
    INCLUDE([PatientOtherCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientOtherCode_OtherCodeID]
    ON [dbo].[PatientOtherCode]([OtherCodeID] ASC)
    INCLUDE([PatientOtherCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientOtherCode_[OtherCodeID]
    ON [dbo].[PatientOtherCode]([OtherCodeID] ASC)
    INCLUDE([PatientOtherCodeID], [LkUpCodeTypeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientOtherCode_StatusCode_PatientID_DateOfService_PatientOtherCodeID_ClaimInfoId]
    ON [dbo].[PatientOtherCode]([StatusCode] ASC, [PatientID] ASC, [DateOfService] ASC, [PatientOtherCodeID] ASC, [ClaimInfoId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE STATISTICS [stat_PatientOtherCode_ClaimInfoId_DateOfService_PatientID_StatusCode]
    ON [dbo].[PatientOtherCode]([ClaimInfoId], [DateOfService], [PatientID], [StatusCode]);


GO
CREATE STATISTICS [stat_PatientOtherCode_PatientOtherCodeID_ClaimInfoId]
    ON [dbo].[PatientOtherCode]([PatientOtherCodeID], [ClaimInfoId]);


GO
CREATE STATISTICS [stat_PatientOtherCode_PatientOtherCodeID_PatientID_StatusCode_DateOfService_ClaimInfoId]
    ON [dbo].[PatientOtherCode]([PatientOtherCodeID], [PatientID], [StatusCode], [DateOfService], [ClaimInfoId]);

