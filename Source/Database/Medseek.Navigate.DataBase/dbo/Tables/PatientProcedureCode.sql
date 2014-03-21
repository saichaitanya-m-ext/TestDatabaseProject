CREATE TABLE [dbo].[PatientProcedureCode] (
    [PatientProcedureCodeID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [PatientID]              [dbo].[KeyID]      NOT NULL,
    [DateOfService]          DATE               NOT NULL,
    [LkUpCodeTypeID]         [dbo].[KeyID]      NOT NULL,
    [ProcedureCodeID]        [dbo].[KeyID]      NOT NULL,
    [ClaimInfoId]            [dbo].[KeyID]      NOT NULL,
    [StatusCode]             [dbo].[StatusCode] CONSTRAINT [DF_PatientProcedureCode_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId]        [dbo].[KeyID]      NOT NULL,
    [CreatedDate]            [dbo].[UserDate]   CONSTRAINT [DF_PatientProcedureCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PatientProcedureCode] PRIMARY KEY CLUSTERED ([PatientProcedureCodeID] ASC),
    CONSTRAINT [FK_PatientProcedureCode_ClaimInfo] FOREIGN KEY ([ClaimInfoId]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_PatientProcedureCode_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientProcedureCode_DateOfService]
    ON [dbo].[PatientProcedureCode]([DateOfService] ASC)
    INCLUDE([PatientProcedureCodeID], [PatientID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [<IX_PatientID,Dateofservice,>]
    ON [dbo].[PatientProcedureCode]([StatusCode] ASC, [DateOfService] ASC)
    INCLUDE([PatientProcedureCodeID], [PatientID], [ClaimInfoId]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientProcedureCode_PatientProcedureCodeID]
    ON [dbo].[PatientProcedureCode]([PatientID] ASC, [StatusCode] ASC, [DateOfService] ASC)
    INCLUDE([PatientProcedureCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientProcedureCode_ProcedureCodeID]
    ON [dbo].[PatientProcedureCode]([ProcedureCodeID] ASC)
    INCLUDE([PatientProcedureCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientProcedureCode_LkUpCodeTypeID]
    ON [dbo].[PatientProcedureCode]([LkUpCodeTypeID] ASC, [ProcedureCodeID] ASC)
    INCLUDE([PatientProcedureCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientProcedureCode_StatusCode_PatientID_DateOfService_PatientProcedureCodeID_ClaimInfoId]
    ON [dbo].[PatientProcedureCode]([StatusCode] ASC, [PatientID] ASC, [DateOfService] ASC, [PatientProcedureCodeID] ASC, [ClaimInfoId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_StatusCode_PID_DOS_PCI]
    ON [dbo].[PatientProcedureCode]([StatusCode] ASC)
    INCLUDE([PatientID], [DateOfService], [ProcedureCodeID]);


GO
CREATE STATISTICS [stat_PatientProcedureCode_DateOfService_PatientID]
    ON [dbo].[PatientProcedureCode]([DateOfService], [PatientID]);


GO
CREATE STATISTICS [stat_PatientProcedureCode_PatientProcedureCodeID_ClaimInfoId]
    ON [dbo].[PatientProcedureCode]([PatientProcedureCodeID], [ClaimInfoId]);


GO
CREATE STATISTICS [stat_PatientProcedureCode_PatientProcedureCodeID_PatientID_StatusCode]
    ON [dbo].[PatientProcedureCode]([PatientProcedureCodeID], [PatientID], [StatusCode]);

