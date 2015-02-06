CREATE TYPE [dbo].[HealthCareCriteriaSQLTest] AS TABLE (
    [NrDrIndicator]    CHAR (1)      NULL,
    [CriteriaTypeName] VARCHAR (50)  NULL,
    [CriteriaSQL]      VARCHAR (MAX) NULL,
    [CriteriaText]     VARCHAR (MAX) NULL,
    [JoinType]         VARCHAR (20)  NULL,
    [JoinStatement]    VARCHAR (MAX) NULL,
    [OnClause]         VARCHAR (200) NULL,
    [WhereClause]      VARCHAR (MAX) NULL);

