CREATE TABLE [dbo].[CodeSetDrugFormulationBridge] (
    [FormulationID] INT NOT NULL,
    [DrugCodeID]    INT NOT NULL,
    CONSTRAINT [PK_CodeSetDrugFormulationBridge] PRIMARY KEY CLUSTERED ([FormulationID] ASC, [DrugCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetDrugFormulationBridge_Formulations] FOREIGN KEY ([FormulationID]) REFERENCES [dbo].[CodeSetDrugFormulation] ([FormulationID])
);

