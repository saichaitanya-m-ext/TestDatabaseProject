CREATE TABLE [dbo].[CodeSetClaimCareType] (
    [ClaimCareTypeCodeID]  INT                IDENTITY (1, 1) NOT NULL,
    [ClaimCareTypeCode]    VARCHAR (10)       NOT NULL,
    [Description]          VARCHAR (100)      NULL,
    [CreatedDate]          DATETIME           CONSTRAINT [DF_CodeSetClaimCareType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                NULL,
    [LastModifiedDate]     DATETIME           NULL,
    [StatusCOde]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetClaimCareType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByuserID]      INT                NOT NULL,
    CONSTRAINT [PK_CodeSetClaimCareType] PRIMARY KEY CLUSTERED ([ClaimCareTypeCodeID] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ClaimCareType.ClaimCareTypeCode]
    ON [dbo].[CodeSetClaimCareType]([ClaimCareTypeCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimCareType', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimCareType', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimCareType', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetClaimCareType', @level2type = N'COLUMN', @level2name = N'CreatedByuserID';

