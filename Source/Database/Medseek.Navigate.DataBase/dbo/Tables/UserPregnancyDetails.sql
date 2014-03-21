CREATE TABLE [dbo].[UserPregnancyDetails] (
    [UserPregnancyDetailsID]        INT           IDENTITY (1, 1) NOT NULL,
    [PatientID]                     INT           NOT NULL,
    [FirstDayofLastMenstrualPeriod] DATE          NULL,
    [EstimatedConceptionDate]       DATE          NULL,
    [EstimatedDeliveryDate]         DATE          NULL,
    [DatePrenatalCareBegan]         DATE          NULL,
    [TotalWeightGainORLossInLBs]    VARCHAR (10)  NULL,
    [PretermLaborRisk]              BIT           NOT NULL,
    [PretermLaborRiskComments]      VARCHAR (100) NULL,
    [Comments]                      VARCHAR (500) NULL,
    [EstimatedFirstTrimesterDate]   DATE          NULL,
    [EstimatedSecondTrimester]      DATE          NULL,
    [EstimatedThirdTrimester]       DATE          NULL,
    [Trimester1]                    BIT           NULL,
    [Trimester2]                    BIT           NULL,
    [Trimester3]                    BIT           NULL,
    [Trimester1Severity]            CHAR (1)      NULL,
    [Trimester2Severity]            CHAR (1)      NULL,
    [Trimester3Severity]            CHAR (1)      NULL,
    [EthnicityID]                   INT           NULL,
    [RaceID]                        INT           NULL,
    [BloodGroupID]                  INT           NULL,
    [CreatedByUserId]               INT           NOT NULL,
    [CreatedDate]                   DATETIME      CONSTRAINT [DF_UserPregnancyDetails_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          INT           NULL,
    [LastModifiedDate]              DATETIME      NULL,
    [EstimatedWeeks]                VARCHAR (20)  NULL,
    [DataSourceId]                  [dbo].[KeyID] NULL,
    CONSTRAINT [PK_UserPregnancyDetails] PRIMARY KEY CLUSTERED ([UserPregnancyDetailsID] ASC),
    CONSTRAINT [FK_UserPregnancyDetails_DataSourceId] FOREIGN KEY ([DataSourceId]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_UserPregnancyDetails_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_UserPregnancyDetails]
    ON [dbo].[UserPregnancyDetails]([PatientID] ASC, [FirstDayofLastMenstrualPeriod] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserPregnancyDetails', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserPregnancyDetails', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserPregnancyDetails', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserPregnancyDetails', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

