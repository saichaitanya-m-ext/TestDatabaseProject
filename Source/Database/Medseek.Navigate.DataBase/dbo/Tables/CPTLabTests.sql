CREATE TABLE [dbo].[CPTLabTests] (
    [ProcedureID]          [dbo].[KeyID]      NOT NULL,
    [LabTestID]            [dbo].[KeyID]      NOT NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CPTLabTests_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUseriD]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_CPTLabTests_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_CPTLabTests] PRIMARY KEY CLUSTERED ([ProcedureID] ASC, [LabTestID] ASC),
    CONSTRAINT [FK_CPTLabTests_CodeSetProcedure] FOREIGN KEY ([ProcedureID]) REFERENCES [dbo].[CodeSetProcedure] ([ProcedureCodeID]),
    CONSTRAINT [FK_CPTLabTests_LabTests] FOREIGN KEY ([LabTestID]) REFERENCES [dbo].[LabTests] ([LabTestId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CPTLabTests', @level2type = N'COLUMN', @level2name = N'CreatedByUseriD';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CPTLabTests', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CPTLabTests', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CPTLabTests', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

