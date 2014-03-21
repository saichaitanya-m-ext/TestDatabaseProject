CREATE TABLE [dbo].[CodeSetDrugDosageBridge] (
    [DrugCodeID] INT NOT NULL,
    [DosageID]   INT NOT NULL,
    CONSTRAINT [PK_CodeSetDrugDosageBridge] PRIMARY KEY CLUSTERED ([DrugCodeID] ASC, [DosageID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetDrugDosageBridge_Dosage] FOREIGN KEY ([DosageID]) REFERENCES [dbo].[CodeSetDrugDosage] ([DosageId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FDA Drug Schema Table -', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugDosageBridge';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FDA unique ID for Drugs Foreign key to the listing table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugDosageBridge', @level2type = N'COLUMN', @level2name = N'DrugCodeID';

