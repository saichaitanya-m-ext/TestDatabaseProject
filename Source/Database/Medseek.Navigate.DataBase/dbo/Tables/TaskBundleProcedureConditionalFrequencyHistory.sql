CREATE TABLE [dbo].[TaskBundleProcedureConditionalFrequencyHistory] (
    [TaskBundleProcedureConditionalFrequencyID] [dbo].[KeyID]      NOT NULL,
    [TaskBundleProcedureFrequencyId]            [dbo].[KeyID]      NOT NULL,
    [DefinitionVersion]                         VARCHAR (5)        NOT NULL,
    [MeasureID]                                 [dbo].[KeyID]      NULL,
    [FromOperatorforMeasure]                    VARCHAR (5)        NULL,
    [FromValueforMeasure]                       DECIMAL (10, 2)    NULL,
    [ToOperatorforMeasure]                      VARCHAR (5)        NULL,
    [ToValueforMeasure]                         DECIMAL (10, 2)    NULL,
    [MeasureTextValue]                          [dbo].[SourceName] NULL,
    [FromOperatorforAge]                        VARCHAR (5)        NULL,
    [FromValueforAge]                           SMALLINT           NULL,
    [ToOperatorforAge]                          VARCHAR (5)        NULL,
    [ToValueforAge]                             SMALLINT           NULL,
    [FrequencyUOM]                              VARCHAR (1)        NOT NULL,
    [Frequency]                                 SMALLINT           NOT NULL,
    [CreatedByUserId]                           [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                               [dbo].[UserDate]   CONSTRAINT [DF_TaskBundleProcedureConditionalFrequencyHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_TaskBundleProcedureConditionalFrequencyHistory] PRIMARY KEY CLUSTERED ([TaskBundleProcedureConditionalFrequencyID] ASC, [DefinitionVersion] ASC),
    CONSTRAINT [FK_TaskBundleProcedureConditionalFrequencyHistory_Measure] FOREIGN KEY ([MeasureID]) REFERENCES [dbo].[Measure] ([MeasureId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureConditionalFrequencyHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleProcedureConditionalFrequencyHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';

