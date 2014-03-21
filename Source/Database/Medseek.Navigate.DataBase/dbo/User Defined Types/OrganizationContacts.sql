CREATE TYPE [dbo].[OrganizationContacts] AS TABLE (
    [OrganizationContactsId] [dbo].[KeyID]      NULL,
    [ContactTypeId]          [dbo].[KeyID]      NULL,
    [OrganizationId]         [dbo].[KeyID]      NULL,
    [FirstName]              [dbo].[FirstName]  NULL,
    [MiddleName]             [dbo].[MiddleName] NULL,
    [LastName]               [dbo].[LastName]   NULL,
    [EmailID]                [dbo].[EmailId]    NULL,
    [Phone]                  [dbo].[Phone]      NULL,
    [PhoneExt]               [dbo].[PhoneExt]   NULL,
    [StatusCode]             [dbo].[StatusCode] NULL);

