CREATE TABLE [dbo].[CodeSetRxPercentageSalesTaxBasis] (
    [RxPercentageSalesTaxBasisID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [RxPercentageSalesTaxBasisCode] VARCHAR (5)             NOT NULL,
    [RxPercentageSalesTaxBasisName] VARCHAR (30)            NOT NULL,
    [CodeDescription]               [dbo].[LongDescription] NULL,
    [DataSourceID]                  [dbo].[KeyID]           NULL,
    [DataSourceFileID]              [dbo].[KeyID]           NULL,
    [StatusCode]                    [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetRxPercentageSalesTaxBasis_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]               INT                     NOT NULL,
    [CreatedDate]                   DATETIME                CONSTRAINT [DF_CodeSetRxPercentageSalesTaxBasis_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          INT                     NULL,
    [LastModifiedDate]              DATETIME                NULL,
    CONSTRAINT [PK_CodeSetRxPercentageSalesTaxBasis] PRIMARY KEY CLUSTERED ([RxPercentageSalesTaxBasisID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetRxPercentageSalesTaxBasis_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetRxPercentageSalesTaxBasis_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxPercentageSalesTaxBasis_TaxBasisCode]
    ON [dbo].[CodeSetRxPercentageSalesTaxBasis]([RxPercentageSalesTaxBasisCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxPercentageSalesTaxBasis_TaxBasisName]
    ON [dbo].[CodeSetRxPercentageSalesTaxBasis]([RxPercentageSalesTaxBasisName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

