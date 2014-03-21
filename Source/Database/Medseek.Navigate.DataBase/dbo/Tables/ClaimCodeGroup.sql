CREATE TABLE [dbo].[ClaimCodeGroup] (
    [ClaimInfoID]    [dbo].[KeyID] NOT NULL,
    [CodeGroupingID] [dbo].[KeyID] NOT NULL,
    CONSTRAINT [PK_ClaimCodeGroup] PRIMARY KEY CLUSTERED ([ClaimInfoID] ASC, [CodeGroupingID] ASC),
    CONSTRAINT [FK_ClaimCodeGroup_ClaimInfo] FOREIGN KEY ([ClaimInfoID]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_ClaimCodeGroup_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID])
);

