CREATE TABLE [dbo].[DataLoad_CodeSetNPIProviderLicenseNumber] (
    [NPI]                                   NUMERIC (10) NULL,
    [Provider License Number_1]             VARCHAR (20) NULL,
    [Provider License Number_2]             VARCHAR (20) NULL,
    [Provider License Number_3]             VARCHAR (20) NULL,
    [Provider License Number_4]             VARCHAR (20) NULL,
    [Provider License Number_5]             VARCHAR (20) NULL,
    [Provider License Number_6]             VARCHAR (20) NULL,
    [Provider License Number_7]             VARCHAR (20) NULL,
    [Provider License Number_8]             VARCHAR (20) NULL,
    [Provider License Number_9]             VARCHAR (20) NULL,
    [Provider License Number_10]            VARCHAR (20) NULL,
    [Provider License Number_11]            VARCHAR (20) NULL,
    [Provider License Number_12]            VARCHAR (20) NULL,
    [Provider License Number_13]            VARCHAR (20) NULL,
    [Provider License Number_14]            VARCHAR (20) NULL,
    [Provider License Number_15]            VARCHAR (20) NULL,
    [Provider License Number State Code_1]  VARCHAR (2)  NULL,
    [Provider License Number State Code_2]  VARCHAR (2)  NULL,
    [Provider License Number State Code_3]  VARCHAR (2)  NULL,
    [Provider License Number State Code_4]  VARCHAR (2)  NULL,
    [Provider License Number State Code_5]  VARCHAR (2)  NULL,
    [Provider License Number State Code_6]  VARCHAR (2)  NULL,
    [Provider License Number State Code_7]  VARCHAR (2)  NULL,
    [Provider License Number State Code_8]  VARCHAR (2)  NULL,
    [Provider License Number State Code_9]  VARCHAR (2)  NULL,
    [Provider License Number State Code_10] VARCHAR (2)  NULL,
    [Provider License Number State Code_11] VARCHAR (2)  NULL,
    [Provider License Number State Code_12] VARCHAR (2)  NULL,
    [Provider License Number State Code_13] VARCHAR (2)  NULL,
    [Provider License Number State Code_14] VARCHAR (2)  NULL,
    [Provider License Number State Code_15] VARCHAR (2)  NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [UQ_DataLoad_NPIProviderLicenseNumber_NPI]
    ON [dbo].[DataLoad_CodeSetNPIProviderLicenseNumber]([NPI] ASC)
    ON [FG_Codesets];

