CREATE TABLE [dbo].[ACGMEDCPatientBulk] (
    [Patient_id]       NVARCHAR (50) NOT NULL,
    [MEDC_Code]        VARCHAR (10)  NOT NULL,
    [MEDC_Description] VARCHAR (500) NULL,
    CONSTRAINT [PK_ACGMEDCPatientBulk_Patient_Id_MEDC_Code] PRIMARY KEY CLUSTERED ([Patient_id] ASC, [MEDC_Code] ASC) ON [FG_Library]
);

