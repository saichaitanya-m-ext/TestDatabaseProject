﻿CREATE TABLE [dbo].[CodeSetAPC] (
    [APCCodeID]            [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [APCCode]              VARCHAR (10)            NOT NULL,
    [APCCodeName]          VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [BeginDate]            DATE                    NOT NULL,
    [EndDate]              DATE                    NOT NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetAPC_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetAPC_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetAPC] PRIMARY KEY CLUSTERED ([APCCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetAPC_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetAPC_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetAPC_APCCode]
    ON [dbo].[CodeSetAPC]([APCCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetAPC_APCCodeName]
    ON [dbo].[CodeSetAPC]([APCCodeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

