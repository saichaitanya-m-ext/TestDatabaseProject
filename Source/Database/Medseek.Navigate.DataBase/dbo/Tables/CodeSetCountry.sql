CREATE TABLE [dbo].[CodeSetCountry] (
    [CountryID]            [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [CountryCode]          VARCHAR (5)              NOT NULL,
    [CountryName]          [dbo].[ShortDescription] NOT NULL,
    [CountryDescription]   [dbo].[LongDescription]  NULL,
    [SortOrder]            SMALLINT                 CONSTRAINT [DF_CodeSetCountry_SortOrder] DEFAULT ('1') NULL,
    [DataSourceID]         [dbo].[KeyID]            NULL,
    [DataSourceFileID]     [dbo].[KeyID]            NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetCountry_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                      NOT NULL,
    [CreatedDate]          DATETIME                 CONSTRAINT [DF_CodeSetCountry_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                      NULL,
    [LastModifiedDate]     DATETIME                 NULL,
    CONSTRAINT [PK_CodeSetCountry] PRIMARY KEY CLUSTERED ([CountryID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetCountry_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetCountry_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_CodeSetCountry_LastProvider] FOREIGN KEY ([LastModifiedByUserId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_CodeSetCountry_Provider] FOREIGN KEY ([CreatedByUserId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [UQ_CodeSetCountry_Code] UNIQUE NONCLUSTERED ([CountryCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX],
    CONSTRAINT [UQ_CodeSetCountry_name] UNIQUE NONCLUSTERED ([CountryName] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

