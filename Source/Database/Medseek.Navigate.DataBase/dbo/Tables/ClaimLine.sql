CREATE TABLE [dbo].[ClaimLine] (
    [ClaimLineID]                   [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [ClaimInfoID]                   INT                 NOT NULL,
    [BilledAmount]                  MONEY               NULL,
    [EligibleAmount]                MONEY               NULL,
    [PaymentAmount]                 MONEY               NULL,
    [PayeeCodeID]                   [dbo].[KeyID]       NULL,
    [PlaceOfServiceCodeID]          INT                 NULL,
    [BeginServiceDate]              DATETIME            NULL,
    [EndServiceDate]                DATETIME            NULL,
    [ServiceTypeCodeID]             [dbo].[KeyID]       NULL,
    [DatePaid]                      DATETIME            NULL,
    [CustomProviderSpecialtyCodeID] [dbo].[KeyID]       NULL,
    [DeductibleAmount]              MONEY               NULL,
    [CopayAmount]                   MONEY               NULL,
    [CoinsuranceAmount]             MONEY               NULL,
    [OtherInsuranceCOBAmount]       MONEY               NULL,
    [SubrogationAmount]             MONEY               NULL,
    [AdjustmentCodeId]              INT                 NULL,
    [ReversalCodeID]                INT                 NULL,
    [CreatedByUserId]               [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                   [dbo].[UserDate]    CONSTRAINT [DF_ClaimLine_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [DisabilityTypeCodeID]          [dbo].[KeyID]       NULL,
    [FileId]                        [dbo].[KeyID]       NULL,
    [ClaimCareTypeCodeID]           [dbo].[KeyID]       NULL,
    [ServiceLineNumber]             SMALLINT            NULL,
    [TopLine]                       CHAR (1)            NULL,
    [DisallowedAmount]              MONEY               NULL,
    [InEligibleAmount]              MONEY               NULL,
    [DiscountAmount]                MONEY               NULL,
    [OriginalDiscount]              MONEY               NULL,
    [PenalityAmount]                MONEY               NULL,
    [OverUsualAndCustomary]         MONEY               NULL,
    [NetPaymentAmount]              MONEY               NULL,
    [PaidToProvider]                MONEY               NULL,
    [PaidToEmployee]                MONEY               NULL,
    [WithHoldAmount]                MONEY               NULL,
    [COBType]                       CHAR (1)            NULL,
    [COBEmployeeAmount]             MONEY               NULL,
    [COBProviderAmount]             MONEY               NULL,
    [UnitsOfService]                INT                 NULL,
    [LastModifiedByUserID]          [dbo].[KeyID]       NULL,
    [LastModifiedDate]              DATETIME            NULL,
    [StatusCode]                    VARCHAR (1)         CONSTRAINT [DF_ClaimLine_StatusCode] DEFAULT ('A') NOT NULL,
    [ICDPointer]                    INT                 NULL,
    [Quantity]                      NUMERIC (10, 5)     NULL,
    [UnitCodeID]                    [dbo].[KeyID]       NULL,
    [ProcedureCodeID]               [dbo].[KeyID]       NULL,
    [RevenueCodeID]                 [dbo].[KeyID]       NULL,
    [ApprovedQuantity]              NUMERIC (10, 2)     NULL,
    [DataSourceID]                  [dbo].[KeyID]       NULL,
    [DataSourceFileID]              [dbo].[KeyID]       NULL,
    [RecordTag_FileID]              VARCHAR (30)        NULL,
    [Isnew]                         [dbo].[IsIndicator] NULL,
    CONSTRAINT [PK_ClaimLine] PRIMARY KEY NONCLUSTERED ([ClaimLineID] ASC) WITH (FILLFACTOR = 100) ON [FG_Transactional_NCX],
    CONSTRAINT [FK_ClaimLine_ClaimInfo] FOREIGN KEY ([ClaimInfoID]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_ClaimLine_CodeSetAdjustment] FOREIGN KEY ([AdjustmentCodeId]) REFERENCES [dbo].[CodeSetAdjustment] ([AdjustmentCodeID]),
    CONSTRAINT [FK_ClaimLine_CodeSetClaimCareType] FOREIGN KEY ([ClaimCareTypeCodeID]) REFERENCES [dbo].[CodeSetClaimCareType] ([ClaimCareTypeCodeID]),
    CONSTRAINT [FK_Claimline_CodeSetCMSPlaceOfService] FOREIGN KEY ([PlaceOfServiceCodeID]) REFERENCES [dbo].[CodeSetCMSPlaceOfService] ([PlaceOfServiceCodeID]),
    CONSTRAINT [FK_ClaimLine_CodeSetCustomProviderSpecialty] FOREIGN KEY ([CustomProviderSpecialtyCodeID]) REFERENCES [dbo].[CodeSetCustomProviderSpecialty] ([CustomProviderSpecialtyCodeID]),
    CONSTRAINT [FK_Claimline_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ClaimLine_CodeSetDisabilityType] FOREIGN KEY ([DisabilityTypeCodeID]) REFERENCES [dbo].[CodeSetDisabilityType] ([DisabilityTypeCodeID]),
    CONSTRAINT [FK_ClaimLine_CodeSetPayee] FOREIGN KEY ([PayeeCodeID]) REFERENCES [dbo].[CodeSetPayee] ([PayeeCodeID]),
    CONSTRAINT [FK_Claimline_CodeSetProcedure] FOREIGN KEY ([ProcedureCodeID]) REFERENCES [dbo].[CodeSetProcedure] ([ProcedureCodeID]),
    CONSTRAINT [FK_ClaimLine_CodeSetRevenue] FOREIGN KEY ([RevenueCodeID]) REFERENCES [dbo].[CodeSetRevenue] ([RevenueCodeID]),
    CONSTRAINT [FK_ClaimLine_CodeSetReversalCode] FOREIGN KEY ([ReversalCodeID]) REFERENCES [dbo].[CodeSetReversalCode] ([ReversalCodeID]),
    CONSTRAINT [FK_ClaimLine_CodeSetServiceType] FOREIGN KEY ([ServiceTypeCodeID]) REFERENCES [dbo].[CodeSetServiceType] ([ServiceTypeCodeID]),
    CONSTRAINT [FK_Claimline_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE NONCLUSTERED INDEX [IX_ClaimLine_ClaimInfoid]
    ON [dbo].[ClaimLine]([ClaimInfoID] ASC)
    INCLUDE([ClaimLineID], [PlaceOfServiceCodeID], [BeginServiceDate], [EndServiceDate], [ServiceTypeCodeID], [CreatedByUserId], [CreatedDate], [LastModifiedByUserID], [LastModifiedDate], [ProcedureCodeID], [RevenueCodeID], [DataSourceID], [DataSourceFileID], [RecordTag_FileID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_ClaimLine_StatusCode]
    ON [dbo].[ClaimLine]([StatusCode] ASC)
    INCLUDE([ClaimInfoID], [RevenueCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_ClaimLine_StatusCodeProcedureCodeID]
    ON [dbo].[ClaimLine]([StatusCode] ASC)
    INCLUDE([ProcedureCodeID], [ClaimInfoID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_ClaimLine_StatusCodeClaimInfoID]
    ON [dbo].[ClaimLine]([StatusCode] ASC)
    INCLUDE([ClaimLineID], [ClaimInfoID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_ClaimLine_StatusCodePlaceOfServiceCodeID]
    ON [dbo].[ClaimLine]([StatusCode] ASC)
    INCLUDE([ClaimInfoID], [PlaceOfServiceCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLine', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLine', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLine', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLine', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

