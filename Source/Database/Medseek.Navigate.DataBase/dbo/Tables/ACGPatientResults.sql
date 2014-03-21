CREATE TABLE [dbo].[ACGPatientResults] (
    [ACGResultsID]                      [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PatientID]                         INT              NOT NULL,
    [DateDetermined]                    DATETIME         NOT NULL,
    [Pregnant]                          SMALLINT         NULL,
    [Delivered]                         SMALLINT         NULL,
    [LowBirthWeight]                    SMALLINT         NULL,
    [PharmacyCost]                      MONEY            NULL,
    [TotalCost]                         MONEY            NULL,
    [InpatientHospitalizationCount]     SMALLINT         NULL,
    [EmergencyVisitCount]               SMALLINT         NULL,
    [OutpatientVisitCount]              SMALLINT         NULL,
    [DialysisService]                   SMALLINT         NULL,
    [NursingService]                    SMALLINT         NULL,
    [MajorProcedure]                    INT              NULL,
    [PharmacyCostBand]                  NVARCHAR (20)    NULL,
    [TotalCostBand]                     NVARCHAR (20)    NULL,
    [AgeBand]                           NVARCHAR (20)    NULL,
    [ACGCode]                           INT              NULL,
    [ResourceUtilizationBand]           INT              NULL,
    [ReferenceUnscaledConcurrentWeight] DECIMAL (10, 2)  NULL,
    [ReferenceRescaledConcurrentWeight] DECIMAL (10, 2)  NULL,
    [LocalConcurrentWeight]             DECIMAL (10, 2)  NULL,
    [ADGVector]                         NVARCHAR (100)   NULL,
    [MajorAGDCount]                     SMALLINT         NULL,
    [FrailtyFlag]                       VARCHAR (50)     NULL,
    [HospitalDominantCount]             SMALLINT         NULL,
    [ChronicConditionCount]             SMALLINT         NULL,
    [UnscaledTotalCostResourceIndex]    FLOAT (53)       NULL,
    [RescaledTotalCostResourceIndex]    FLOAT (53)       NULL,
    [ProbabilityHighTotalCost]          FLOAT (53)       NULL,
    [UnscaledPharmacyCostResourceIndex] FLOAT (53)       NULL,
    [RescaledPharmacyCostResourceIndex] FLOAT (53)       NULL,
    [ProbabilityHighPharmacyCost]       FLOAT (53)       NULL,
    [HighRiskUnexpectedPharmacyCost]    VARCHAR (1)      NULL,
    [ProbabilityUnexpectedPharmacyCost] FLOAT (53)       NULL,
    [MajoritySourceOfCarePercent]       FLOAT (53)       NULL,
    [MajoritySourceOfCareProviders]     NVARCHAR (100)   NULL,
    [UniqueProviderCount]               SMALLINT         NULL,
    [SpecialtyCount]                    SMALLINT         NULL,
    [NoGeneralist]                      NVARCHAR (1)     NULL,
    [GenericDrugCount]                  SMALLINT         NULL,
    [ProbabilityIPHosp]                 FLOAT (53)       NULL,
    [ProbabilityIPHosp6mos]             FLOAT (53)       NULL,
    [ProbabilityICUHosp]                FLOAT (53)       NULL,
    [probabilityInjuryHosp]             FLOAT (53)       NULL,
    [probabilityExtendedHosp]           FLOAT (53)       NULL,
    [CreatedDate]                       [dbo].[UserDate] CONSTRAINT [DF_PatientACGResults_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedByUserID]                   [dbo].[KeyID]    NOT NULL,
    [LastModifiedDate]                  [dbo].[UserDate] NULL,
    [LastModifiedByUserID]              [dbo].[KeyID]    NULL,
    [ACGScheduleID]                     [dbo].[KeyID]    NULL,
    CONSTRAINT [PK_PatientACGResults] PRIMARY KEY CLUSTERED ([ACGResultsID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_ACGPatientResults_ACGSchedule] FOREIGN KEY ([ACGScheduleID]) REFERENCES [dbo].[ACGSchedule] ([ACGScheduleID]),
    CONSTRAINT [FK_ACGPatientResults_ACGScheduleID] FOREIGN KEY ([ACGScheduleID]) REFERENCES [dbo].[ACGSchedule] ([ACGScheduleID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PatientACGResults_PatientID_DateDetermined_ACGScheduleID]
    ON [dbo].[ACGPatientResults]([PatientID] ASC, [DateDetermined] ASC, [ACGScheduleID] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientResults', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientResults', @level2type = N'COLUMN', @level2name = N'CreatedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientResults', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientResults', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserID';

