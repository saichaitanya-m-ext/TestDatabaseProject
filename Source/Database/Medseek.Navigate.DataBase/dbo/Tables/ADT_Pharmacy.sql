CREATE TABLE [dbo].[ADT_Pharmacy] (
    [ADTPharmacyID]                  INT           IDENTITY (1, 1) NOT NULL,
    [Patient_SetID]                  VARCHAR (100) NULL,
    [PharmacyName]                   VARCHAR (100) NULL,
    [Pharmacy_StreetAddress]         VARCHAR (100) NULL,
    [Pharmacy_OtherDesignation]      VARCHAR (100) NULL,
    [Pharmacy_City]                  VARCHAR (150) NULL,
    [Pharmacy_StateOrProvince]       VARCHAR (150) NULL,
    [Pharmacy_ZipOrPostalCode]       VARCHAR (150) NULL,
    [Pharmacy_Country]               VARCHAR (150) NULL,
    [Pharmacy_AddressType]           VARCHAR (150) NULL,
    [TelephoneNumbers_UseCode]       VARCHAR (150) NULL,
    [TelephoneNumbers_EquipmentType] VARCHAR (150) NULL,
    [TelephoneNumbers_CommAddress]   VARCHAR (100) NULL,
    [TelephoneNumbers_CountryCode]   VARCHAR (150) NULL,
    [TelephoneNumbers_AreaCode]      VARCHAR (150) NULL,
    [TelephoneNumbers_LocalNumber]   VARCHAR (150) NULL,
    [TelephoneNumbers_Extension]     VARCHAR (150) NULL,
    [Website]                        VARCHAR (100) NULL,
    [IsPreferred]                    VARCHAR (150) NULL,
    [EmailAddress]                   VARCHAR (100) NULL
);

