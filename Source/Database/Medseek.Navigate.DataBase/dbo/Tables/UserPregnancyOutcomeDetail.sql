CREATE TABLE [dbo].[UserPregnancyOutcomeDetail] (
    [UserPregnancyOutcomeDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [UserPregnancyOutcomeId]       INT             NOT NULL,
    [UserPregnancyDetailsID]       INT             NULL,
    [SequenceofBirth]              TINYINT         NULL,
    [TypeofDeliveryId]             INT             NULL,
    [ModeofDeliveryId]             INT             NULL,
    [BirthDate]                    DATETIME        NULL,
    [BirthTime]                    TIME (7)        NULL,
    [Gender]                       CHAR (1)        NULL,
    [Weight]                       DECIMAL (10, 2) NULL,
    [Height]                       DECIMAL (10, 2) NULL,
    [HeadCircumference]            DECIMAL (10, 2) NULL,
    [NICUadminssion]               CHAR (4)        NULL,
    [CreatedByUserId]              INT             NOT NULL,
    [CreatedDate]                  DATETIME        CONSTRAINT [DF_UserPregnancyOutcomeDetail_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]         INT             NULL,
    [LastModifiedDate]             DATETIME        NULL,
    [Comments]                     VARCHAR (500)   NULL,
    [BabyStatus]                   VARCHAR (20)    NULL,
    [BabyId]                       INT             NULL,
    [PrenatalVisits]               SMALLINT        NULL,
    [PrenatalCosts]                DECIMAL (10, 2) NULL,
    [AntepartumVisits]             SMALLINT        NULL,
    [AntepartumCosts]              DECIMAL (10, 2) NULL,
    [ERVisits]                     SMALLINT        NULL,
    [ERCosts]                      DECIMAL (10, 2) NULL,
    [IPHospVisits]                 SMALLINT        NULL,
    [IPHospCost]                   DECIMAL (10, 2) NULL,
    [DeliveryInst]                 DECIMAL (10, 2) NULL,
    [DeliveryProf]                 DECIMAL (10, 2) NULL,
    CONSTRAINT [PK_UserPregnancyOutcomeDetail_1] PRIMARY KEY CLUSTERED ([UserPregnancyOutcomeDetailId] ASC),
    CONSTRAINT [FK_UserPregnancyOutcomeDetail_ModeofDeliveryId] FOREIGN KEY ([ModeofDeliveryId]) REFERENCES [dbo].[ModeofDelivery] ([ModeofDeliveryId]),
    CONSTRAINT [FK_UserPregnancyOutcomeDetail_TypeofDeliveryId] FOREIGN KEY ([TypeofDeliveryId]) REFERENCES [dbo].[TypeofDelivery] ([TypeofDeliveryId]),
    CONSTRAINT [FK_UserPregnancyOutcomeDetail_UserPregnancyOutcomeId] FOREIGN KEY ([UserPregnancyOutcomeId]) REFERENCES [dbo].[UserPregnancyOutcome] ([UserPregnancyOutcomeId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserPregnancyOutcomeDetail', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserPregnancyOutcomeDetail', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserPregnancyOutcomeDetail', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserPregnancyOutcomeDetail', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

