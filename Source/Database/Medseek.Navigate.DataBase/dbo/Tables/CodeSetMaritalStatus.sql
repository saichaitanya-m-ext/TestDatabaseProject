CREATE TABLE [dbo].[CodeSetMaritalStatus] (
    [MaritalStatusID]      [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [MaritalStatusCode]    VARCHAR (2)             NOT NULL,
    [MaritalStatusName]    VARCHAR (30)            NOT NULL,
    [StatusDescription]    [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetMaritalStatus_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetMaritalStatus_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetMaritalStatus] PRIMARY KEY CLUSTERED ([MaritalStatusID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetMaritalStatus_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetMaritalStatus_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetMaritalStatus_MaritalCode] UNIQUE NONCLUSTERED ([MaritalStatusCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX],
    CONSTRAINT [UQ_CodeSetMaritalStatus_MaritalStatus] UNIQUE NONCLUSTERED ([MaritalStatusName] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

