CREATE TABLE [dbo].[CodeSetDrugDosage] (
    [DosageId]   INT          IDENTITY (1, 1) NOT NULL,
    [DosageName] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_CodeSetDrugDosage] PRIMARY KEY CLUSTERED ([DosageId] ASC) ON [FG_Codesets]
);

