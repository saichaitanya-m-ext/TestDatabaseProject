CREATE TABLE [dbo].[CodeSetProcedureModifier] (
    [ProcedureCodeModifierId]   [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [ProcedureCodeModifierCode] VARCHAR (10)     NOT NULL,
    [Name]                      VARCHAR (500)    NOT NULL,
    [Description]               VARCHAR (4000)   NULL,
    [CreatedByUserId]           [dbo].[KeyID]    NOT NULL,
    [CreatedDate]               [dbo].[UserDate] CONSTRAINT [DF_ProcedureCodeModifier_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]      [dbo].[KeyID]    NULL,
    [LastModifiedDate]          [dbo].[UserDate] NULL,
    [BeginDate]                 DATE             NULL,
    [EndDate]                   DATE             CONSTRAINT [DF_ProcedureCodeModifier_EndDate] DEFAULT ('01-01-2100') NULL,
    [StatusCode]                VARCHAR (1)      CONSTRAINT [DF_CodeSetProcedureModifier_StatusCode] DEFAULT ('A') NULL,
    CONSTRAINT [PK_CodeSetProcedureModifier] PRIMARY KEY CLUSTERED ([ProcedureCodeModifierId] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetProcedureModifier.ProcedureCodeModifierCode]
    ON [dbo].[CodeSetProcedureModifier]([ProcedureCodeModifierCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Modifiers to Procedure codes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not Used in Application', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'ProcedureCodeModifierId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not Used in Application', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'ProcedureCodeModifierCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CodeSetProcedureModifier Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for CodeSetProcedureModifier table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'First Date on which the Procedure Modifier code is valid for use., alter the column to not permit NULL values.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'BeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'First Date on which the Drug code is valid for use.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'BeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Last Date on which the Procedure Modifier code is valid for use., alter the column to not permit NULL values.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Last Date on which the Drug code is valid for use.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedureModifier', @level2type = N'COLUMN', @level2name = N'EndDate';

