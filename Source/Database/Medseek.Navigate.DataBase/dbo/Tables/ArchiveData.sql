CREATE TABLE [dbo].[ArchiveData] (
    [PatientID]  [dbo].[KeyID]      NOT NULL,
    [FirstName]  [dbo].[FirstName]  NOT NULL,
    [MiddleName] [dbo].[MiddleName] NULL,
    [LastName]   VARCHAR (100)      NOT NULL,
    [NameSuffix] VARCHAR (10)       NULL,
    [NamePrefix] VARCHAR (10)       NULL,
    [Gender]     VARCHAR (1)        NULL
);

