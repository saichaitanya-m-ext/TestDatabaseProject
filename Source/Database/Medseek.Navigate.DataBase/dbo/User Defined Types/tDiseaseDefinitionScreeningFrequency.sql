CREATE TYPE [dbo].[tDiseaseDefinitionScreeningFrequency] AS TABLE (
    [ProcedureID]            [dbo].[KeyID]      NOT NULL,
    [MeasureID]              [dbo].[KeyID]      NULL,
    [FromOperatorforMeasure] VARCHAR (5)        NULL,
    [FromValueforMeasure]    DECIMAL (10, 2)    NULL,
    [ToOperatorforMeasure]   VARCHAR (5)        NULL,
    [ToValueforMeasure]      DECIMAL (10, 2)    NULL,
    [MeasureTextValue]       [dbo].[SourceName] NULL,
    [FromOperatorforAge]     VARCHAR (5)        NULL,
    [FromValueforAge]        SMALLINT           NULL,
    [ToOperatorforAge]       VARCHAR (5)        NULL,
    [ToValueforAge]          SMALLINT           NULL,
    [FrequencyUOM]           VARCHAR (1)        NOT NULL,
    [Frequency]              SMALLINT           NOT NULL);

