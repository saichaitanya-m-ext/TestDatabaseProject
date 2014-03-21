CREATE TABLE [dbo].[ClaimLineModifier] (
    [ClaimLineModifierID]     INT              IDENTITY (1, 1) NOT NULL,
    [ClaimLineID]             [dbo].[KeyID]    NOT NULL,
    [ProcedureCodeModifierID] [dbo].[KeyID]    NOT NULL,
    [CreatedByUserId]         [dbo].[KeyID]    NOT NULL,
    [CreatedDate]             [dbo].[UserDate] CONSTRAINT [DF_ClaimLineModifier_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [RankOrder]               TINYINT          NULL,
    CONSTRAINT [PK_ClaimLineModifier] PRIMARY KEY CLUSTERED ([ClaimLineModifierID] ASC),
    CONSTRAINT [FK_ClaimLineModifier_ClaimLine] FOREIGN KEY ([ClaimLineID]) REFERENCES [dbo].[ClaimLine] ([ClaimLineID]),
    CONSTRAINT [FK_ClaimLineModifier_CodeSetProcedureModifier] FOREIGN KEY ([ProcedureCodeModifierID]) REFERENCES [dbo].[CodeSetProcedureModifier] ([ProcedureCodeModifierId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLineModifier', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLineModifier', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The rank order of the Diagnosis code on the Claim Line.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLineModifier', @level2type = N'COLUMN', @level2name = N'RankOrder';

