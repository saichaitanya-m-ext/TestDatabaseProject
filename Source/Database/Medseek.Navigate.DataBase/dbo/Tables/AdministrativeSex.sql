CREATE TABLE [dbo].[AdministrativeSex] (
    [AdministrativeSexID] INT          IDENTITY (1, 1) NOT NULL,
    [Value]               VARCHAR (20) NULL,
    CONSTRAINT [PK_AdministrativeSex] PRIMARY KEY CLUSTERED ([AdministrativeSexID] ASC)
);

