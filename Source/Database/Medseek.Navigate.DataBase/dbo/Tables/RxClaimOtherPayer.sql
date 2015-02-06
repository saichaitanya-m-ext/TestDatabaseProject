CREATE TABLE [dbo].[RxClaimOtherPayer] (
    [RxClaimOtherPayerID]        INT             IDENTITY (1, 1) NOT NULL,
    [RxClaimID]                  INT             NOT NULL,
    [PayerIDQualifier]           VARCHAR (5)     NOT NULL,
    [PayerID]                    VARCHAR (50)    NOT NULL,
    [PayerDate]                  DATETIME        NOT NULL,
    [PayerAmountPaidQualifierID] INT             NOT NULL,
    [AmountPaid]                 NUMERIC (15, 2) NOT NULL,
    [RankOrder]                  SMALLINT        NOT NULL,
    [DataSourceID]               INT             NULL,
    [DataSourceFileID]           INT             NULL,
    [RecordTagFileID]            VARCHAR (30)    NULL,
    [StatusCode]                 VARCHAR (1)     CONSTRAINT [DF_RxClaimOtherPayer_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]            INT             NOT NULL,
    [CreatedDate]                DATETIME        CONSTRAINT [DF_RxClaimOtherPayer_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]       INT             NULL,
    [LastModifiedDate]           DATETIME        NULL,
    CONSTRAINT [PK_RxClaimOtherPayer] PRIMARY KEY CLUSTERED ([RxClaimID] ASC, [PayerIDQualifier] ASC, [PayerID] ASC, [PayerDate] ASC),
    CONSTRAINT [FK_RxClaimOtherPayer_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_RxClaimOtherPayer_CodeSetRxPayerAmountPaidQualifier] FOREIGN KEY ([PayerAmountPaidQualifierID]) REFERENCES [dbo].[CodeSetRxPayerAmountPaidQualifier] ([PayerAmountPaidQualifierID]),
    CONSTRAINT [FK_RxClaimOtherPayer_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

