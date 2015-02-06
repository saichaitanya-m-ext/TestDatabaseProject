CREATE TABLE [dbo].[CodeSetICDDiagnosis] (
    [DiagnosisCodeID]           [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [DiagnosisCode]             VARCHAR (10)       NOT NULL,
    [CodeTypeID]                [dbo].[KeyID]      NOT NULL,
    [ICDGroupID]                [dbo].[KeyID]      NULL,
    [BeginDate]                 [dbo].[UserDate]   NULL,
    [EndDate]                   [dbo].[UserDate]   CONSTRAINT [DF_CodeSetICDDiagnosis_EndDate] DEFAULT ('01-01-2100') NULL,
    [DataSourceID]              [dbo].[KeyID]      NULL,
    [DataSourceFileID]          [dbo].[KeyID]      NULL,
    [StatusCode]                [dbo].[StatusCode] CONSTRAINT [DF_CodeSetICDDiagnosis_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]           INT                NOT NULL,
    [CreatedDate]               DATETIME           CONSTRAINT [DF_CodeSetICDDiagnosis_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]      INT                NULL,
    [LastModifiedDate]          DATETIME           NULL,
    [DiagnosisShortDescription] VARCHAR (1000)     NULL,
    [DiagnosisLongDescription]  VARCHAR (4000)     NULL,
    CONSTRAINT [PK_CodeSetICDDiagnosis] PRIMARY KEY CLUSTERED ([DiagnosisCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetICDDiagnosis_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetICDDiagnosis_CodeSetICDCodeGroup] FOREIGN KEY ([ICDGroupID]) REFERENCES [dbo].[CodeSetICDCodeGroup] ([ICDCodeGroupId]),
    CONSTRAINT [FK_CodeSetICDDiagnosis_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE NONCLUSTERED INDEX [IX_CodeSetICDDiagnosis_DiagnosisCodeID_DiagnosisCode_DiagnosisLongDescription]
    ON [dbo].[CodeSetICDDiagnosis]([DiagnosisCodeID] ASC)
    INCLUDE([DiagnosisCode], [DiagnosisLongDescription]) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
CREATE STATISTICS [stat_CodeSetICDDiagnosis_DiagnosisCode_DiagnosisCodeID]
    ON [dbo].[CodeSetICDDiagnosis]([DiagnosisCode], [DiagnosisCodeID]);

