CREATE TABLE [dbo].[AdmissionType] (
    [AdmissionTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [Value]           VARCHAR (50) NULL,
    CONSTRAINT [PK_AdmissionType] PRIMARY KEY CLUSTERED ([AdmissionTypeID] ASC)
);

