CREATE TABLE [dbo].[CodeSetClaimSource] (
    [ClaimSourceCodeID]    INT           IDENTITY (1, 1) NOT NULL,
    [ClaimSourceCode]      VARCHAR (5)   NOT NULL,
    [Description]          VARCHAR (100) NULL,
    [StatusCode]           VARCHAR (1)   CONSTRAINT [DF_CodeSetClaimSource_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT           NOT NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_CodeSetClaimSource_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT           NULL,
    [LastModifiedDate]     DATETIME      NULL,
    CONSTRAINT [PK_CodeSetClaimSource] PRIMARY KEY CLUSTERED ([ClaimSourceCodeID] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ClaimSourceCode.ClaimSourceCode]
    ON [dbo].[CodeSetClaimSource]([ClaimSourceCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimSource', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimSource', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimSource', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimSource', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

