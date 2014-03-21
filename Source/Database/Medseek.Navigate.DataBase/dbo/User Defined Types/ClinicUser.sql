CREATE TYPE [dbo].[ClinicUser] AS TABLE (
    [ClinicUserId] [dbo].[KeyID] NULL,
    [ClinicId]     [dbo].[KeyID] NULL,
    [UserId]       [dbo].[KeyID] NULL,
    [StatusId]     [dbo].[STID]  NULL);

