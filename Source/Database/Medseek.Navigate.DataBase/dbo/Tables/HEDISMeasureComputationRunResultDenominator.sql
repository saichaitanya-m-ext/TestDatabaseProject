CREATE TABLE [dbo].[HEDISMeasureComputationRunResultDenominator] (
    [HEDISMeasureComputationRunResultID] INT      IDENTITY (1, 1) NOT NULL,
    [HEDISMeasureComputationRunID]       INT      NOT NULL,
    [PatientID]                          INT      NOT NULL,
    [OutputAnchortDate]                  DATETIME NOT NULL,
    [IsSystemDefaultValue]               BIT      NOT NULL,
    [CreatedByUserID]                    INT      NOT NULL,
    [CreatedDate]                        DATETIME CONSTRAINT [DF_HEDISMeasureComputationRunResultDenominator_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_HEDISMeasureComputationRunResultDenominator] PRIMARY KEY CLUSTERED ([HEDISMeasureComputationRunID] ASC, [PatientID] ASC),
    CONSTRAINT [FK_HEDISMeasureComputationRunResultDenominator_HEDISMeasureComputationRun] FOREIGN KEY ([HEDISMeasureComputationRunID]) REFERENCES [dbo].[HEDISMeasureComputationRun] ([HEDISMeasureComputationRunID]),
    CONSTRAINT [FK_HEDISMeasureComputationRunResultDenominator_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);

