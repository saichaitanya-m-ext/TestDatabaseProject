CREATE TYPE [dbo].[Filter] AS TABLE (
    [Sno]         INT          NULL,
    [ColumnName]  VARCHAR (50) NULL,
    [FilterType]  VARCHAR (50) NULL,
    [FilterValue] VARCHAR (50) NULL);

