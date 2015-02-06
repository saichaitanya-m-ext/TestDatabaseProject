CREATE TABLE [dbo].[CodeSetValueCode] (
    [ValueCodeID]          [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [ValueCode]            VARCHAR (10)            NOT NULL,
    [ValueName]            VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetValueCode_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetValueCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetValueCode] PRIMARY KEY CLUSTERED ([ValueCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetValueCode_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetValueCode_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetValueCode_ValueCode]
    ON [dbo].[CodeSetValueCode]([ValueCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetValueCode_ValueName]
    ON [dbo].[CodeSetValueCode]([ValueName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

