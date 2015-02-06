CREATE TABLE [dbo].[PersonLocationType] (
    [LocationTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [Value]          VARCHAR (50) NULL,
    CONSTRAINT [PK_PersonLocationType] PRIMARY KEY CLUSTERED ([LocationTypeID] ASC)
);

