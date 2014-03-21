CREATE TYPE [dbo].[HealthCareCriteria] AS TABLE (
    [CriteriaTypeName] VARCHAR (50)  NULL,
    [CriteriaSQL]      VARCHAR (MAX) NULL,
    [CriteriaText]     VARCHAR (MAX) NULL);

