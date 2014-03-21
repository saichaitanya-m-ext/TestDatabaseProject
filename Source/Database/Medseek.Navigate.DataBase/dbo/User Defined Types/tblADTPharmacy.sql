CREATE TYPE [dbo].[tblADTPharmacy] AS TABLE (
    [NAME]                    VARCHAR (200) NULL,
    [Address_StreetAddress]   VARCHAR (200) NULL,
    [Address_City]            VARCHAR (200) NULL,
    [Address_StateOrProvince] VARCHAR (200) NULL,
    [Address_ZipOrPostalCode] VARCHAR (200) NULL,
    [Address_Country]         VARCHAR (200) NULL,
    [Address_AddressType]     VARCHAR (200) NULL,
    [IsPreferred]             VARCHAR (200) NULL,
    [EmailAddress]            VARCHAR (200) NULL);

