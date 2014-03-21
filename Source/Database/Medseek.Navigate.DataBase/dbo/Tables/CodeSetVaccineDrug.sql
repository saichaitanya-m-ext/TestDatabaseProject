CREATE TABLE [dbo].[CodeSetVaccineDrug] (
    [VaccineDrugID]           INT                IDENTITY (1, 1) NOT NULL,
    [DrugLabellerProductCode] VARCHAR (20)       NULL,
    [DrugManufacturerCode]    VARCHAR (5)        NULL,
    [DrugCodeStatus]          VARCHAR (10)       NULL,
    [DrugCDCContractStatus]   VARCHAR (10)       NULL,
    [DrugLastUpdatedDate]     DATE               NULL,
    [DrugNote]                VARCHAR (500)      NULL,
    [VaccineID]               INT                NULL,
    [StatusCode]              [dbo].[StatusCode] NOT NULL,
    [DataSourceID]            [dbo].[KeyID]      NULL,
    [DataSourceFileID]        [dbo].[KeyID]      NULL,
    [CreatedByUserID]         [dbo].[KeyID]      NOT NULL,
    [CreatedDate]             [dbo].[UserDate]   NOT NULL,
    [LastModifiedByUserID]    [dbo].[KeyID]      NULL,
    [LastModifiedDate]        [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_CodeSetVaccineDrug] PRIMARY KEY CLUSTERED ([VaccineDrugID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetVaccineDrug_CodeSetVaccine] FOREIGN KEY ([VaccineID]) REFERENCES [dbo].[CodeSetVaccine] ([VaccineID])
);

