CREATE TABLE [dbo].[CodeSetICDProcedure] (
    [ProcedureCodeID]           [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [ProcedureCode]             VARCHAR (10)       NOT NULL,
    [CodeTypeID]                [dbo].[KeyID]      NOT NULL,
    [ICDGroupID]                [dbo].[KeyID]      NULL,
    [BeginDate]                 [dbo].[UserDate]   NOT NULL,
    [EndDate]                   [dbo].[UserDate]   CONSTRAINT [DF_CodeSetICDProcedure_EndDate] DEFAULT ('01-01-2100') NOT NULL,
    [DataSourceID]              [dbo].[KeyID]      NULL,
    [DataSourceFileID]          [dbo].[KeyID]      NULL,
    [StatusCode]                [dbo].[StatusCode] CONSTRAINT [DF_CodeSetICDProcedure_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]           INT                NOT NULL,
    [CreatedDate]               DATETIME           CONSTRAINT [DF_CodeSetICDProcedure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]      INT                NULL,
    [LastModifiedDate]          DATETIME           NULL,
    [ProcedureShortDescription] VARCHAR (1000)     NULL,
    [ProcedureLongDescription]  VARCHAR (4000)     NULL,
    CONSTRAINT [PK_CodeSetICDProcedure] PRIMARY KEY CLUSTERED ([ProcedureCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetICDProcedure_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetICDProcedure_CodeSetICDGroup] FOREIGN KEY ([ICDGroupID]) REFERENCES [dbo].[CodeSetICDCodeGroup] ([ICDCodeGroupId]),
    CONSTRAINT [FK_CodeSetICDProcedure_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE NONCLUSTERED INDEX [IX_CodeSetICDProcedure_ProcedureCodeID_ProcedureCode_ProcedureShortDescription]
    ON [dbo].[CodeSetICDProcedure]([ProcedureCodeID] ASC)
    INCLUDE([ProcedureCode], [ProcedureShortDescription]) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
CREATE STATISTICS [stat_CodeSetICDProcedure_ProcedureCode_ProcedureCodeID]
    ON [dbo].[CodeSetICDProcedure]([ProcedureCode], [ProcedureCodeID]);

