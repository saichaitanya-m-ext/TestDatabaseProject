CREATE TYPE [dbo].[OrganizationUser] AS TABLE (
    [OrganizationUserId] [dbo].[KeyID] NULL,
    [OrganizationId]     [dbo].[KeyID] NULL,
    [UserId]             [dbo].[KeyID] NULL);

