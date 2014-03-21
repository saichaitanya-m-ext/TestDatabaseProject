CREATE TABLE [dbo].[CodeSetECTHedisSubDomain] (
    [ECTHedisSubDomainID]   INT                IDENTITY (1, 1) NOT NULL,
    [ECTHedisSubDomainCode] VARCHAR (50)       NOT NULL,
    [SubDomainDescription]  VARCHAR (255)      NULL,
    [StatusCode]            [dbo].[StatusCode] CONSTRAINT [DF_CodeSetECTHedisSubDomain_StatusCode] DEFAULT ('A') NOT NULL,
    [DataSourceID]          [dbo].[KeyID]      NULL,
    [DataSourceFileID]      [dbo].[KeyID]      NULL,
    [CreatedByUserID]       [dbo].[KeyID]      NOT NULL,
    [CreatedDate]           [dbo].[UserDate]   CONSTRAINT [DF_CodeSetECTHedisSubDomain_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]  [dbo].[KeyID]      NULL,
    [LastModifiedDate]      [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_CodeSetECTHedisSubDomain] PRIMARY KEY CLUSTERED ([ECTHedisSubDomainID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetECTHedisSubDomain_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetECTHedisSubDomain_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ECTHEDISSubDomain_ECTSubDomainCode]
    ON [dbo].[CodeSetECTHedisSubDomain]([ECTHedisSubDomainCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

