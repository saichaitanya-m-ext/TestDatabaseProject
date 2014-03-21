CREATE TABLE [dbo].[HEDISMeasureComputationRunResultNumeratorValue] (
    [HEDISMeasureComputationRunResultID] INT      IDENTITY (1, 1) NOT NULL,
    [HEDISMeasureComputationRunID]       INT      NOT NULL,
    [PatientID]                          INT      NOT NULL,
    [OutputValue]                        INT      NOT NULL,
    [OutputValueDate]                    DATETIME NULL,
    [UnitOfMeasureID]                    INT      NULL,
    [CreatedByUserID]                    INT      NOT NULL,
    [CreatedDate]                        DATETIME CONSTRAINT [DF_HEDISMeasureComputationRunResultNumeratorValue_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_HEDISMeasureComputationRunResultNumeratorValue] PRIMARY KEY CLUSTERED ([HEDISMeasureComputationRunID] ASC, [PatientID] ASC),
    CONSTRAINT [FK_HEDISMeasureComputationRunResultNumeratorValue_CodeSetUnitOfMeasure] FOREIGN KEY ([UnitOfMeasureID]) REFERENCES [dbo].[CodeSetUnitOfMeasure] ([UnitOfMeasureID]),
    CONSTRAINT [FK_HEDISMeasureComputationRunResultNumeratorValue_HEDISMeasureComputation] FOREIGN KEY ([HEDISMeasureComputationRunID]) REFERENCES [dbo].[HEDISMeasureComputation] ([HEDISMeasureComputationID]),
    CONSTRAINT [FK_HEDISMeasureComputationRunResultNumeratorValue_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);

