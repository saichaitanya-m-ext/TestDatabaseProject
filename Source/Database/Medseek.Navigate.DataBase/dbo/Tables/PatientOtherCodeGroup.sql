CREATE TABLE [dbo].[PatientOtherCodeGroup] (
    [PatientOtherCodeID] [dbo].[KeyID]      NOT NULL,
    [CodeGroupingID]     [dbo].[KeyID]      NOT NULL,
    [StatusCode]         [dbo].[StatusCode] CONSTRAINT [DF_PatientOtherCodeGroup_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId]    [dbo].[KeyID]      NOT NULL,
    [CreatedDate]        [dbo].[UserDate]   CONSTRAINT [DF_PatientOtherCodeGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PatientOtherCodeGroup] PRIMARY KEY CLUSTERED ([PatientOtherCodeID] ASC, [CodeGroupingID] ASC),
    CONSTRAINT [FK_PatientOtherCodeGroup_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_PatientOtherCodeGroup_PatientOtherCode] FOREIGN KEY ([PatientOtherCodeID]) REFERENCES [dbo].[PatientOtherCode] ([PatientOtherCodeID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientOtherCodeGroup_[StatusCode]
    ON [dbo].[PatientOtherCodeGroup]([CodeGroupingID] ASC, [StatusCode] ASC)
    INCLUDE([PatientOtherCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientOtherCodeGroup_StatusCode_PatientOtherCodeID]
    ON [dbo].[PatientOtherCodeGroup]([StatusCode] ASC, [PatientOtherCodeID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE STATISTICS [stat_PatientOtherCodeGroup_CodeGroupingID_StatusCode_PatientOtherCodeID]
    ON [dbo].[PatientOtherCodeGroup]([CodeGroupingID], [StatusCode], [PatientOtherCodeID]);


GO
CREATE STATISTICS [stat_PatientOtherCodeGroup_PatientOtherCodeID_StatusCode]
    ON [dbo].[PatientOtherCodeGroup]([PatientOtherCodeID], [StatusCode]);

