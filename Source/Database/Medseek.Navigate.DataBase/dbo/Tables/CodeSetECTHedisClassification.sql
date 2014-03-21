CREATE TABLE [dbo].[CodeSetECTHedisClassification] (
    [ECTHedisClassID]           INT              IDENTITY (1, 1) NOT NULL,
    [ECTHedisClassCode]         VARCHAR (20)     NOT NULL,
    [ClassificationDescription] VARCHAR (255)    NULL,
    [StatusCode]                VARCHAR (255)    CONSTRAINT [DF_CodeSetECTHedisClassification_StatusCode] DEFAULT ('A') NOT NULL,
    [DataSourceID]              [dbo].[KeyID]    NULL,
    [DataSourceFileID]          [dbo].[KeyID]    NULL,
    [CreatedByUserID]           [dbo].[KeyID]    NOT NULL,
    [CreatedDate]               [dbo].[UserDate] CONSTRAINT [DF_CodeSetECTHedisClassification_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]      [dbo].[KeyID]    NULL,
    [LastModifiedDate]          [dbo].[UserDate] NULL,
    CONSTRAINT [PK_CodeSetECTHedisClassification] PRIMARY KEY CLUSTERED ([ECTHedisClassID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetECTHedisClassification_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetECTHedisClassification_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetECTHedisClassification_ECTClassCode] UNIQUE NONCLUSTERED ([ECTHedisClassCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ECTHEDISClassification_ECTClassCode]
    ON [dbo].[CodeSetECTHedisClassification]([ECTHedisClassCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

