CREATE TABLE [dbo].[ADTPatientAdditionalVisitInfo] (
    [PatientAdditionalVisitID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [AdmitReason]              VARCHAR (50)     NULL,
    [CreatedDate]              [dbo].[UserDate] CONSTRAINT [DF_ADTPatientAdditionalVisitInfo_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ADTPatientAdditionalVisitInfo] PRIMARY KEY CLUSTERED ([PatientAdditionalVisitID] ASC)
);

