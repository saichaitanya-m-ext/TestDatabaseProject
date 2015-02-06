CREATE TYPE [dbo].[DiseaseDefinitionCriteriaSQL] AS TABLE (
    [CriteriaSQL]   VARCHAR (MAX) NULL,
    [CriteriaText]  VARCHAR (MAX) NULL,
    [JoinType]      VARCHAR (20)  NULL,
    [JoinStatement] VARCHAR (MAX) NULL,
    [OnClause]      VARCHAR (200) NULL,
    [WhereClause]   VARCHAR (MAX) NULL);

