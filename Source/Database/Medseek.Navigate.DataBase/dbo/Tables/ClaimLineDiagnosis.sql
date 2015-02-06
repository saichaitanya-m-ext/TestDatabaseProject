CREATE TABLE [dbo].[ClaimLineDiagnosis] (
    [ClaimLineDiagnosisID] INT              IDENTITY (1, 1) NOT NULL,
    [ClaimLineID]          INT              NOT NULL,
    [DiagnosisCodeID]      [dbo].[KeyID]    NOT NULL,
    [PurposeCodeID]        [dbo].[KeyID]    NOT NULL,
    [RankOrder]            TINYINT          NOT NULL,
    [DataSourceID]         [dbo].[KeyID]    NULL,
    [DataSourceFileID]     [dbo].[KeyID]    NULL,
    [RecordTagFileID]      VARCHAR (30)     NULL,
    [CreatedByUserId]      [dbo].[KeyID]    NOT NULL,
    [CreatedDate]          [dbo].[UserDate] CONSTRAINT [DF_ClaimLineDiagnosis_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ClaimLineDiagnosis] PRIMARY KEY CLUSTERED ([ClaimLineDiagnosisID] ASC),
    CONSTRAINT [FK_ClaimLineDiagnosis_ClaimLine] FOREIGN KEY ([ClaimLineID]) REFERENCES [dbo].[ClaimLine] ([ClaimLineID]),
    CONSTRAINT [FK_ClaimLineDiagnosis_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ClaimLineDiagnosis_CodeSetICDDiagnosis] FOREIGN KEY ([DiagnosisCodeID]) REFERENCES [dbo].[CodeSetICDDiagnosis] ([DiagnosisCodeID]),
    CONSTRAINT [FK_ClaimLineDiagnosis_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_ClaimLineDiagnosis_LkUpPurposeCode] FOREIGN KEY ([PurposeCodeID]) REFERENCES [dbo].[LkUpPurposeCode] ([PurposeCodeID])
);


GO
CREATE NONCLUSTERED INDEX [IX_ClaimLineDiagnosis_ClaimLineID]
    ON [dbo].[ClaimLineDiagnosis]([ClaimLineID] ASC)
    INCLUDE([ClaimLineDiagnosisID], [DiagnosisCodeID], [PurposeCodeID], [RankOrder]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [UQ_DiagnosisCodeID_ClaimLineDiagnosis]
    ON [dbo].[ClaimLineDiagnosis]([DiagnosisCodeID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE STATISTICS [stat_ClaimLineDiagnosis_DiagnosisCodeID_ClaimLineID]
    ON [dbo].[ClaimLineDiagnosis]([DiagnosisCodeID], [ClaimLineID]);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLineDiagnosis', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLineDiagnosis', @level2type = N'COLUMN', @level2name = N'CreatedDate';

