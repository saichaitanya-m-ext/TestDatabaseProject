﻿CREATE TABLE [dbo].[ADT_Guarantor] (
    [ADTGuarantorID]                        INT           IDENTITY (1, 1) NOT NULL,
    [Patient_SetID]                         VARCHAR (100) NULL,
    [SetId]                                 VARCHAR (150) NULL,
    [GuarantorNumber_ID]                    VARCHAR (150) NULL,
    [GuarantorNumber_TypeCode]              VARCHAR (150) NULL,
    [GuarantorNumber_AssigningFacility]     VARCHAR (100) NULL,
    [Guarantor_FamilyName]                  VARCHAR (150) NULL,
    [Guarantor_GivenName]                   VARCHAR (150) NULL,
    [Guarantor_FurtherGivenName]            VARCHAR (150) NULL,
    [Guarantor_Suffix]                      VARCHAR (150) NULL,
    [Guarantor_Prefix]                      VARCHAR (150) NULL,
    [Guarantor_StreetAddress]               VARCHAR (100) NULL,
    [Guarantor_OtherDesignation]            VARCHAR (100) NULL,
    [Guarantor_City]                        VARCHAR (150) NULL,
    [Guarantor_StateOrProvince]             VARCHAR (150) NULL,
    [Guarantor_ZipOrPostalCode]             VARCHAR (150) NULL,
    [Guarantor_Country]                     VARCHAR (150) NULL,
    [Guarantor_AddressType]                 VARCHAR (150) NULL,
    [HomePhoneNumber_UseCode]               VARCHAR (150) NULL,
    [HomePhoneNumber_EquipmentType]         VARCHAR (150) NULL,
    [HomePhoneNumber_CommAddress]           VARCHAR (100) NULL,
    [HomePhoneNumber_CountryCode]           VARCHAR (150) NULL,
    [HomePhoneNumber_AreaCode]              VARCHAR (150) NULL,
    [HomePhoneNumber_LocalNumber]           VARCHAR (150) NULL,
    [HomePhoneNumber_Extension]             VARCHAR (150) NULL,
    [BusinessPhoneNumber_UseCode]           VARCHAR (150) NULL,
    [BusinessPhoneNumber_EquipmentType]     VARCHAR (150) NULL,
    [BusinessPhoneNumber_CommAddress]       VARCHAR (100) NULL,
    [BusinessPhoneNumber_CountryCode]       VARCHAR (150) NULL,
    [BusinessPhoneNumber_AreaCode]          VARCHAR (150) NULL,
    [BusinessPhoneNumber_LocalNumber]       VARCHAR (150) NULL,
    [BusinessPhoneNumber_Extension]         VARCHAR (150) NULL,
    [DateOfBirth]                           VARCHAR (100) NULL,
    [Sex]                                   VARCHAR (150) NULL,
    [Relationship]                          VARCHAR (150) NULL,
    [SSN]                                   VARCHAR (150) NULL,
    [GuarantorPriority]                     VARCHAR (150) NULL,
    [Employer_EmployerID_ID]                VARCHAR (150) NULL,
    [Employer_EmployerID_TypeCode]          VARCHAR (150) NULL,
    [Employer_EmployerID_AssigningFacility] VARCHAR (100) NULL,
    [Employer_OrganizationName]             VARCHAR (100) NULL,
    [Employer_OrganizationTypeCode]         VARCHAR (150) NULL,
    [EmployerAddresses_StreetAddress]       VARCHAR (100) NULL,
    [EmployerAddresses_OtherDesignation]    VARCHAR (100) NULL,
    [EmployerAddresses_City]                VARCHAR (150) NULL,
    [EmployerAddresses_StateOrProvince]     VARCHAR (150) NULL,
    [EmployerAddresses_ZipOrPostalCode]     VARCHAR (150) NULL,
    [EmployerAddresses_Country]             VARCHAR (150) NULL,
    [EmployerAddresses_AddressType]         VARCHAR (150) NULL,
    [EmployerPhoneNumbers_UseCode]          VARCHAR (150) NULL,
    [EmployerPhoneNumbers_EquipmentType]    VARCHAR (150) NULL,
    [EmployerPhoneNumbers_CommAddress]      VARCHAR (100) NULL,
    [EmployerPhoneNumbers_CountryCode]      VARCHAR (150) NULL,
    [EmployerPhoneNumbers_AreaCode]         VARCHAR (150) NULL,
    [EmployerPhoneNumbers_LocalNumber]      VARCHAR (150) NULL,
    [EmployerPhoneNumbers_Extension]        VARCHAR (150) NULL
);

