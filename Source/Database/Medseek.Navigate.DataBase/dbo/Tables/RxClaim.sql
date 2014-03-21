CREATE TABLE [dbo].[RxClaim] (
    [RxClaimId]                   [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [DateFilled]                  DATE               NOT NULL,
    [DaysSupply]                  SMALLINT           NULL,
    [QuantityDispensed]           DECIMAL (10, 2)    NULL,
    [DrugCodeId]                  [dbo].[KeyID]      NULL,
    [StatusCode]                  [dbo].[StatusCode] CONSTRAINT [DF_RxClaim_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]             [dbo].[KeyID]      NULL,
    [CreatedDate]                 [dbo].[UserDate]   CONSTRAINT [DF_RxClaim_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]        [dbo].[KeyID]      NULL,
    [LastModifiedDate]            [dbo].[UserDate]   NULL,
    [RxClaimNumber]               VARCHAR (80)       NULL,
    [PatientID]                   [dbo].[KeyID]      NULL,
    [PrescriberID]                [dbo].[KeyID]      NULL,
    [PrescribedDate]              [dbo].[UserDate]   NULL,
    [NumberAuthorizedRefills]     TINYINT            NULL,
    [RxPercentageSalesTaxBasisID] [dbo].[KeyID]      NULL,
    [RxClaimSourceID]             [dbo].[KeyID]      NULL,
    [DataSourceID]                [dbo].[KeyID]      NULL,
    [DataSourceFileID]            [dbo].[KeyID]      NULL,
    [IsGeneric]                   BIT                NULL,
    [NABP]                        VARCHAR (10)       NULL,
    [PharmacyId]                  [dbo].[KeyID]      NULL,
    [PharmacyPhone]               VARCHAR (15)       NULL,
    CONSTRAINT [PK_RxClaim] PRIMARY KEY CLUSTERED ([RxClaimId] ASC),
    CONSTRAINT [FK_RxClaim_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_RxClaim_CodeSetRxClaimSource] FOREIGN KEY ([RxClaimSourceID]) REFERENCES [dbo].[CodeSetRxClaimSource] ([RxClaimSourceID]),
    CONSTRAINT [FK_RxClaim_CodeSetRxPercentageSalesTaxBasis] FOREIGN KEY ([RxPercentageSalesTaxBasisID]) REFERENCES [dbo].[CodeSetRxPercentageSalesTaxBasis] ([RxPercentageSalesTaxBasisID]),
    CONSTRAINT [FK_RxClaim_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_RxClaim_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_RxClaim_Pharmacy] FOREIGN KEY ([PharmacyId]) REFERENCES [dbo].[Pharmacy] ([PharmacyId])
);


GO
CREATE NONCLUSTERED INDEX [IX_RxClaim_PatientID]
    ON [dbo].[RxClaim]([PatientID] ASC, [StatusCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Medication Claims - the intention is to import this list from the customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the RxClaim table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'RxClaimId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the drug RX was filled', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'DateFilled';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Number of days the medication should last', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'DaysSupply';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Number provided', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'QuantityDispensed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CodeSetDrug Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'DrugCodeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RxClaim', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

