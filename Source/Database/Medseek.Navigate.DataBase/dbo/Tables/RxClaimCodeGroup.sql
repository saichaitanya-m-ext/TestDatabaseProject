CREATE TABLE [dbo].[RxClaimCodeGroup] (
    [RxClaimId]      [dbo].[KeyID] NOT NULL,
    [CodeGroupingId] [dbo].[KeyID] NOT NULL,
    CONSTRAINT [PK_RxClaimCodeGroup] PRIMARY KEY CLUSTERED ([RxClaimId] ASC, [CodeGroupingId] ASC),
    CONSTRAINT [FK_RxClaimCodeGroup_CodeGrouping] FOREIGN KEY ([CodeGroupingId]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_RxClaimCodeGroup_RxClaim] FOREIGN KEY ([RxClaimId]) REFERENCES [dbo].[RxClaim] ([RxClaimId])
);

