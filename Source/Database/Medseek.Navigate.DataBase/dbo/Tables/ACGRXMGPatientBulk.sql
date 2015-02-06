CREATE TABLE [dbo].[ACGRXMGPatientBulk] (
    [Patient_id]             NVARCHAR (50) NOT NULL,
    [RXMG_Code]              VARCHAR (10)  NULL,
    [RXMG_Description]       VARCHAR (500) NULL,
    [Major_RXMG_Code]        VARCHAR (10)  NULL,
    [Major_RXMG_Description] VARCHAR (500) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_ACGRXMGPatientBulk_Patient_id_RXMG_Code_Major_RXMG_Code]
    ON [dbo].[ACGRXMGPatientBulk]([Patient_id] ASC)
    INCLUDE([RXMG_Code], [Major_RXMG_Code]) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];

