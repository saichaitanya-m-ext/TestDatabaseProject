CREATE TABLE [dbo].[CodeSetDrugFormulation] (
    [FormulationID]  INT           IDENTITY (1, 1) NOT NULL,
    [Strength]       VARCHAR (10)  NULL,
    [Unit]           VARCHAR (15)  NULL,
    [IngredientName] VARCHAR (500) NULL,
    CONSTRAINT [PK_CodeSetDrugFormulation] PRIMARY KEY CLUSTERED ([FormulationID] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CodesetDrugFormulation_Strength_Unit_IngredientName]
    ON [dbo].[CodeSetDrugFormulation]([FormulationID] ASC)
    INCLUDE([Strength], [Unit], [IngredientName]) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FDA Drug Schema Table -', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugFormulation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the Formulations table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugFormulation', @level2type = N'COLUMN', @level2name = N'FormulationID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This is the potency of the active ingredient.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugFormulation', @level2type = N'COLUMN', @level2name = N'Strength';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unit of measure corresponding to strength.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugFormulation', @level2type = N'COLUMN', @level2name = N'Unit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Truncated preferred term for the active ingredient.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugFormulation', @level2type = N'COLUMN', @level2name = N'IngredientName';

