CREATE TABLE [dbo].[CodeSetDrug] (
    [DrugCodeId]            INT            IDENTITY (1, 1) NOT NULL,
    [DrugCode]              VARCHAR (15)   NULL,
    [DrugCodeType]          VARCHAR (150)  NULL,
    [DrugName]              VARCHAR (500)  NULL,
    [DrugDescription]       VARCHAR (4000) NULL,
    [CreatedByUserId]       INT            NOT NULL,
    [CreatedDate]           DATETIME       NOT NULL,
    [LastModifiedByUserId]  INT            NULL,
    [LastModifiedDate]      DATETIME       NULL,
    [MedicationId]          INT            NULL,
    [BeginDate]             DATE           NULL,
    [EndDate]               DATE           NULL,
    [NonProprietaryName]    VARCHAR (1000) NULL,
    [PharmClasses]          VARCHAR (4000) NULL,
    [StartMarketingDate]    DATE           NULL,
    [EndMarketingDate]      DATE           NULL,
    [StatusCode]            VARCHAR (1)    NOT NULL,
    [LabelerID]             INT            NULL,
    [MarketingCategoryName] VARCHAR (50)   NULL,
    [ApplicationNumber]     VARCHAR (50)   NULL,
    [VaccineDrugID]         INT            NULL,
    CONSTRAINT [PK_CodeSetDrug] PRIMARY KEY CLUSTERED ([DrugCodeId] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CodeSetDrug_DrugCode]
    ON [dbo].[CodeSetDrug]([DrugCode] ASC) WITH (FILLFACTOR = 80)
    ON [FG_Codesets_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CodeSetDrug_VaccineDrugID]
    ON [dbo].[CodeSetDrug]([VaccineDrugID] ASC)
    INCLUDE([DrugCodeId]) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

