CREATE TYPE [dbo].[SubCohortListCriteriaTbl] AS TABLE (
    [SubCohortListId]          [dbo].[KeyID] NULL,
    [SubCohortCriteriaSQL]     VARCHAR (MAX) NULL,
    [SubCohortCriteriaText]    VARCHAR (MAX) NULL,
    [CohortListCriteriaTypeID] [dbo].[KeyID] NULL,
    [CreatedByUserId]          [dbo].[KeyID] NOT NULL,
    [CreatedDate]              DATETIME      NULL);

