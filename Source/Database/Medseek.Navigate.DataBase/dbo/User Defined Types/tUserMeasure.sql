CREATE TYPE [dbo].[tUserMeasure] AS TABLE (
    [MeasureId]    [dbo].[KeyID]    NULL,
    [MeasureUOMId] [dbo].[KeyID]    NULL,
    [MeasureValue] VARCHAR (200)    NULL,
    [Comments]     VARCHAR (200)    NULL,
    [DateTaken]    [dbo].[UserDate] NULL,
    [DataSourceId] [dbo].[KeyID]    NULL);

