CREATE TABLE [dbo].[ClaimInfo] (
    [ClaimInfoId]             [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [ClaimNumber]             [dbo].[SourceName]  NOT NULL,
    [PatientID]               [dbo].[KeyID]       NOT NULL,
    [DateOfAdmit]             [dbo].[UserDate]    NULL,
    [DateOfDischarge]         [dbo].[UserDate]    NULL,
    [NoOfServices]            INT                 NULL,
    [StatusCode]              [dbo].[StatusCode]  CONSTRAINT [DF_ClaimInfo_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]         [dbo].[KeyID]       NOT NULL,
    [CreatedDate]             [dbo].[UserDate]    CONSTRAINT [DF_ClaimInfo_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ClaimStatusCodeId]       [dbo].[KeyID]       NULL,
    [ClaimSourceCodeId]       [dbo].[KeyID]       NULL,
    [ClaimTypeCodeID]         [dbo].[KeyID]       NULL,
    [TypeOfBillCodeID]        [dbo].[KeyID]       NULL,
    [PatientStatusCodeID]     INT                 NULL,
    [PaidDate]                [dbo].[UserDate]    NULL,
    [NetPaidAmount]           MONEY               NULL,
    [AdjustedAmount]          MONEY               NULL,
    [ChargeAmount]            MONEY               NULL,
    [DisallowedAmount]        MONEY               NULL,
    [IneligibileAmount]       MONEY               NULL,
    [CoPaymentAmount]         MONEY               NULL,
    [OverUsualAndCustomary]   MONEY               NULL,
    [ProviderDiscountAmount]  MONEY               NULL,
    [DeductibleAmount]        MONEY               NULL,
    [PenaltyAmount]           MONEY               NULL,
    [NotCoverdAmount]         MONEY               NULL,
    [CoInsuranceAmount]       MONEY               NULL,
    [OutOfPocketAmount]       MONEY               NULL,
    [TotalClaimPaid]          MONEY               NULL,
    [PaidToProvider]          MONEY               NULL,
    [PaidToEmployee]          MONEY               NULL,
    [ClaimFilingIndicatorID]  [dbo].[KeyID]       NULL,
    [EDIClaimTypeID]          [dbo].[KeyID]       NOT NULL,
    [StatementDateFrom]       [dbo].[UserDate]    NULL,
    [StatementDateTo]         [dbo].[UserDate]    NULL,
    [MSDRGCodeID]             [dbo].[KeyID]       NULL,
    [MDCCodeID]               INT                 NULL,
    [DRGCodeID]               [dbo].[KeyID]       NULL,
    [APRDRGCodeID]            [dbo].[KeyID]       NULL,
    [APCCodeID]               [dbo].[KeyID]       NULL,
    [LengthOfStay]            SMALLINT            NULL,
    [PaidDays]                [dbo].[UserDate]    NULL,
    [DataSourceID]            [dbo].[KeyID]       NULL,
    [DataSourceFileID]        [dbo].[KeyID]       NULL,
    [AdmissionSourceCodeID]   [dbo].[KeyID]       NULL,
    [AdmissionTypeCodeID]     [dbo].[KeyID]       NULL,
    [LastModifiedByUserID]    [dbo].[KeyID]       NULL,
    [LastModifiedDate]        [dbo].[UserDate]    NULL,
    [IsOtherUtilizationGroup] BIT                 NULL,
    [Isnew]                   [dbo].[IsIndicator] NULL,
    CONSTRAINT [PK_ClaimInfo] PRIMARY KEY CLUSTERED ([ClaimInfoId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_ClaimInfo_CodeSetAdmissionSource] FOREIGN KEY ([AdmissionSourceCodeID]) REFERENCES [dbo].[CodeSetAdmissionSource] ([AdmissionSourceCodeID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetAdmissionType] FOREIGN KEY ([AdmissionTypeCodeID]) REFERENCES [dbo].[CodeSetAdmissionType] ([AdmissionTypeCodeID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetAPC] FOREIGN KEY ([APCCodeID]) REFERENCES [dbo].[CodeSetAPC] ([APCCodeID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetAPRDRG] FOREIGN KEY ([APRDRGCodeID]) REFERENCES [dbo].[CodeSetAPRDRG] ([APRDRGCodeID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetClaimFilingIndicator] FOREIGN KEY ([ClaimFilingIndicatorID]) REFERENCES [dbo].[CodeSetClaimFilingIndicator] ([ClaimFilingIndicatorID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetClaimSource] FOREIGN KEY ([ClaimSourceCodeId]) REFERENCES [dbo].[CodeSetClaimSource] ([ClaimSourceCodeID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetClaimStatus] FOREIGN KEY ([ClaimStatusCodeId]) REFERENCES [dbo].[CodeSetClaimStatus] ([ClaimStatusCodeID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetClaimType] FOREIGN KEY ([ClaimTypeCodeID]) REFERENCES [dbo].[CodeSetClaimType] ([ClaimTypeCodeID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ClaimInfo_CodeSetDRG] FOREIGN KEY ([DRGCodeID]) REFERENCES [dbo].[CodeSetDRG] ([DRGCodeID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetMDC] FOREIGN KEY ([MDCCodeID]) REFERENCES [dbo].[CodeSetMDC] ([MDCCodeID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetMSDRG] FOREIGN KEY ([MSDRGCodeID]) REFERENCES [dbo].[CodeSetMSDRG] ([MSDRGCodeID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetPatientStatus] FOREIGN KEY ([PatientStatusCodeID]) REFERENCES [dbo].[CodeSetPatientStatus] ([PatientStatusCodeID]),
    CONSTRAINT [FK_ClaimInfo_CodeSetTypeOfBill] FOREIGN KEY ([TypeOfBillCodeID]) REFERENCES [dbo].[CodeSetTypeOfBill] ([TypeOfBillCodeID]),
    CONSTRAINT [FK_ClaimInfo_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_ClaimInfo_LkUpEDIClaimType] FOREIGN KEY ([EDIClaimTypeID]) REFERENCES [dbo].[LkUpEDIClaimType] ([EDIClaimTypeID]),
    CONSTRAINT [FK_ClaimInfo_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientID]
    ON [dbo].[ClaimInfo]([PatientID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_ClaimInfo_StatusCode]
    ON [dbo].[ClaimInfo]([StatusCode] ASC)
    INCLUDE([ClaimInfoId], [PatientID], [DateOfAdmit]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_ClaimInfo_Include]
    ON [dbo].[ClaimInfo]([StatusCode] ASC)
    INCLUDE([ClaimInfoId], [PatientID], [DateOfAdmit], [TypeOfBillCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_ClaimInfo_PatientID_IsOtherUtilizationGroup_ClaimInfoID]
    ON [dbo].[ClaimInfo]([PatientID] ASC, [IsOtherUtilizationGroup] ASC, [ClaimInfoId] ASC)
    INCLUDE([DateOfAdmit]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_ClaimInfo_claimnumber]
    ON [dbo].[ClaimInfo]([ClaimNumber] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE STATISTICS [stat_ClaimInfo_IsOtherUtilizationGroup]
    ON [dbo].[ClaimInfo]([ClaimInfoId], [IsOtherUtilizationGroup]);


GO
CREATE STATISTICS [stat_ClaimInfo_PatientID_ClaimInfoID]
    ON [dbo].[ClaimInfo]([PatientID], [ClaimInfoId]);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimInfo', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimInfo', @level2type = N'COLUMN', @level2name = N'CreatedDate';

