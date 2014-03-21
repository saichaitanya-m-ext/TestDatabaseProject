CREATE TABLE [dbo].[ADTInsurance] (
    [InsuranceID]                  [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [SetID]                        VARCHAR (50)     NULL,
    [HealthPlanID]                 VARCHAR (50)     NULL,
    [InsuranceCompanyID]           VARCHAR (50)     NULL,
    [InsuranceCompanyName]         VARCHAR (50)     NULL,
    [InsuranceCompanyAddress]      VARCHAR (50)     NULL,
    [InsuranceCoContactPerson]     VARCHAR (50)     NULL,
    [InsuranceCoPhoneNumber]       VARCHAR (50)     NULL,
    [GroupNumber]                  VARCHAR (50)     NULL,
    [GroupName]                    VARCHAR (50)     NULL,
    [PlanEffectiveDate]            [dbo].[UserDate] NULL,
    [PlanExpirationDate]           [dbo].[UserDate] NULL,
    [PlanType]                     VARCHAR (50)     NULL,
    [NameOfInsured]                VARCHAR (50)     NULL,
    [InsuredRelationshipToPatient] VARCHAR (50)     NULL,
    [InsuredDateOfBirth]           [dbo].[UserDate] NULL,
    [InsuredAddress]               VARCHAR (50)     NULL,
    [PolicyNumber]                 VARCHAR (50)     NULL,
    [CreatedDate]                  [dbo].[UserDate] CONSTRAINT [DF_ADTInsurance_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ADTInsurance] PRIMARY KEY CLUSTERED ([InsuranceID] ASC)
);

