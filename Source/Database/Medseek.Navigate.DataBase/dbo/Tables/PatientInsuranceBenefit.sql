CREATE TABLE [dbo].[PatientInsuranceBenefit] (
    [PatientInsuranceBenefitID] [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [PatientInsuranceID]        [dbo].[KeyID]       NOT NULL,
    [InsuranceBenefitTypeID]    [dbo].[KeyID]       NOT NULL,
    [BenfitTypeCode]            VARCHAR (20)        NULL,
    [IsPrimary]                 [dbo].[IsIndicator] NOT NULL,
    [DateOfEligibility]         [dbo].[UserDate]    NOT NULL,
    [CoverageEndsDate]          [dbo].[UserDate]    NOT NULL,
    [CreatedByUserId]           [dbo].[KeyID]       NOT NULL,
    [CreatedDate]               [dbo].[UserDate]    CONSTRAINT [DF_PatientInsuranceBenefit_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]      [dbo].[KeyID]       NULL,
    [LastModifiedDate]          [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_PatientInsuranceBenefit] PRIMARY KEY CLUSTERED ([PatientInsuranceBenefitID] ASC),
    CONSTRAINT [FK_PatientInsuranceBenefit_LkUpInsuranceBenefitType] FOREIGN KEY ([InsuranceBenefitTypeID]) REFERENCES [dbo].[LkUpInsuranceBenefitType] ([InsuranceBenefitTypeID]),
    CONSTRAINT [FK_PatientInsuranceBenefit_PatientInsurance] FOREIGN KEY ([PatientInsuranceID]) REFERENCES [dbo].[PatientInsurance] ([PatientInsuranceID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The first date at which the Member can attain the benefit.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsuranceBenefit', @level2type = N'COLUMN', @level2name = N'DateOfEligibility';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The last date at which the Member can attain the benefit, usually represented along the time of ''11:59:59'' or ''23:59:59''.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsuranceBenefit', @level2type = N'COLUMN', @level2name = N'CoverageEndsDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsuranceBenefit', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsuranceBenefit', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsuranceBenefit', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsuranceBenefit', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

