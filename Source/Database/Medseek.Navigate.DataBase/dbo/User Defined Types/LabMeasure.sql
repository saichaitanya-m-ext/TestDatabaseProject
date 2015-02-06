CREATE TYPE [dbo].[LabMeasure] AS TABLE (
    [LabMeasureId]           [dbo].[KeyID] NULL,
    [MeasureId]              [dbo].[KeyID] NULL,
    [IsGoodControl]          TINYINT       NULL,
    [OperatorforGoodControl] VARCHAR (10)  NULL,
    [Value1forGoodControl]   DECIMAL (18)  NULL,
    [Value2forGoodControl]   DECIMAL (18)  NULL,
    [IsFairControl]          TINYINT       NULL,
    [OperatorforFairControl] VARCHAR (10)  NULL,
    [Value1forFairControl]   DECIMAL (18)  NULL,
    [Value2forFairControl]   DECIMAL (18)  NULL,
    [IsPoorControl]          TINYINT       NULL,
    [OperatorforPoorControl] VARCHAR (10)  NULL,
    [Value1forPoorControl]   DECIMAL (18)  NULL,
    [Value2forPoorControl]   DECIMAL (18)  NULL,
    [Units]                  VARCHAR (1)   NULL);

