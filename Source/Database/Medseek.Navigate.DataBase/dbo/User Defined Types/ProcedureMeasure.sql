CREATE TYPE [dbo].[ProcedureMeasure] AS TABLE (
    [ProcedureMeasureId] [dbo].[KeyID] NULL,
    [MeasureId]          [dbo].[KeyID] NULL,
    [Frequency]          [dbo].[KeyID] NULL,
    [UnitofFrequency]    [dbo].[Unit]  NULL,
    [ProcedureId]        [dbo].[KeyID] NULL);

