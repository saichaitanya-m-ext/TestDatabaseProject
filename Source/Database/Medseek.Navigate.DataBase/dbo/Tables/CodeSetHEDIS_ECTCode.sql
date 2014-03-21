CREATE TABLE [dbo].[CodeSetHEDIS_ECTCode] (
    [HEDIS_ECTCodeID]      INT              IDENTITY (1, 1) NOT NULL,
    [ECTCode]              VARCHAR (20)     NULL,
    [ECTCodeDescription]   VARCHAR (255)    NULL,
    [ECTHedisMeasureID]    [dbo].[KeyID]    NOT NULL,
    [ECTHedisDomainID]     [dbo].[KeyID]    NOT NULL,
    [ECTHedisSubDomainID]  [dbo].[KeyID]    NOT NULL,
    [ECTHedisClassID]      [dbo].[KeyID]    NOT NULL,
    [ECTHedisTableID]      [dbo].[KeyID]    NOT NULL,
    [ECTHedisCodeTypeID]   [dbo].[KeyID]    NOT NULL,
    [IsBillingValid]       BIT              NULL,
    [VersionYear]          INT              NOT NULL,
    [StatusCode]           VARCHAR (1)      CONSTRAINT [DF_CodeSetHEDIS_ECTCode_StatusCode] DEFAULT ('A') NULL,
    [DataSourceID]         [dbo].[KeyID]    NULL,
    [DataSourceFileID]     [dbo].[KeyID]    NULL,
    [CreatedByUserID]      [dbo].[KeyID]    NOT NULL,
    [CreatedDate]          [dbo].[UserDate] CONSTRAINT [DF_CodeSetHEDIS_ECTCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]    NULL,
    [LastModifiedDate]     [dbo].[UserDate] NULL,
    [ECTCodeID]            INT              NULL,
    CONSTRAINT [PK_CodeSetHEDIS_ECTCode] PRIMARY KEY CLUSTERED ([HEDIS_ECTCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetHEDIS_ECTCode_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetHEDIS_ECTCode_CodeSetECTHedisClassification] FOREIGN KEY ([ECTHedisClassID]) REFERENCES [dbo].[CodeSetECTHedisClassification] ([ECTHedisClassID]),
    CONSTRAINT [FK_CodeSetHEDIS_ECTCode_CodeSetECTHedisCodeType] FOREIGN KEY ([ECTHedisCodeTypeID]) REFERENCES [dbo].[CodeSetECTHedisCodeType] ([ECTHedisCodeTypeID]),
    CONSTRAINT [FK_CodeSetHEDIS_ECTCode_CodeSetECTHedisDomain] FOREIGN KEY ([ECTHedisDomainID]) REFERENCES [dbo].[CodeSetECTHedisDomain] ([ECTHedisDomainID]),
    CONSTRAINT [FK_CodeSetHEDIS_ECTCode_CodeSetECTHedisMeasure] FOREIGN KEY ([ECTHedisMeasureID]) REFERENCES [dbo].[CodeSetECTHedisMeasure] ([ECTHedisMeasureID]),
    CONSTRAINT [FK_CodeSetHEDIS_ECTCode_CodeSetECTHedisSubDomain] FOREIGN KEY ([ECTHedisSubDomainID]) REFERENCES [dbo].[CodeSetECTHedisSubDomain] ([ECTHedisSubDomainID]),
    CONSTRAINT [FK_CodeSetHEDIS_ECTCode_CodeSetECTHedisTable] FOREIGN KEY ([ECTHedisTableID]) REFERENCES [dbo].[CodeSetECTHedisTable] ([ECTHedisTableID]),
    CONSTRAINT [FK_CodeSetHEDIS_ECTCode_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE NONCLUSTERED INDEX [IX_CodeSetHEDIS_ECTCode_ECTCode]
    ON [dbo].[CodeSetHEDIS_ECTCode]([ECTCode] ASC)
    INCLUDE([ECTCodeDescription], [ECTHedisTableID], [ECTHedisCodeTypeID]) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CodeSetHEDIS_ECTCode_Include]
    ON [dbo].[CodeSetHEDIS_ECTCode]([ECTHedisTableID] ASC)
    INCLUDE([ECTCode], [ECTCodeDescription], [ECTHedisCodeTypeID]) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CodeSetHEDIS_ECTCode_ECTHedisCodeTypeID_ECTHedisTableID]
    ON [dbo].[CodeSetHEDIS_ECTCode]([ECTHedisCodeTypeID] ASC, [ECTHedisTableID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CodeSetHEDIS_ECTCode_ECTHedisTableID]
    ON [dbo].[CodeSetHEDIS_ECTCode]([ECTHedisTableID] ASC)
    INCLUDE([ECTHedisCodeTypeID]) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
CREATE STATISTICS [stat_CodeSetHEDIS_ECTCode_ECTHedisTableID_ECTHedisCodeTypeID]
    ON [dbo].[CodeSetHEDIS_ECTCode]([ECTHedisTableID], [ECTHedisCodeTypeID]);

