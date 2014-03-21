CREATE TABLE [dbo].[HEDISMeasureComputationRun] (
    [HEDISMeasureComputationRunID] [dbo].[KeyID]       NOT NULL,
    [HEDISMeasureComputationID]    [dbo].[KeyID]       NOT NULL,
    [ComputationRunTime]           DATETIME            NOT NULL,
    [ComputationRunCompletionTime] DATETIME            NOT NULL,
    [IsScheduledRun]               [dbo].[IsIndicator] NOT NULL,
    [IsInitiatedFromUI]            [dbo].[IsIndicator] NOT NULL,
    [IsUIDisplayEnabled]           [dbo].[IsIndicator] NOT NULL,
    [RunInitiatedBy]               [dbo].[KeyID]       NOT NULL,
    [CreatedByUserID]              [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                  [dbo].[UserDate]    CONSTRAINT [DF_HEDISMeasureComputationRun_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]         [dbo].[KeyID]       NULL,
    [LastModifiedDate]             [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_HEDISMeasureComputationRun] PRIMARY KEY CLUSTERED ([HEDISMeasureComputationRunID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_HEDISMeasureComputationRun_HEDISMeasureComputation] FOREIGN KEY ([HEDISMeasureComputationID]) REFERENCES [dbo].[HEDISMeasureComputation] ([HEDISMeasureComputationID]),
    CONSTRAINT [FK_HEDISMeasureComputationRun_RunInitiatedBy] FOREIGN KEY ([RunInitiatedBy]) REFERENCES [dbo].[Patient] ([PatientID])
);

