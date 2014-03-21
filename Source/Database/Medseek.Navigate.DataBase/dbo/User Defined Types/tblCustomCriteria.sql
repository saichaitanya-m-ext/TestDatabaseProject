CREATE TYPE [dbo].[tblCustomCriteria] AS TABLE (
    [CriteriaTypeName]   VARCHAR (100)  NULL,
    [CriteriaSQL]        VARCHAR (8000) NULL,
    [CohortCriteriaText] VARCHAR (8000) NULL,
    [JoinType]           VARCHAR (20)   NULL,
    [JoinStatement]      VARCHAR (4000) NULL,
    [OnClause]           VARCHAR (200)  NULL,
    [WhereClause]        VARCHAR (4000) NULL);

