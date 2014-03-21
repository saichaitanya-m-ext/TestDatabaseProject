CREATE TABLE [dbo].[LookUpType] (
    [LookUpCode]  VARCHAR (2)              NOT NULL,
    [Description] [dbo].[ShortDescription] NOT NULL,
    CONSTRAINT [PK_LookUpType] PRIMARY KEY CLUSTERED ([LookUpCode] ASC) ON [FG_Library]
);

