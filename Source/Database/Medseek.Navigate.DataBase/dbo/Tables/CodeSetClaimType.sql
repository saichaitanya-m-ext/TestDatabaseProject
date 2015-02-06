CREATE TABLE [dbo].[CodeSetClaimType] (
    [ClaimTypeCodeID] [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [Description]     [dbo].[ShortDescription] NOT NULL,
    [StatusCode]      [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetClaimType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId] [dbo].[KeyID]            NOT NULL,
    [CreatedDate]     [dbo].[UserDate]         CONSTRAINT [DF_CodeSetClaimType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [Code]            VARCHAR (2)              NULL,
    CONSTRAINT [PK_CodeSetClaimType] PRIMARY KEY CLUSTERED ([ClaimTypeCodeID] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ClaimType.Description]
    ON [dbo].[CodeSetClaimType]([Description] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimType', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimType', @level2type = N'COLUMN', @level2name = N'CreatedDate';

