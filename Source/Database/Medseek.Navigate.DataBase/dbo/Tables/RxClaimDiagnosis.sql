CREATE TABLE [dbo].[RxClaimDiagnosis] (
    [RxClaimDiagnosisID]   INT          IDENTITY (1, 1) NOT NULL,
    [RxClaimID]            INT          NOT NULL,
    [DiagnosisCodeID]      VARCHAR (5)  NOT NULL,
    [DataSourceID]         INT          NULL,
    [DataSourceFileID]     INT          NULL,
    [RecordTagFileID]      VARCHAR (30) NULL,
    [StatusCode]           VARCHAR (1)  CONSTRAINT [DF_RxClaimDiagnosis_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      INT          NOT NULL,
    [CreatedDate]          DATETIME     CONSTRAINT [DF_RxClaimDiagnosis_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] INT          NULL,
    [LastModifiedDate]     DATETIME     NULL,
    CONSTRAINT [PK_RxClaimDiagnosis] PRIMARY KEY CLUSTERED ([RxClaimID] ASC, [DiagnosisCodeID] ASC),
    CONSTRAINT [FK_RxClaimDiagnosis_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_RxClaimDiagnosis_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

