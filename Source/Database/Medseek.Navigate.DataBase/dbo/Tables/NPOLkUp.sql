CREATE TABLE [dbo].[NPOLkUp] (
    [LkUpCodeID]      [dbo].[KeyID]  IDENTITY (1, 1) NOT NULL,
    [LkUpCode]        VARCHAR (150)  NOT NULL,
    [Description]     VARCHAR (1000) NOT NULL,
    [NPOLkUpTypeID]   [dbo].[KeyID]  NOT NULL,
    [CreatedByUserID] [dbo].[KeyID]  NOT NULL,
    [CreatedDate]     DATETIME       CONSTRAINT [DF_NPOLkUp_CreatedDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_NPOLkUp] PRIMARY KEY CLUSTERED ([LkUpCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_NPOLkUp_NPOLkUpType] FOREIGN KEY ([NPOLkUpTypeID]) REFERENCES [dbo].[NPOLkUpType] ([NPOLkUpTypeID])
);

