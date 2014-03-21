CREATE TABLE [dbo].[CodeSetNamePrefix] (
    [NamePrefixID]         [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [NamePrefix]           VARCHAR (20)            NOT NULL,
    [PrefixDescription]    [dbo].[LongDescription] NULL,
    [SortOrder]            SMALLINT                NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetNamePrefix_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetNamePrefix_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetNamePrefix] PRIMARY KEY CLUSTERED ([NamePrefixID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNamePrefix_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNamePrefix_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetNamePrefix_NamePrefix] UNIQUE NONCLUSTERED ([NamePrefix] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

