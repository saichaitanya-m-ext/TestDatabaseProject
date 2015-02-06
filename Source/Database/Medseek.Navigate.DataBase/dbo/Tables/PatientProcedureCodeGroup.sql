CREATE TABLE [dbo].[PatientProcedureCodeGroup] (
    [PatientProcedureCodeID] [dbo].[KeyID]      NOT NULL,
    [CodeGroupingID]         [dbo].[KeyID]      NOT NULL,
    [StatusCode]             [dbo].[StatusCode] CONSTRAINT [DF_PatientProcedureCodeGroup_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId]        [dbo].[KeyID]      NOT NULL,
    [CreatedDate]            [dbo].[UserDate]   CONSTRAINT [DF_PatientProcedureCodeGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PatientProcedureCodeGroup] PRIMARY KEY CLUSTERED ([PatientProcedureCodeID] ASC, [CodeGroupingID] ASC),
    CONSTRAINT [FK_PatientProcedureCodeGroup_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_PatientProcedureCodeGroup_PatientProcedureCode] FOREIGN KEY ([PatientProcedureCodeID]) REFERENCES [dbo].[PatientProcedureCode] ([PatientProcedureCodeID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientProcedureCodeGroup_StatusCode]
    ON [dbo].[PatientProcedureCodeGroup]([StatusCode] ASC)
    INCLUDE([PatientProcedureCodeID], [CodeGroupingID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientProcedureCodeGroup_CodeGroupingID]
    ON [dbo].[PatientProcedureCodeGroup]([CodeGroupingID] ASC, [StatusCode] ASC)
    INCLUDE([PatientProcedureCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

