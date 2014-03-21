CREATE TABLE [dbo].[CodeSetEntityType] (
    [EntityTypeID]         INT                IDENTITY (1, 1) NOT NULL,
    [EntityTypeCode]       VARCHAR (1)        NOT NULL,
    [EntityType]           VARCHAR (30)       NOT NULL,
    [TypeDescription]      VARCHAR (30)       NULL,
    [DataSourceID]         [dbo].[KeyID]      NULL,
    [DataSourceFileID]     [dbo].[KeyID]      NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetEntityType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_CodeSetEntityType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_CodeSetEntityType] PRIMARY KEY CLUSTERED ([EntityTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetEntityType_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetEntityType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetEntityType_EntityTypeCode]
    ON [dbo].[CodeSetEntityType]([EntityTypeCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetEntityType_EntityType]
    ON [dbo].[CodeSetEntityType]([EntityType] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

