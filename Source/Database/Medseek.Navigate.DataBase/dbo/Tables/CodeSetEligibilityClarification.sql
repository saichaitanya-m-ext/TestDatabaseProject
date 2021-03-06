﻿CREATE TABLE [dbo].[CodeSetEligibilityClarification] (
    [EligibilityClarificationID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [EligibilityClarificationCode] VARCHAR (5)             NOT NULL,
    [EligibilityClarificationName] VARCHAR (30)            NOT NULL,
    [CodeDescription]              [dbo].[LongDescription] NULL,
    [DataSourceID]                 [dbo].[KeyID]           NULL,
    [DataSourceFileID]             [dbo].[KeyID]           NULL,
    [StatusCode]                   [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetEligibilityClarification_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]              INT                     NOT NULL,
    [CreatedDate]                  DATETIME                CONSTRAINT [DF_CodeSetEligibilityClarification_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]         INT                     NULL,
    [LastModifiedDate]             DATETIME                NULL,
    CONSTRAINT [PK_CodeSetEligibilityClarification] PRIMARY KEY CLUSTERED ([EligibilityClarificationID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetEligibilityClarification_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetEligibilityClarification_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetEligibilityClarification_Code] UNIQUE NONCLUSTERED ([EligibilityClarificationCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX],
    CONSTRAINT [UQ_CodeSetEligibilityClarification_name] UNIQUE NONCLUSTERED ([EligibilityClarificationID] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

