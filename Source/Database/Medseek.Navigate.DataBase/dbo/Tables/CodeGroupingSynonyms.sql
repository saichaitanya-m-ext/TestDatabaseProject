CREATE TABLE [dbo].[CodeGroupingSynonyms] (
    [CodeGroupingSynonymsID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [CodeGroupingID]         [dbo].[KeyID]    NULL,
    [CodeGroupingSynonym]    VARCHAR (200)    NULL,
    [CreatedByUserId]        [dbo].[KeyID]    NULL,
    [CreatedDate]            [dbo].[UserDate] CONSTRAINT [DF_CodeGroupingSynonyms_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]    NULL,
    [LastModifiedDate]       [dbo].[UserDate] NULL,
    CONSTRAINT [CodeGroupingSynonyms_PK] PRIMARY KEY CLUSTERED ([CodeGroupingSynonymsID] ASC),
    CONSTRAINT [FK_CodeGroupingSynonyms_CodeGroupingName] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID])
);

