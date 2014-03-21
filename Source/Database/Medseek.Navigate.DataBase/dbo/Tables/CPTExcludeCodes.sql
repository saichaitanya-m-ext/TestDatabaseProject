CREATE TABLE [dbo].[CPTExcludeCodes] (
    [CPTCode] NVARCHAR (5) NOT NULL,
    CONSTRAINT [PK_CPTExcludeCodes] PRIMARY KEY CLUSTERED ([CPTCode] ASC) ON [FG_Library]
);

