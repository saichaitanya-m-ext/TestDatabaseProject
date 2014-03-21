CREATE TABLE [dbo].[ACGPharmacySpansPatientBulk] (
    [Patient_id]                      NVARCHAR (50) NOT NULL,
    [condition_name]                  VARCHAR (100) NULL,
    [rx_drug_class]                   VARCHAR (100) NULL,
    [rx_drug_ingredient]              VARCHAR (100) NULL,
    [rx_fill_date]                    DATETIME      NULL,
    [rx_refill_date]                  DATETIME      NULL,
    [rx_days_supply]                  INT           NULL,
    [rx_ip_days]                      INT           NULL,
    [days_carried_over]               INT           NULL,
    [rx_supply_begin_date]            DATETIME      NULL,
    [rx_supply_end_date]              DATETIME      NULL,
    [rx_supply_available_upon_refill] INT           NULL,
    [rx_grace_period]                 INT           NULL,
    [rx_days_exceeding_grace_period]  INT           NULL,
    [rx_eligible_for_adherence]       CHAR (1)      NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_ACGPharmacySpansPatientBulk_Patient_id]
    ON [dbo].[ACGPharmacySpansPatientBulk]([Patient_id] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];

