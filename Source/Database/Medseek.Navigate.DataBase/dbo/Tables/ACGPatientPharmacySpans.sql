CREATE TABLE [dbo].[ACGPatientPharmacySpans] (
    [ACGPharmacySpansID]           [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ACGResultsID]                 [dbo].[KeyID]            NOT NULL,
    [ACGConditionsID]              [dbo].[KeyID]            NOT NULL,
    [RxDrugClass]                  [dbo].[ShortDescription] NULL,
    [RxDrugIngredient]             [dbo].[ShortDescription] NULL,
    [RxFillDate]                   [dbo].[UserDate]         NULL,
    [RxRefillDate]                 [dbo].[UserDate]         NULL,
    [RxDaysSupply]                 INT                      NULL,
    [RxIPDays]                     INT                      NULL,
    [DaysCarriedOver]              INT                      NULL,
    [RxSupplyBeginDate]            [dbo].[UserDate]         NULL,
    [RxSupplyEndDate]              [dbo].[UserDate]         NULL,
    [RxSupplyAvailableUponRequest] INT                      NULL,
    [RxGracePeriod]                INT                      NULL,
    [RxDaysExceedingGracePeriod]   INT                      NULL,
    [RxEligibleForAdherence]       CHAR (1)                 NULL,
    [CreatedDate]                  [dbo].[UserDate]         CONSTRAINT [DF_PatientPharmacySpans_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedByUserID]              [dbo].[KeyID]            NOT NULL,
    [LastModifiedDate]             [dbo].[UserDate]         NULL,
    [LastModifiedByUserID]         [dbo].[KeyID]            NULL,
    CONSTRAINT [PK_PatientPharmancySpans] PRIMARY KEY CLUSTERED ([ACGPharmacySpansID] ASC, [ACGResultsID] ASC, [ACGConditionsID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientPharmacySpans_ACGConditions] FOREIGN KEY ([ACGConditionsID]) REFERENCES [dbo].[ACGConditions] ([ACGConditionsID]),
    CONSTRAINT [FK_PatientPharmacySpans_PatientACGResults] FOREIGN KEY ([ACGResultsID]) REFERENCES [dbo].[ACGPatientResults] ([ACGResultsID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientPharmacySpans', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientPharmacySpans', @level2type = N'COLUMN', @level2name = N'CreatedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientPharmacySpans', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientPharmacySpans', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserID';

