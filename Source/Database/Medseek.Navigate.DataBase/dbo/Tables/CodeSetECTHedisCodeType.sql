CREATE TABLE [dbo].[CodeSetECTHedisCodeType] (
    [ECTHedisCodeTypeID]   INT                IDENTITY (1, 1) NOT NULL,
    [ECTHedisCodeTypeCode] VARCHAR (20)       NOT NULL,
    [CodeTypeDescription]  VARCHAR (255)      NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetECTHedisCodeType_StatusCode] DEFAULT ('A') NOT NULL,
    [DataSourceID]         [dbo].[KeyID]      NULL,
    [DataSourceFileID]     [dbo].[KeyID]      NULL,
    [CreatedByUserID]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_CodeSetECTHedisCodeType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    [LkupCode]             VARCHAR (50)       NULL,
    CONSTRAINT [PK_CodeSetECTHedisCodeType] PRIMARY KEY CLUSTERED ([ECTHedisCodeTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetECTHedisCodeType_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetECTHedisCodeType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetECTHedisCodeType_ECTCodeTypeCode] UNIQUE NONCLUSTERED ([ECTHedisCodeTypeCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

