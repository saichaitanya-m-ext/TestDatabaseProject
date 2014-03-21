CREATE TABLE [dbo].[NumeratorGoal] (
    [MetricNumeratorFrequencyID] INT NOT NULL,
    [EntityTypeID]               INT NOT NULL,
    CONSTRAINT [PK_NumeratorGoal] PRIMARY KEY CLUSTERED ([MetricNumeratorFrequencyID] ASC, [EntityTypeID] ASC) ON [FG_Library]
);

