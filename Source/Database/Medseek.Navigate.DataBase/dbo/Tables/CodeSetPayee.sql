CREATE TABLE [dbo].[CodeSetPayee] (
    [PayeeCodeID]     [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PayeeCode]       VARCHAR (3)              NOT NULL,
    [Description]     [dbo].[ShortDescription] NOT NULL,
    [StatusCode]      [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetPayee_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId] [dbo].[KeyID]            NOT NULL,
    [CreatedDate]     [dbo].[UserDate]         CONSTRAINT [DF_CodeSetPayee_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CodeSetPayee] PRIMARY KEY CLUSTERED ([PayeeCodeID] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PayeeCode_PayeeCode]
    ON [dbo].[CodeSetPayee]([PayeeCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetPayee', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetPayee', @level2type = N'COLUMN', @level2name = N'CreatedDate';

