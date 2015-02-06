CREATE TABLE [dbo].[RxClaimOtherClaimedAmount] (
    [RxClaimOtherClaimedAmountID]         INT             IDENTITY (1, 1) NOT NULL,
    [RxClaimID]                           INT             NOT NULL,
    [RxAmountClaimedSubmittedQualifierID] INT             NOT NULL,
    [ClaimedAmount]                       NUMERIC (15, 2) NOT NULL,
    [DataSourceID]                        INT             NULL,
    [DataSourceFileID]                    INT             NULL,
    [RecordTagFileID]                     VARCHAR (30)    NULL,
    [StatusCode]                          VARCHAR (1)     CONSTRAINT [DF_RxClaimOtherClaimedAmount_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]                     INT             NOT NULL,
    [CreatedDate]                         DATETIME        CONSTRAINT [DF_RxClaimOtherClaimedAmount_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]                INT             NULL,
    [LastModifiedDate]                    DATETIME        NULL,
    CONSTRAINT [PK_RxClaimOtherClaimedAmount] PRIMARY KEY CLUSTERED ([RxClaimID] ASC, [RxAmountClaimedSubmittedQualifierID] ASC, [ClaimedAmount] ASC),
    CONSTRAINT [FK_RxClaimOtherClaimedAmount_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_RxClaimOtherClaimedAmount_CodeSetRxAmountClaimedSubmittedQualifier] FOREIGN KEY ([RxAmountClaimedSubmittedQualifierID]) REFERENCES [dbo].[CodeSetRxAmountClaimedSubmittedQualifier] ([RxAmountClaimedSubmittedQualifierID]),
    CONSTRAINT [FK_RxClaimOtherClaimedAmount_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

