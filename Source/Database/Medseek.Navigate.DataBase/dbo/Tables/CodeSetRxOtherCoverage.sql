﻿CREATE TABLE [dbo].[CodeSetRxOtherCoverage] (
    [RxOtherCoverageID]    [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [RxOtherCoverageCode]  VARCHAR (5)             NOT NULL,
    [RxOtherCoverageName]  VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetRxOtherCoverage_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetRxOtherCoverage_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetRxOtherCoverage] PRIMARY KEY CLUSTERED ([RxOtherCoverageID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetRxOtherCoverage_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetRxOtherCoverage_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxOtherCoverage_RxOtherCoverageCode]
    ON [dbo].[CodeSetRxOtherCoverage]([RxOtherCoverageCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxOtherCoverage_RxOtherCoverageName]
    ON [dbo].[CodeSetRxOtherCoverage]([RxOtherCoverageName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

