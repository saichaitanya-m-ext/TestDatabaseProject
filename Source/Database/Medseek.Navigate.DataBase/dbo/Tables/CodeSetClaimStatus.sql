CREATE TABLE [dbo].[CodeSetClaimStatus] (
    [ClaimStatusCodeID]    INT           IDENTITY (1, 1) NOT NULL,
    [ClaimStatusCode]      CHAR (1)      NOT NULL,
    [Description]          VARCHAR (100) NULL,
    [StatusCode]           VARCHAR (1)   CONSTRAINT [DF_CodeSetClaimStatus_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT           NOT NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_CodeSetClaimStatus_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT           NULL,
    [LastModifiedDate]     DATETIME      NULL,
    CONSTRAINT [PK_CodeSetClaimStatus] PRIMARY KEY CLUSTERED ([ClaimStatusCodeID] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ClaimStatusCode_ClaimStatusCode]
    ON [dbo].[CodeSetClaimStatus]([ClaimStatusCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimStatus', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimStatus', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimStatus', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimStatus', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

