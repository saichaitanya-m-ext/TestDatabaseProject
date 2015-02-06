CREATE TABLE [dbo].[HEDISMeasureComputationRunResultNumeratorCount] (
    [HEDISMeasureComputationRunResultID] INT      IDENTITY (1, 1) NOT NULL,
    [HEDISMeasureComputationRunID]       INT      NOT NULL,
    [PatientID]                          INT      NOT NULL,
    [OutputCount]                        INT      NOT NULL,
    [CreatedByUserID]                    INT      NOT NULL,
    [CreatedDate]                        DATETIME CONSTRAINT [DF_HEDISMeasureComputationRunResultNumeratorCount_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_HEDISMeasureComputationRunResultNumeratorCount] PRIMARY KEY CLUSTERED ([HEDISMeasureComputationRunID] ASC, [PatientID] ASC),
    CONSTRAINT [FK_HEDISMeasureComputationRunResultNumeratorCount_HEDISMeasureComputation] FOREIGN KEY ([HEDISMeasureComputationRunID]) REFERENCES [dbo].[HEDISMeasureComputation] ([HEDISMeasureComputationID]),
    CONSTRAINT [FK_HEDISMeasureComputationRunResultNumeratorCount_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);

