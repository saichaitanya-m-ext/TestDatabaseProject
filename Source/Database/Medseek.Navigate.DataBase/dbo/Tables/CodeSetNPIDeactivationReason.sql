CREATE TABLE [dbo].[CodeSetNPIDeactivationReason] (
    [DeactivationReasonCodeID] [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [DeactivationReasonCode]   VARCHAR (2)             NOT NULL,
    [DeactivationReasonName]   VARCHAR (30)            NOT NULL,
    [ReasonDescription]        [dbo].[LongDescription] NULL,
    [DataSourceID]             [dbo].[KeyID]           NULL,
    [DataSourceFileID]         [dbo].[KeyID]           NULL,
    [StatusCode]               [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetNPIDeactivationReason_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]          INT                     NOT NULL,
    [CreatedDate]              DATETIME                CONSTRAINT [DF_CodeSetNPIDeactivationReason_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]     INT                     NULL,
    [LastModifiedDate]         DATETIME                NULL,
    CONSTRAINT [PK_CodeSetNPIDeactivationReason] PRIMARY KEY CLUSTERED ([DeactivationReasonCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNPIDeactivationReason_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNPIDeactivationReason_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetNPIDeactivationReason_Code] UNIQUE NONCLUSTERED ([DeactivationReasonCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX],
    CONSTRAINT [UQ_CodeSetNPIDeactivationReason_DeactivationReasonName] UNIQUE NONCLUSTERED ([DeactivationReasonName] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

