CREATE TABLE [dbo].[ACGADGPatientBulk] (
    [Patient_id]      NVARCHAR (50) NULL,
    [ADG_Code]        VARCHAR (200) NULL,
    [ADG_Description] VARCHAR (500) NULL
);


GO
CREATE NONCLUSTERED INDEX [UI_ACGADGPatientBulk_Patient_id_ADG_Code]
    ON [dbo].[ACGADGPatientBulk]([Patient_id] ASC)
    INCLUDE([ADG_Code]) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];

