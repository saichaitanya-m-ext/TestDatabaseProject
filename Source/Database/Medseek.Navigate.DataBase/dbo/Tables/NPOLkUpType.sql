CREATE TABLE [dbo].[NPOLkUpType] (
    [NPOLkUpTypeID] [dbo].[KeyID] IDENTITY (1, 1) NOT NULL,
    [LkUpTypeName]  VARCHAR (20)  NULL,
    CONSTRAINT [PK_NPOLkUpType] PRIMARY KEY CLUSTERED ([NPOLkUpTypeID] ASC) ON [FG_Codesets]
);

