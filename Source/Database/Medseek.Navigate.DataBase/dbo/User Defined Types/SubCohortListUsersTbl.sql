CREATE TYPE [dbo].[SubCohortListUsersTbl] AS TABLE (
    [SubCohortListId] [dbo].[KeyID]       NULL,
    [UserId]          [dbo].[KeyID]       NULL,
    [CreatedByUserId] [dbo].[UserDate]    NOT NULL,
    [CreatedDate]     DATETIME            NULL,
    [StatusCode]      [dbo].[StatusCode]  NULL,
    [LeaveInList]     [dbo].[IsIndicator] NULL);

