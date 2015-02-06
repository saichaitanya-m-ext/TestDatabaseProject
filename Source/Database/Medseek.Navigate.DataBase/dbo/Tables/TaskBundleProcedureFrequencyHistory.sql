CREATE TABLE [dbo].[TaskBundleProcedureFrequencyHistory] (
    [TaskBundleProcedureFrequencyId] [dbo].[KeyID]       NOT NULL,
    [TaskBundleId]                   [dbo].[KeyID]       NOT NULL,
    [DefinitionVersion]              VARCHAR (5)         NOT NULL,
    [CodeGroupingId]                 [dbo].[KeyID]       NOT NULL,
    [StatusCode]                     [dbo].[StatusCode]  NOT NULL,
    [FrequencyNumber]                [dbo].[KeyID]       NULL,
    [Frequency]                      VARCHAR (1)         NULL,
    [NeverSchedule]                  BIT                 NULL,
    [ExclusionReason]                VARCHAR (100)       NULL,
    [IsPreventive]                   [dbo].[IsIndicator] NULL,
    [FrequencyCondition]             [dbo].[SourceName]  NULL,
    [CreatedByUserId]                [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                    [dbo].[UserDate]    CONSTRAINT [DF_TaskBundleProcedureFrequencyHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_TaskBundleProcedureFrequencyHistory] PRIMARY KEY CLUSTERED ([TaskBundleProcedureFrequencyId] ASC, [DefinitionVersion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TaskBundleProcedureFrequencyHistory_CodeGrouping] FOREIGN KEY ([CodeGroupingId]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_TaskBundleProcedureFrequencyHistory_TaskBundle] FOREIGN KEY ([TaskBundleId]) REFERENCES [dbo].[TaskBundle] ([TaskBundleId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureFrequencyHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureFrequencyHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';

