CREATE TABLE [dbo].[CodeSetDrugRoutesBridge] (
    [DrugCodeID]  INT NOT NULL,
    [RouteCodeID] INT NOT NULL,
    CONSTRAINT [PK_CodeSetDrugRoutesBridge] PRIMARY KEY CLUSTERED ([DrugCodeID] ASC, [RouteCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetDrugRoutesBridge_RouteCodes] FOREIGN KEY ([RouteCodeID]) REFERENCES [dbo].[CodeSetDrugRoutes] ([RouteCodeID])
);

