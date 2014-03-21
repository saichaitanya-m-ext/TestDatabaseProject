﻿CREATE TABLE [dbo].[Provider] (
    [ProviderID]                        [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [UserID]                            [dbo].[KeyID]            NULL,
    [IsIndividual]                      [dbo].[IsIndicator]      NOT NULL,
    [OrganizationName]                  [dbo].[ShortDescription] NULL,
    [FirstName]                         [dbo].[FirstName]        NULL,
    [MiddleName]                        [dbo].[MiddleName]       NULL,
    [LastName]                          VARCHAR (100)            NULL,
    [NamePrefix]                        [dbo].[Code]             NULL,
    [NameSuffix]                        [dbo].[Code]             NULL,
    [Gender]                            VARCHAR (1)              NULL,
    [IsCareProvider]                    [dbo].[IsIndicator]      NOT NULL,
    [IsExternalProvider]                [dbo].[IsIndicator]      NOT NULL,
    [ProviderTypeID]                    [dbo].[KeyID]            NULL,
    [NPINumber]                         VARCHAR (80)             NULL,
    [ParentOrganizationID]              [dbo].[KeyID]            NULL,
    [TaxID_EIN_SSN]                     VARCHAR (10)             NULL,
    [ReferenceIDQualifierCode]          VARCHAR (5)              NULL,
    [SecondaryAlternativeProviderID]    VARCHAR (80)             NULL,
    [InsuranceLicenseNumber]            VARCHAR (80)             NULL,
    [DEANumber]                         VARCHAR (30)             NULL,
    [ProfessionalTypeID]                [dbo].[KeyID]            NULL,
    [ProviderURL]                       [dbo].[ShortDescription] NULL,
    [PrimaryAddressContactName]         VARCHAR (60)             NULL,
    [PrimaryAddressContactTitle]        VARCHAR (120)            NULL,
    [PrimaryAddressTypeID]              [dbo].[KeyID]            NULL,
    [PrimaryAddressLine1]               VARCHAR (60)             NULL,
    [PrimaryAddressLine2]               VARCHAR (60)             NULL,
    [PrimaryAddressLine3]               VARCHAR (60)             NULL,
    [PrimaryAddressCity]                VARCHAR (30)             NULL,
    [PrimaryAddressStateCodeID]         [dbo].[KeyID]            NULL,
    [PrimaryAddressCountyID]            [dbo].[KeyID]            NULL,
    [PrimaryAddressPostalCode]          VARCHAR (15)             NULL,
    [PrimaryAddressCountryCodeID]       [dbo].[KeyID]            NULL,
    [SecondaryAddressContactName]       VARCHAR (60)             NULL,
    [SecondaryAddressContactTitle]      VARCHAR (120)            NULL,
    [SecondaryAddressTypeID]            [dbo].[KeyID]            NULL,
    [SecondaryAddressLine1]             VARCHAR (60)             NULL,
    [SecondaryAddressLine2]             VARCHAR (60)             NULL,
    [SecondaryAddressLine3]             VARCHAR (60)             NULL,
    [SecondaryAddressCity]              VARCHAR (30)             NULL,
    [SecondaryAddressStateCodeID]       [dbo].[KeyID]            NULL,
    [SecondaryAddressCountyID]          [dbo].[KeyID]            NULL,
    [SecondaryAddressPostalCode]        VARCHAR (15)             NULL,
    [SecondaryAddressCountryCodeID]     [dbo].[KeyID]            NULL,
    [PrimaryPhoneContactName]           VARCHAR (60)             NULL,
    [PrimaryPhoneContactTitle]          VARCHAR (120)            NULL,
    [PrimaryPhoneTypeID]                [dbo].[KeyID]            NULL,
    [PrimaryPhoneNumber]                VARCHAR (20)             NULL,
    [PrimaryPhoneNumberExtension]       VARCHAR (15)             NULL,
    [SecondaryPhoneContactName]         VARCHAR (60)             NULL,
    [SecondaryPhoneContactTitle]        VARCHAR (120)            NULL,
    [SecondaryPhoneTypeID]              [dbo].[KeyID]            NULL,
    [SecondaryPhoneNumber]              VARCHAR (20)             NULL,
    [SecondaryPhoneNumberExtension]     VARCHAR (15)             NULL,
    [TertiaryPhoneContactName]          VARCHAR (60)             NULL,
    [TertiaryPhoneContactTitle]         VARCHAR (120)            NULL,
    [TertiaryPhoneTypeID]               [dbo].[KeyID]            NULL,
    [TertiaryPhoneNumber]               VARCHAR (20)             NULL,
    [TertiaryPhoneNumberExtension]      VARCHAR (15)             NULL,
    [PrimaryEmailAddressContactName]    VARCHAR (60)             NULL,
    [PrimaryEmailAddressContactTilte]   VARCHAR (120)            NULL,
    [PrimaryEmailAddressTypeID]         [dbo].[KeyID]            NULL,
    [PrimaryEmailAddress]               VARCHAR (256)            NULL,
    [SecondaryEmailAddressContactName]  VARCHAR (60)             NULL,
    [SecondaryEmailAddressContactTitle] VARCHAR (60)             NULL,
    [SecondaryEmailAddresTypeID]        [dbo].[KeyID]            NULL,
    [SecondaryEmailAddress]             VARCHAR (256)            NULL,
    [UnderWriter]                       VARCHAR (5)              NULL,
    [DataSourceID]                      [dbo].[KeyID]            NULL,
    [DataSourceFileID]                  [dbo].[KeyID]            NULL,
    [RecordTag_FileID]                  VARCHAR (30)             NULL,
    [AccountStatusCode]                 VARCHAR (20)             CONSTRAINT [DF_Provider_AccountStatus] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]                   [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                       [dbo].[UserDate]         CONSTRAINT [DF_Provider_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]              [dbo].[KeyID]            NULL,
    [LastModifiedDate]                  [dbo].[UserDate]         NULL,
    [InsuranceGroupID]                  [dbo].[KeyID]            NULL,
    CONSTRAINT [PK_Provider] PRIMARY KEY CLUSTERED ([ProviderID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Provider_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_Provider_CodeSetProfessionalType] FOREIGN KEY ([ProfessionalTypeID]) REFERENCES [dbo].[CodeSetProfessionalType] ([ProfessionalTypeID]),
    CONSTRAINT [FK_Provider_CodeSetProviderType] FOREIGN KEY ([ProviderTypeID]) REFERENCES [dbo].[CodeSetProviderType] ([ProviderTypeCodeID]),
    CONSTRAINT [FK_Provider_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_Provider_LkUpAccountStatus] FOREIGN KEY ([AccountStatusCode]) REFERENCES [dbo].[LkUpAccountStatus] ([AccountStatusCode]),
    CONSTRAINT [FK_Provider_ParentOrganizationID] FOREIGN KEY ([ParentOrganizationID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_Provider_PrimaryAddressCodeSetCountry] FOREIGN KEY ([PrimaryAddressCountryCodeID]) REFERENCES [dbo].[CodeSetCountry] ([CountryID]),
    CONSTRAINT [FK_Provider_PrimaryAddressCodeSetCounty] FOREIGN KEY ([PrimaryAddressCountyID]) REFERENCES [dbo].[CodeSetCounty] ([CountyID]),
    CONSTRAINT [FK_Provider_PrimaryAddressCodeSetState] FOREIGN KEY ([PrimaryAddressStateCodeID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_Provider_PrimaryAddressLkUpAddressType] FOREIGN KEY ([PrimaryAddressTypeID]) REFERENCES [dbo].[LkUpAddressType] ([AddressTypeID]),
    CONSTRAINT [FK_Provider_PrimaryEmailAddressLkUpEmailAddressType] FOREIGN KEY ([PrimaryEmailAddressTypeID]) REFERENCES [dbo].[LkUpEmailAddressType] ([EmailAddressTypeID]),
    CONSTRAINT [FK_Provider_PrimaryPhoneLkUpPhoneType] FOREIGN KEY ([PrimaryPhoneTypeID]) REFERENCES [dbo].[LkUpPhoneType] ([PhoneTypeID]),
    CONSTRAINT [FK_Provider_SecondaryAddressCodeSetCountry] FOREIGN KEY ([SecondaryAddressCountryCodeID]) REFERENCES [dbo].[CodeSetCountry] ([CountryID]),
    CONSTRAINT [FK_Provider_SecondaryAddressCodeSetCounty] FOREIGN KEY ([SecondaryAddressCountyID]) REFERENCES [dbo].[CodeSetCounty] ([CountyID]),
    CONSTRAINT [FK_Provider_SecondaryAddressCodeSetState] FOREIGN KEY ([SecondaryAddressStateCodeID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_Provider_SecondaryAddressLkUpAddressType] FOREIGN KEY ([SecondaryAddressTypeID]) REFERENCES [dbo].[LkUpAddressType] ([AddressTypeID]),
    CONSTRAINT [FK_Provider_SecondaryEmailAddressLkUpEmailAddressType] FOREIGN KEY ([SecondaryEmailAddresTypeID]) REFERENCES [dbo].[LkUpEmailAddressType] ([EmailAddressTypeID]),
    CONSTRAINT [FK_Provider_SecondaryPhoneLkUpPhoneType] FOREIGN KEY ([SecondaryPhoneTypeID]) REFERENCES [dbo].[LkUpPhoneType] ([PhoneTypeID]),
    CONSTRAINT [FK_Provider_TertiaryPhoneLkUpPhoneType] FOREIGN KEY ([TertiaryPhoneTypeID]) REFERENCES [dbo].[LkUpPhoneType] ([PhoneTypeID])
);


GO
CREATE STATISTICS [stat_Provider_FirstName_ProviderID]
    ON [dbo].[Provider]([FirstName], [ProviderID]);
