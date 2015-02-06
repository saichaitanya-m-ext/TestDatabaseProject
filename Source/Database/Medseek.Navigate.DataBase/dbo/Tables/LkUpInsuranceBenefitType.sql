CREATE TABLE [dbo].[LkUpInsuranceBenefitType] (
    [InsuranceBenefitTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [BenefitTypeName]        VARCHAR (150) NOT NULL,
    [CreatedByUserId]        INT           NOT NULL,
    [CreatedDate]            DATETIME      CONSTRAINT [DF_LkUpInsuranceBenefitType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   INT           NULL,
    [LastModifiedDate]       DATETIME      NULL,
    [StatusCode]             VARCHAR (1)   DEFAULT ('A') NOT NULL,
    [BenefitTypeCode]        VARCHAR (10)  NULL,
    [BenefitDescription]     VARCHAR (255) NULL,
    CONSTRAINT [PK_InsuranceBenfitType] PRIMARY KEY CLUSTERED ([InsuranceBenefitTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [IX_InsuranceBenfitType_BenefitTypeCode] UNIQUE NONCLUSTERED ([BenefitTypeCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Abbreviation or shortname of the Insurance Type.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpInsuranceBenefitType', @level2type = N'COLUMN', @level2name = N'InsuranceBenefitTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpInsuranceBenefitType', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpInsuranceBenefitType', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpInsuranceBenefitType', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpInsuranceBenefitType', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

