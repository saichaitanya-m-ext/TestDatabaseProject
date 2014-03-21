CREATE TYPE [dbo].[DiseaseMeasure] AS TABLE (
    [DiseaseMeasureId] [dbo].[KeyID] NULL,
    [DiseaseId]        [dbo].[KeyID] NULL,
    [MeasureId]        [dbo].[KeyID] NULL,
    [Prioritization]   [dbo].[KeyID] NULL);

