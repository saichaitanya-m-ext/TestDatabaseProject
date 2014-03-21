CREATE TABLE [dbo].[RxClaimCost] (
    [RxClaimId]                [dbo].[KeyID]      NOT NULL,
    [IngredientCost]           MONEY              NULL,
    [PaidAmount]               MONEY              NULL,
    [ApprovedCopay]            MONEY              NULL,
    [StandardCost]             MONEY              NULL,
    [DispensingFee]            MONEY              NULL,
    [PatientPaidAmount]        MONEY              NULL,
    [IncentiveAmount]          MONEY              NULL,
    [FlatSalesTaxAmount]       MONEY              NULL,
    [PercentageSalesTaxAmount] MONEY              NULL,
    [PercentageSalesTaxRate]   NUMERIC (15, 2)    NULL,
    [UsualAndCustomaryCharge]  MONEY              NULL,
    [GrossAmountDue]           MONEY              NULL,
    [StatusCode]               [dbo].[StatusCode] CONSTRAINT [DF_RxClaimCost_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]          [dbo].[KeyID]      NULL,
    [CreatedDate]              [dbo].[UserDate]   CONSTRAINT [DF_RxClaimCost_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]     [dbo].[KeyID]      NULL,
    [LastModifiedDate]         [dbo].[UserDate]   NULL,
    CONSTRAINT [PK__RxClaimC__C50153426276CEFF] PRIMARY KEY CLUSTERED ([RxClaimId] ASC),
    CONSTRAINT [FK__RxClaimCo__RxCla__66475FE3] FOREIGN KEY ([RxClaimId]) REFERENCES [dbo].[RxClaim] ([RxClaimId])
);

