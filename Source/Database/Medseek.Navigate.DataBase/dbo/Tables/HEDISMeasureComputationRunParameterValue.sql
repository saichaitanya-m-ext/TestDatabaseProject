CREATE TABLE [dbo].[HEDISMeasureComputationRunParameterValue] (
    [HEDISMeasureComputationRunParameterValueID] INT            IDENTITY (1, 1) NOT NULL,
    [HEDISMeasureComputationRunID]               INT            NOT NULL,
    [HEDISMeasureComputationParameterID]         INT            NOT NULL,
    [ParameterValue]                             VARCHAR (1000) NOT NULL,
    [IsSystemDefaultValue]                       BIT            CONSTRAINT [DF_HEDISMeasureComputationRunParameterValue_IsSystemDefaultValue] DEFAULT ('1') NOT NULL,
    [CreatedByUserID]                            INT            NOT NULL,
    [CreatedDate]                                DATETIME       CONSTRAINT [DF_HEDISMeasureComputationRunParameterValue_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_HEDISMeasureComputationRunParameterValue] PRIMARY KEY CLUSTERED ([HEDISMeasureComputationRunID] ASC, [HEDISMeasureComputationParameterID] ASC),
    CONSTRAINT [FK_HEDISMeasureComputationRunParameterValue_HEDISMeasureComputationParameter] FOREIGN KEY ([HEDISMeasureComputationParameterID]) REFERENCES [dbo].[HEDISMeasureComputationParameter] ([HEDISMeasureComputationParameterID]),
    CONSTRAINT [FK_HEDISMeasureComputationRunParameterValue_HEDISMeasureComputationRun] FOREIGN KEY ([HEDISMeasureComputationRunID]) REFERENCES [dbo].[HEDISMeasureComputationRun] ([HEDISMeasureComputationRunID])
);

