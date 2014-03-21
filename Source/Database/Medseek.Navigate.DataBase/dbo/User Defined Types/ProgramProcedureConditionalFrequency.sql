CREATE TYPE [dbo].[ProgramProcedureConditionalFrequency] AS TABLE (
    [MeasureID]             [dbo].[KeyID]      NULL,
    [MeasureName]           VARCHAR (100)      NULL,
    [MeasureUOM]            VARCHAR (50)       NULL,
    [FromOperatorWithValue] VARCHAR (15)       NULL,
    [ToOperatorWithValue]   VARCHAR (15)       NULL,
    [MeasureTextValue]      [dbo].[SourceName] NULL,
    [FromOperatorWithAge]   VARCHAR (10)       NULL,
    [ToOperatorWithAge]     VARCHAR (10)       NULL,
    [FrequencyNumberUOM]    VARCHAR (20)       NULL);

