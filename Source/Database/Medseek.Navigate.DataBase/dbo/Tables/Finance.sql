CREATE TABLE [dbo].[Finance] (
    [ConditionPatientsKey]  INT            IDENTITY (1, 1) NOT NULL,
    [DateKey]               INT            NOT NULL,
    [PopulationConditionID] INT            NOT NULL,
    [PatientID]             INT            NOT NULL,
    [HealthGroupID]         INT            NULL,
    [Amt]                   DECIMAL (5, 2) NULL
);

