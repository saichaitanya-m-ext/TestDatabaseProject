CREATE TABLE [dbo].[DoctorName] (
    [DoctorID]         INT          IDENTITY (1, 1) NOT NULL,
    [PersonIdentifier] VARCHAR (20) NULL,
    [FamilyName]       VARCHAR (50) NULL,
    [GivenName]        VARCHAR (50) NULL,
    [FurtherGivenName] VARCHAR (50) NULL,
    [Suffix]           VARCHAR (20) NULL,
    [Prefix]           VARCHAR (20) NULL,
    [Degree]           VARCHAR (20) NULL,
    CONSTRAINT [PK_DoctorName] PRIMARY KEY CLUSTERED ([DoctorID] ASC)
);

