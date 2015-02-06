CREATE TABLE [dbo].[PatientICDProcedure] (
    [PatientICDProcedureID] [dbo].[KeyID]    NOT NULL,
    [PatientID]             [dbo].[KeyID]    NOT NULL,
    [ProcedureCodeID]       [dbo].[KeyID]    NOT NULL,
    [ClaimInfoID]           [dbo].[KeyID]    NOT NULL,
    [DateOfAdmit]           [dbo].[UserDate] NOT NULL,
    [Comments]              VARCHAR (255)    NULL,
    [DataSourceID]          [dbo].[KeyID]    NULL,
    [DataFileID]            [dbo].[KeyID]    NULL,
    [StatusCode]            VARCHAR (1)      CONSTRAINT [DF_PatientICDProcedure_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]       [dbo].[KeyID]    NOT NULL,
    [CreatedDate]           [dbo].[UserDate] CONSTRAINT [DF_PatientICDProcedure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]  [dbo].[KeyID]    NULL,
    [LastModifiedDate]      [dbo].[UserDate] NULL,
    CONSTRAINT [PK_PatientICDProcedure] PRIMARY KEY CLUSTERED ([PatientID] ASC, [ProcedureCodeID] ASC, [ClaimInfoID] ASC, [DateOfAdmit] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_PatientICDProcedure_ClaimInfo] FOREIGN KEY ([ClaimInfoID]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_PatientICDProcedure_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientICDProcedure_DataSourceFile] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

