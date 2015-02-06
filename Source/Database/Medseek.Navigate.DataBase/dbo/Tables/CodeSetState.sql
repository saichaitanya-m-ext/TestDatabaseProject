CREATE TABLE [dbo].[CodeSetState] (
    [StateID]              [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [StateCode]            VARCHAR (20)             NOT NULL,
    [StateName]            [dbo].[ShortDescription] NOT NULL,
    [CountryID]            [dbo].[KeyID]            CONSTRAINT [DF_CodeSetState_CountryID] DEFAULT ('1') NOT NULL,
    [StateDescription]     [dbo].[LongDescription]  NULL,
    [SortOrder]            SMALLINT                 NULL,
    [DataSourceID]         [dbo].[KeyID]            NULL,
    [DataSourceFileID]     [dbo].[KeyID]            NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetState_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                      NOT NULL,
    [CreatedDate]          DATETIME                 CONSTRAINT [DF_CodeSetState_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                      NULL,
    [LastModifiedDate]     DATETIME                 NULL,
    CONSTRAINT [PK_CodeSetState] PRIMARY KEY CLUSTERED ([StateID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetState_CodeSetCountry] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[CodeSetCountry] ([CountryID]),
    CONSTRAINT [FK_CodeSetState_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetState]
    ON [dbo].[CodeSetState]([StateCode] ASC, [StateName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetState_StateCode]
    ON [dbo].[CodeSetState]([StateCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

