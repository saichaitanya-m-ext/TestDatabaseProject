CREATE TABLE [dbo].[ClaimBeneficiaryCode] (
    [ClaimBeneficiaryCodeId] INT           NOT NULL,
    [ClaimBeneficiaryCode]   VARCHAR (10)  NULL,
    [Description]            VARCHAR (100) NULL,
    [StatusCode]             VARCHAR (1)   NULL,
    [CreatedByUserId]        INT           NULL,
    [CreatedDate]            DATETIME      NULL,
    [LastModifiedByUserId]   INT           NULL,
    [LastModifiedDate]       DATETIME      NULL,
    CONSTRAINT [PK_ClaimBeneficiaryCode] PRIMARY KEY CLUSTERED ([ClaimBeneficiaryCodeId] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimBeneficiaryCode', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimBeneficiaryCode', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimBeneficiaryCode', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimBeneficiaryCode', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

