CREATE TABLE [dbo].[ProgramProcedureConditionalFrequency] (
    [ProgramProcedureMeasureConditionID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [ProgramID]                          [dbo].[KeyID]      NOT NULL,
    [ProcedureID]                        [dbo].[KeyID]      NOT NULL,
    [MeasureID]                          [dbo].[KeyID]      NULL,
    [FromOperatorforMeasure]             VARCHAR (5)        NULL,
    [FromValueforMeasure]                DECIMAL (10, 2)    NULL,
    [ToOperatorforMeasure]               VARCHAR (5)        NULL,
    [ToValueforMeasure]                  DECIMAL (10, 2)    NULL,
    [MeasureTextValue]                   [dbo].[SourceName] NULL,
    [FromOperatorforAge]                 VARCHAR (5)        NULL,
    [FromValueforAge]                    SMALLINT           NULL,
    [ToOperatorforAge]                   VARCHAR (5)        NULL,
    [ToValueforAge]                      SMALLINT           NULL,
    [FrequencyUOM]                       VARCHAR (1)        NOT NULL,
    [Frequency]                          SMALLINT           NOT NULL,
    [CreatedByUserId]                    [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                        [dbo].[UserDate]   CONSTRAINT [DF_ProgramProcedureConditionalFrequency_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]               [dbo].[KeyID]      NULL,
    [LastModifiedDate]                   [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_ProgramProcedureConditionalFrequency] PRIMARY KEY CLUSTERED ([ProgramProcedureMeasureConditionID] ASC),
    CONSTRAINT [FK_ProgramProcedureConditionalFrequency_ProgramProcedureConditionalFrequency] FOREIGN KEY ([MeasureID]) REFERENCES [dbo].[Measure] ([MeasureId]),
    CONSTRAINT [FK_ProgramProcedureConditionalFrequency_ProgramProcedureFrequency] FOREIGN KEY ([ProgramID], [ProcedureID]) REFERENCES [dbo].[ProgramProcedureFrequency] ([ProgramId], [ProcedureId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramProcedureConditionalFrequency', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

