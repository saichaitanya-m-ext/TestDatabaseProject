CREATE TABLE [dbo].[CodeSetRxAmountClaimedSubmittedQualifier] (
    [RxAmountClaimedSubmittedQualifierID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [RxAmountClaimedSubmittedQualifierCode] VARCHAR (2)             NOT NULL,
    [RxAmountClaimedSubmittedQualifierName] VARCHAR (30)            NOT NULL,
    [CodeDescription]                       [dbo].[LongDescription] NULL,
    [DataSourceID]                          [dbo].[KeyID]           NULL,
    [DataSourceFileID]                      [dbo].[KeyID]           NULL,
    [StatusCode]                            [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetRxAmountClaimedSubmittedQualifier_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]                       INT                     NOT NULL,
    [CreatedDate]                           DATETIME                CONSTRAINT [DF_CodeSetRxAmountClaimedSubmittedQualifier_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]                  INT                     NULL,
    [LastModifiedDate]                      DATETIME                NULL,
    CONSTRAINT [PK_CodeSetRxAmountClaimedSubmittedQualifier] PRIMARY KEY CLUSTERED ([RxAmountClaimedSubmittedQualifierID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetRxAmountClaimedSubmittedQualifier_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetRxAmountClaimedSubmittedQualifier_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxAmountClaimedSubmittedQualifier_QualifierCode]
    ON [dbo].[CodeSetRxAmountClaimedSubmittedQualifier]([RxAmountClaimedSubmittedQualifierCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxAmountClaimedSubmittedQualifier_QualifierName]
    ON [dbo].[CodeSetRxAmountClaimedSubmittedQualifier]([RxAmountClaimedSubmittedQualifierName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

