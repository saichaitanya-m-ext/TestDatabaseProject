CREATE TABLE [dbo].[IOMCategory] (
    [IOMCategoryId]   INT           IDENTITY (1, 1) NOT NULL,
    [Name]            VARCHAR (100) NOT NULL,
    [Description]     VARCHAR (100) NULL,
    [StatusCode]      VARCHAR (1)   CONSTRAINT [DF_IOMCategorys_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId] INT           NOT NULL,
    [CreatedDate]     DATETIME      CONSTRAINT [DF_IOMCategorys_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_IOMCategorys] PRIMARY KEY CLUSTERED ([IOMCategoryId] ASC) ON [FG_Library]
);

