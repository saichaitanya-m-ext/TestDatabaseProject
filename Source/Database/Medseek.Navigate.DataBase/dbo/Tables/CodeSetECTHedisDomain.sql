CREATE TABLE [dbo].[CodeSetECTHedisDomain] (
    [ECTHedisDomainID]     INT                IDENTITY (1, 1) NOT NULL,
    [ECTHedisDomainCode]   VARCHAR (20)       NOT NULL,
    [DomainDescription]    VARCHAR (255)      NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetECTHedisDomain_StatusCode] DEFAULT ('A') NOT NULL,
    [DataSourceID]         [dbo].[KeyID]      NULL,
    [DataSourceFileID]     [dbo].[KeyID]      NULL,
    [CreatedByUserID]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_CodeSetECTHedisDomain_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_CodeSetECTHedisDomain] PRIMARY KEY CLUSTERED ([ECTHedisDomainID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetECTHedisDomain_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetECTHedisDomain_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetECTHedisDomain_ECTDomainCode]
    ON [dbo].[CodeSetECTHedisDomain]([ECTHedisDomainCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

