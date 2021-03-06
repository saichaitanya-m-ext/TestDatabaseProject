﻿CREATE TYPE [dbo].[tblADTPatient] AS TABLE (
    [Patient_PrimaryId_Id]                             VARCHAR (200) NULL,
    [Identifiers_Identifier_Id]                        VARCHAR (200) NULL,
    [Identifiers_Identifier_TypeCode]                  VARCHAR (200) NULL,
    [Identifiers_Identifier_AssigningFacility]         VARCHAR (200) NULL,
    [PatientNames_Name_FamilyName]                     VARCHAR (200) NULL,
    [PatientNames_Name_GivenName]                      VARCHAR (200) NULL,
    [DateOfBirth]                                      VARCHAR (200) NULL,
    [Sex]                                              VARCHAR (200) NULL,
    [Races_Race_OriginalNameCode]                      VARCHAR (200) NULL,
    [Races_Race_NameCode]                              VARCHAR (200) NULL,
    [Addresses_Address_StreetAddress]                  VARCHAR (200) NULL,
    [Addresses_Address_City]                           VARCHAR (200) NULL,
    [Addresses_Address_StateOrProvince]                VARCHAR (200) NULL,
    [Addresses_Address_ZipOrPostalCode]                VARCHAR (200) NULL,
    [Addresses_Address_Country]                        VARCHAR (200) NULL,
    [Addresses_Address_AddressType]                    VARCHAR (200) NULL,
    [HomePhoneNumbers_TeleComNumber_UseCode]           VARCHAR (200) NULL,
    [HomePhoneNumbers_TeleComNumber_EquipmentType]     VARCHAR (200) NULL,
    [HomePhoneNumbers_TeleComNumber_CommAddress]       VARCHAR (200) NULL,
    [HomePhoneNumbers_TeleComNumber_CountryCode]       VARCHAR (200) NULL,
    [HomePhoneNumbers_TeleComNumber_AreaCode]          VARCHAR (200) NULL,
    [HomePhoneNumbers_TeleComNumber_LocalNumber]       VARCHAR (200) NULL,
    [BusinessPhoneNumbers_TeleComNumber_UseCode]       VARCHAR (200) NULL,
    [BusinessPhoneNumbers_TeleComNumber_EquipmentType] VARCHAR (200) NULL,
    [BusinessPhoneNumbers_TeleComNumber_CommAddress]   VARCHAR (200) NULL,
    [BusinessPhoneNumbers_TeleComNumber_CountryCode]   VARCHAR (200) NULL,
    [BusinessPhoneNumbers_TeleComNumber_AreaCode]      VARCHAR (200) NULL,
    [BusinessPhoneNumbers_TeleComNumber_LocalNumber]   VARCHAR (200) NULL,
    [MaritalStatus]                                    VARCHAR (200) NULL,
    [Religion]                                         VARCHAR (200) NULL,
    [SSN]                                              VARCHAR (200) NULL,
    [EthnicGroups_EthnicGroup_OriginalNameCode]        VARCHAR (200) NULL,
    [EthnicGroups_EthnicGroup_NameCode]                VARCHAR (200) NULL,
    [Languages_Language_OriginalNameCode]              VARCHAR (200) NULL,
    [Languages_Language_NameCode]                      VARCHAR (200) NULL,
    [DeathIndicator]                                   VARCHAR (200) NULL);

