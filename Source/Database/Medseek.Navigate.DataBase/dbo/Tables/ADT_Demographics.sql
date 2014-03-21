CREATE TABLE [dbo].[ADT_Demographics] (
    [ADTDemographicsID]                   INT           IDENTITY (1, 1) NOT NULL,
    [Patient_SetID]                       VARCHAR (100) NULL,
    [EnrollmentPIN]                       VARCHAR (150) NULL,
    [PatientEmailAddress]                 VARCHAR (100) NULL,
    [OverrideAgeOfMajority]               VARCHAR (150) NULL,
    [OverrideAccountHolderMinimumAge]     VARCHAR (150) NULL,
    [PatientWorkAddress_StreetAddress]    VARCHAR (100) NULL,
    [PatientWorkAddress_OtherDesignation] VARCHAR (100) NULL,
    [PatientWorkAddress_City]             VARCHAR (150) NULL,
    [PatientWorkAddress_StateOrProvince]  VARCHAR (150) NULL,
    [PatientWorkAddress_ZipOrPostalCode]  VARCHAR (150) NULL,
    [PatientWorkAddress_Country]          VARCHAR (150) NULL,
    [PatientWorkAddress_AddressType]      VARCHAR (150) NULL,
    [FacilityPIN_ID]                      VARCHAR (150) NULL,
    [FacilityPIN_TypeCode]                VARCHAR (150) NULL,
    [FacilityPIN_AssigningFacility]       VARCHAR (100) NULL
);

