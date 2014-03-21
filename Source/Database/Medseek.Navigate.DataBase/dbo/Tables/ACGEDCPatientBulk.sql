CREATE TABLE [dbo].[ACGEDCPatientBulk] (
    [Patient_id]       NVARCHAR (50) NOT NULL,
    [EDC_Code]         VARCHAR (10)  NOT NULL,
    [EDC_Description]  VARCHAR (500) NULL,
    [MEDC_Code]        VARCHAR (10)  NOT NULL,
    [MEDC_Description] VARCHAR (500) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_ACGEDCPatientBulk_Patient_id_EDC_Code_MEDC_Code]
    ON [dbo].[ACGEDCPatientBulk]([Patient_id] ASC)
    INCLUDE([EDC_Code], [MEDC_Code]) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];

