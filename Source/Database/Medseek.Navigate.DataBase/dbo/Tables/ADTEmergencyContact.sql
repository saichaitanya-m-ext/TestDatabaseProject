﻿CREATE TABLE [dbo].[ADTEmergencyContact] (
    [Patient_PrimaryId_Id]              VARCHAR (200) NULL,
    [Identifier]                        VARCHAR (200) NULL,
    [ContactName_FamilyName]            VARCHAR (200) NULL,
    [ContactName_GivenName]             VARCHAR (200) NULL,
    [ContactName_Suffix]                VARCHAR (200) NULL,
    [ContactAddress_StreetAddress]      VARCHAR (200) NULL,
    [ContactAddress_City]               VARCHAR (200) NULL,
    [ContactAddress_StateOrProvince]    VARCHAR (200) NULL,
    [ContactAddress_ZipOrPostalCode]    VARCHAR (200) NULL,
    [ContactAddress_Country]            VARCHAR (200) NULL,
    [ContactAddress_AddressType]        VARCHAR (200) NULL,
    [HomePhoneNumber_UseCode]           VARCHAR (200) NULL,
    [HomePhoneNumber_EquipmentType]     VARCHAR (200) NULL,
    [HomePhoneNumber_CountryCode]       VARCHAR (200) NULL,
    [HomePhoneNumber_AreaCode]          VARCHAR (200) NULL,
    [HomePhoneNumber_LocalNumber]       VARCHAR (200) NULL,
    [HomePhoneNumber_Extension]         VARCHAR (200) NULL,
    [BusinessPhoneNumber_UseCode]       VARCHAR (200) NULL,
    [BusinessPhoneNumber_EquipmentType] VARCHAR (200) NULL,
    [BusinessPhoneNumber_CountryCode]   VARCHAR (200) NULL,
    [BusinessPhoneNumber_AreaCode]      VARCHAR (200) NULL,
    [BusinessPhoneNumber_LocalNumber]   VARCHAR (200) NULL,
    [BusinessPhoneNumber_Extension]     VARCHAR (200) NULL,
    [MobileNumber_EquipmentType]        VARCHAR (200) NULL,
    [MobileNumber_AreaCode]             VARCHAR (200) NULL,
    [Relationship]                      VARCHAR (200) NULL,
    [EmailAddress]                      VARCHAR (200) NULL,
    [EventType]                         VARCHAR (200) NULL
);

