﻿CREATE TABLE [dbo].[ADT_Patient] (
    [ADTPatientID]                         INT           IDENTITY (1, 1) NOT NULL,
    [Patient_SetId]                        VARCHAR (150) NULL,
    [Patient_PrimaryID_ID]                 VARCHAR (150) NULL,
    [Patient_PrimaryID_TypeCode]           VARCHAR (150) NULL,
    [Patient_PrimaryID_AssigningFacility]  VARCHAR (100) NULL,
    [Patient_Identifier_ID]                VARCHAR (150) NULL,
    [Patient_Identifier_TypeCode]          VARCHAR (150) NULL,
    [Patient_Identifier_AssigningFacility] VARCHAR (100) NULL,
    [Patient_FamilyName]                   VARCHAR (100) NULL,
    [Patient_GivenName]                    VARCHAR (100) NULL,
    [Patient_FurtherGivenName]             VARCHAR (100) NULL,
    [Patient_Suffix]                       VARCHAR (100) NULL,
    [Patient_Prefix]                       VARCHAR (100) NULL,
    [DateOfBirth]                          VARCHAR (100) NULL,
    [Sex]                                  VARCHAR (150) NULL,
    [Race_OriginalNameCode]                VARCHAR (150) NULL,
    [Race_NameCode]                        VARCHAR (150) NULL,
    [Patient_StreetAddress]                VARCHAR (100) NULL,
    [Patient_OtherDesignation]             VARCHAR (100) NULL,
    [Patient_City]                         VARCHAR (150) NULL,
    [Patient_StateOrProvince]              VARCHAR (150) NULL,
    [Patient_ZipOrPostalCode]              VARCHAR (150) NULL,
    [Patient_Country]                      VARCHAR (150) NULL,
    [Patient_AddressType]                  VARCHAR (150) NULL,
    [HomePhoneNumber_UseCode]              VARCHAR (150) NULL,
    [HomePhoneNumber_EquipmentType]        VARCHAR (150) NULL,
    [HomePhoneNumber_CommAddress]          VARCHAR (100) NULL,
    [HomePhoneNumber_CountryCode]          VARCHAR (150) NULL,
    [HomePhoneNumber_AreaCode]             VARCHAR (150) NULL,
    [HomePhoneNumber_LocalNumber]          VARCHAR (150) NULL,
    [HomePhoneNumber_Extension]            VARCHAR (150) NULL,
    [BusinessPhoneNumber_UseCode]          VARCHAR (150) NULL,
    [BusinessPhoneNumber_EquipmentType]    VARCHAR (150) NULL,
    [BusinessPhoneNumber_CommAddress]      VARCHAR (100) NULL,
    [BusinessPhoneNumber_CountryCode]      VARCHAR (150) NULL,
    [BusinessPhoneNumber_AreaCode]         VARCHAR (150) NULL,
    [BusinessPhoneNumber_LocalNumber]      VARCHAR (150) NULL,
    [BusinessPhoneNumber_Extension]        VARCHAR (150) NULL,
    [MaritalStatus]                        VARCHAR (150) NULL,
    [Religion]                             VARCHAR (150) NULL,
    [SSN]                                  VARCHAR (150) NULL,
    [EthnicGroup_OriginalNameCode]         VARCHAR (30)  NULL,
    [EthnicGroup_NameCode]                 VARCHAR (30)  NULL,
    [Language_OriginalNameCode]            VARCHAR (30)  NULL,
    [Language_NameCode]                    VARCHAR (30)  NULL,
    [TelecomInformation_UseCode]           VARCHAR (150) NULL,
    [TelecomInformation_EquipmentType]     VARCHAR (150) NULL,
    [TelecomInformation_CommAddress]       VARCHAR (100) NULL,
    [TelecomInformation_CountryCode]       VARCHAR (150) NULL,
    [TelecomInformation_AreaCode]          VARCHAR (150) NULL,
    [TelecomInformation_LocalNumber]       VARCHAR (150) NULL,
    [TelecomInformation_Extension]         VARCHAR (150) NULL,
    [EmailAddress]                         VARCHAR (100) NULL,
    [Enrolled]                             VARCHAR (150) NULL,
    [ClinicalDocumentsCount]               VARCHAR (150) NULL,
    [DeathIndicator]                       VARCHAR (150) NULL,
    [DeathDateTime]                        VARCHAR (100) NULL
);

