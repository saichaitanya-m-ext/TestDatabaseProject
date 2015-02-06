CREATE TABLE [dbo].[CodeSetRxPayerAmountPaidQualifier] (
    [PayerAmountPaidQualifierID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PayerAmountPaidQualifierCode] VARCHAR (5)             NOT NULL,
    [PayerAmountPaidQualifierName] VARCHAR (30)            NOT NULL,
    [CodeDescription]              [dbo].[LongDescription] NULL,
    [DataSourceID]                 [dbo].[KeyID]           NULL,
    [DataSourceFileID]             [dbo].[KeyID]           NULL,
    [StatusCode]                   [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetRxPayerAmountPaidQualifier_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]              INT                     NOT NULL,
    [CreatedDate]                  DATETIME                CONSTRAINT [DF_CodeSetRxPayerAmountPaidQualifier_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]         INT                     NULL,
    [LastModifiedDate]             DATETIME                NULL,
    CONSTRAINT [PK_CodeSetRxPayerAmountPaidQualifier] PRIMARY KEY CLUSTERED ([PayerAmountPaidQualifierID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetRxPayerAmountPaidQualifier_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetRxPayerAmountPaidQualifier_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxPayerAmountPaidQualifier_QualifierCode]
    ON [dbo].[CodeSetRxPayerAmountPaidQualifier]([PayerAmountPaidQualifierCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxPayerAmountPaidQualifier_QualifierName]
    ON [dbo].[CodeSetRxPayerAmountPaidQualifier]([PayerAmountPaidQualifierName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

