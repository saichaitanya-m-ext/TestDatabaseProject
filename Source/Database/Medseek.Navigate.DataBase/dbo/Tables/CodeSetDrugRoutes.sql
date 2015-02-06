CREATE TABLE [dbo].[CodeSetDrugRoutes] (
    [RouteCodeID] INT          IDENTITY (1, 1) NOT NULL,
    [RouteCode]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_CodeSetDrugRoutes] PRIMARY KEY CLUSTERED ([RouteCodeID] ASC) ON [FG_Codesets]
);

