CREATE TABLE [dbo].[CodeSetGender] (
    [GenderID]             [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [GenderCode]           VARCHAR (1)             NOT NULL,
    [GenderName]           VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetGender_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetGender_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetGender] PRIMARY KEY CLUSTERED ([GenderID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetGender_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetGender_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetGender_GenderCode] UNIQUE NONCLUSTERED ([GenderCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX],
    CONSTRAINT [UQ_CodeSetGender_GenderName] UNIQUE NONCLUSTERED ([GenderName] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

