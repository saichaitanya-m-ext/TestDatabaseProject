CREATE TABLE [dbo].[CodeSetUnitCode] (
    [UnitCodeID]           INT                     IDENTITY (1, 1) NOT NULL,
    [UnitCode]             VARCHAR (20)            NOT NULL,
    [UnitCodeDescription]  [dbo].[LongDescription] NOT NULL,
    [BeginDate]            DATE                    NOT NULL,
    [EndDate]              DATE                    CONSTRAINT [DF_CodeSetUnitCode_EndDate] DEFAULT ('01-01-2100') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]           NOT NULL,
    [CreatedDate]          [dbo].[UserDate]        CONSTRAINT [DF_CodeSetUnitCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]           NULL,
    [LastModifiedDate]     [dbo].[UserDate]        NULL,
    CONSTRAINT [PK_CodeSetUnitCode] PRIMARY KEY CLUSTERED ([UnitCodeID] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetUnitCode_UnitCode]
    ON [dbo].[CodeSetUnitCode]([UnitCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The code for the Unit Code.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetUnitCode', @level2type = N'COLUMN', @level2name = N'UnitCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Alter the column to permit NULL values.  And also, alter the size of the column to 500 (down from 1000).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetUnitCode', @level2type = N'COLUMN', @level2name = N'UnitCodeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The description of the Unit Code.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetUnitCode', @level2type = N'COLUMN', @level2name = N'UnitCodeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'First Date on which the Claim Filing Indicator code is valid for use.And also, alter the column to not permit NULL values.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetUnitCode', @level2type = N'COLUMN', @level2name = N'BeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The First Date in which the Unit Code is available for use.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetUnitCode', @level2type = N'COLUMN', @level2name = N'BeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Last Date on which the Claim Filing Indicator code is valid for use.And also, alter the column to not permit NULL values.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetUnitCode', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Last Date of availability for use or Expiration Date of the Unit Code.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetUnitCode', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetUnitCode', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetUnitCode', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetUnitCode', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetUnitCode', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

