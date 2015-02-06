CREATE TABLE [dbo].[PatientClass] (
    [PatientClassID] INT          IDENTITY (1, 1) NOT NULL,
    [Value]          VARCHAR (50) NULL,
    CONSTRAINT [PK_PatientClass] PRIMARY KEY CLUSTERED ([PatientClassID] ASC)
);

