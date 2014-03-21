CREATE TABLE [dbo].[IPA] (
    [IPACode]     VARCHAR (3)   NOT NULL,
    [Description] VARCHAR (200) NULL,
    CONSTRAINT [PK_IPA] PRIMARY KEY CLUSTERED ([IPACode] ASC) ON [FG_Library]
);

