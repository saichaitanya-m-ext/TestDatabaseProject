CREATE TABLE [dbo].[ADTPatientVisit] (
    [PatientVisitID]          [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [SetID]                   VARCHAR (50)     NULL,
    [PatientClass]            VARCHAR (50)     NULL,
    [AssignedPatientLocation] VARCHAR (50)     NULL,
    [AttendingDoctor]         VARCHAR (50)     NULL,
    [RefferingDoctor]         VARCHAR (50)     NULL,
    [HospitalService]         VARCHAR (50)     NULL,
    [Re-AdmissionIndicator]   VARCHAR (50)     NULL,
    [AdmittingDoctor]         VARCHAR (50)     NULL,
    [DischargeDisposition]    VARCHAR (50)     NULL,
    [DischargedToLocation]    VARCHAR (50)     NULL,
    [AdmitDatetime]           [dbo].[UserDate] NULL,
    [DischargeDatetime]       [dbo].[UserDate] NULL,
    [CreatedDate]             [dbo].[UserDate] CONSTRAINT [DF_ADTPatientVisit_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ADTPatientVisit] PRIMARY KEY CLUSTERED ([PatientVisitID] ASC)
);

