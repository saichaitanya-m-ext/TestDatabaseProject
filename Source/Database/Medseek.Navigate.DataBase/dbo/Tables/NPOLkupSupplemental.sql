CREATE TABLE [dbo].[NPOLkupSupplemental] (
    [NPOLkupSupplementalID] [dbo].[KeyID] IDENTITY (1, 1) NOT NULL,
    [CodeTypeID]            [dbo].[KeyID] NOT NULL,
    [CodeValue]             VARCHAR (15)  NOT NULL,
    [CodeModifier]          VARCHAR (5)   NULL,
    [MeasureID]             [dbo].[KeyID] NOT NULL,
    [HedisYear]             [dbo].[KeyID] NOT NULL,
    [ServiceCode]           VARCHAR (3)   NULL,
    [YRSHishory]            INT           NULL,
    CONSTRAINT [PK_NPOLkupSupplemental] PRIMARY KEY CLUSTERED ([NPOLkupSupplementalID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_NPOLkupSupplemental_CodeType] FOREIGN KEY ([CodeTypeID]) REFERENCES [dbo].[NPOLkUp] ([LkUpCodeID]),
    CONSTRAINT [FK_NPOLkupSupplemental_Measure] FOREIGN KEY ([MeasureID]) REFERENCES [dbo].[NPOLkUp] ([LkUpCodeID])
);

