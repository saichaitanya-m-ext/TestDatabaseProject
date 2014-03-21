﻿CREATE TABLE [dbo].[Stg_ADTInsuranceDetails] (
    [Patient_PrimaryId_Id]                                                      UNIQUEIDENTIFIER NULL,
    [HealthPlanId_Identifier]                                                   VARCHAR (200)    NULL,
    [HealthPlanId_NameOfCodingSystem]                                           VARCHAR (200)    NULL,
    [HealthPlanId_NameOfAlternateCodingSystem]                                  VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyId_Id]                                    VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyId_TypeCode]                              VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyName]                                     VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyAddresses_Address_StreetAddress]          VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyAddresses_Address_City]                   VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyAddresses_Address_StateOrProvince]        VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyAddresses_Address_ZipOrPostalCode]        VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyAddresses_Address_Country]                VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyAddresses_Address_AddressType]            VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_EquipmentType] VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_CountryCode]   VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_AreaCode]      VARCHAR (200)    NULL,
    [InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_LocalNumber]   VARCHAR (200)    NULL,
    [GroupNumber]                                                               VARCHAR (200)    NULL,
    [GroupName_OrganizationName]                                                VARCHAR (200)    NULL,
    [InsuredGroupEmployerName]                                                  VARCHAR (200)    NULL,
    [PlanEffectiveDate]                                                         VARCHAR (200)    NULL,
    [PlanExpiryDate]                                                            VARCHAR (200)    NULL,
    [PlanType_Identifier]                                                       VARCHAR (200)    NULL,
    [InsuredNames_NAME_FamilyName]                                              VARCHAR (200)    NULL,
    [InsuredNames_NAME_GivenName]                                               VARCHAR (200)    NULL,
    [InsuredRelationshipToPatient]                                              VARCHAR (200)    NULL,
    [InsuredDateOfBirth]                                                        VARCHAR (200)    NULL,
    [InsuredAddresses_Address_StreetAddress]                                    VARCHAR (200)    NULL,
    [InsuredAddresses_Address_City]                                             VARCHAR (200)    NULL,
    [InsuredAddresses_Address_StateOrProvince]                                  VARCHAR (200)    NULL,
    [InsuredAddresses_Address_ZipOrPostalCode]                                  VARCHAR (200)    NULL,
    [InsuredAddresses_Address_Country]                                          VARCHAR (200)    NULL,
    [InsuredAddresses_Address_AddressType]                                      VARCHAR (200)    NULL,
    [CompanyPlanCode_NameOfCodingSystem]                                        VARCHAR (200)    NULL,
    [CompanyPlanCode_NameOfAlternateCodingSystem]                               VARCHAR (200)    NULL,
    [PolicyNumber]                                                              VARCHAR (200)    NULL,
    [InsuredSSN]                                                                VARCHAR (200)    NULL,
    [InsuredHomePhoneNumbers]                                                   VARCHAR (200)    NULL,
    [PatientRelationshipToInsured]                                              VARCHAR (200)    NULL,
    [EventType]                                                                 VARCHAR (10)     NULL
);

