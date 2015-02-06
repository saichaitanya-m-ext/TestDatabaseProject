CREATE TABLE [dbo].[LookUpValue] (
    [LookupValueId]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [LookUpCode]      VARCHAR (2)              NOT NULL,
    [Value]           [dbo].[ShortDescription] NOT NULL,
    [CreatedByUserId] [dbo].[KeyID]            NOT NULL,
    [CreatedDate]     [dbo].[UserDate]         CONSTRAINT [DF_LookUpValue_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_LookUpValue] PRIMARY KEY CLUSTERED ([LookupValueId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_LookUpValue_LookUpType] FOREIGN KEY ([LookUpCode]) REFERENCES [dbo].[LookUpType] ([LookUpCode])
);

