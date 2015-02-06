CREATE TABLE [dbo].[TaskBundleAdhocFrequencyHistory] (
    [TaskBundleAdhocFrequencyID] [dbo].[KeyID]      NOT NULL,
    [TaskBundleId]               [dbo].[KeyID]      NOT NULL,
    [AdhocTaskId]                [dbo].[KeyID]      NULL,
    [DefinitionVersion]          VARCHAR (5)        NOT NULL,
    [FrequencyNumber]            INT                NOT NULL,
    [Frequency]                  VARCHAR (1)        NOT NULL,
    [Comments]                   VARCHAR (500)      NULL,
    [StatusCode]                 [dbo].[StatusCode] NOT NULL,
    [CreatedByUserId]            [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                [dbo].[UserDate]   CONSTRAINT [DF_TaskBundleAdhocFrequencyHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_TaskBundleAdhocFrequencyHistory_1] PRIMARY KEY CLUSTERED ([TaskBundleAdhocFrequencyID] ASC, [DefinitionVersion] ASC),
    CONSTRAINT [FK_TaskBundleAdhocFrequencyHistory_AdhocTask] FOREIGN KEY ([AdhocTaskId]) REFERENCES [dbo].[AdhocTask] ([AdhocTaskId]),
    CONSTRAINT [FK_TaskBundleAdhocFrequencyHistory_TaskBundle] FOREIGN KEY ([TaskBundleId]) REFERENCES [dbo].[TaskBundle] ([TaskBundleId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleAdhocFrequencyHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleAdhocFrequencyHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';

