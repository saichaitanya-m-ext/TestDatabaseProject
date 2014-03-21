CREATE TABLE [dbo].[CodeSetNameSuffix] (
    [NameSuffixID]         [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [NameSuffix]           VARCHAR (30)            NOT NULL,
    [SuffixDescription]    [dbo].[LongDescription] NULL,
    [SortOrder]            SMALLINT                NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetNameSuffix_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetNameSuffix_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetNameSuffix] PRIMARY KEY CLUSTERED ([NameSuffixID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNameSuffix_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNameSuffix_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetNameSuffix_NameSuffix] UNIQUE NONCLUSTERED ([NameSuffix] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

