CREATE TABLE [dbo].[ADTPatientIdentification] (
    [PatientIdentificationID]             [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [SetID]                               VARCHAR (50)     NULL,
    [PatientIdentifierList]               VARCHAR (50)     NULL,
    [PatientName]                         VARCHAR (200)    NULL,
    [DateOfBirth]                         [dbo].[UserDate] NULL,
    [AdministrativeSex]                   VARCHAR (50)     NULL,
    [Race]                                VARCHAR (50)     NULL,
    [PatientAddress]                      VARCHAR (50)     NULL,
    [HomePhoneNumber]                     VARCHAR (50)     NULL,
    [BusinessPhoneNumber]                 VARCHAR (50)     NULL,
    [PrimaryLanguage]                     VARCHAR (50)     NULL,
    [PatientSSNnumber]                    VARCHAR (50)     NULL,
    [EthnicGroup]                         VARCHAR (50)     NULL,
    [PatientDeathDatetime]                [dbo].[UserDate] NULL,
    [PatientDeathIndicator]               VARCHAR (50)     NULL,
    [PatientTelecommunicationInformation] VARCHAR (50)     NULL,
    [createdDate]                         [dbo].[UserDate] CONSTRAINT [DF_ADTPatientIdentification_createdDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ADTPatientIdentification] PRIMARY KEY CLUSTERED ([PatientIdentificationID] ASC)
);

