CREATE TABLE [dbo].[ACGMedicalServicesProcess] (
    [patient_id]             VARCHAR (50) NULL,
    [ICD_Version_1]          INT          NULL,
    [ICD_CD_1]               VARCHAR (20) NULL,
    [ICD_Version_2]          INT          NULL,
    [ICD_CD_2]               VARCHAR (20) NULL,
    [ICD_Version_3]          INT          NULL,
    [ICD_CD_3]               VARCHAR (20) NULL,
    [ICD_Version_4]          INT          NULL,
    [ICD_CD_4]               VARCHAR (20) NULL,
    [ICD_Version_5]          INT          NULL,
    [ICD_CD_5]               VARCHAR (20) NULL,
    [Service_Begin_Date]     DATE         NULL,
    [Service_End_Date]       DATE         NULL,
    [Provider_ID]            INT          NULL,
    [Provider_Specialty]     VARCHAR (50) NULL,
    [Provider_Specialty_NPI] VARCHAR (50) NULL,
    [Service_place]          INT          NULL,
    [Revenue_Code]           VARCHAR (5)  NULL,
    [Procedure_Code]         VARCHAR (20) NULL,
    [Revenue_Code_type]      VARCHAR (10) NULL,
    [Procedure_Code_Type]    VARCHAR (10) NULL,
    [ACGScheduleID]          INT          NULL,
    [CareTeamId]             VARCHAR (10) NULL,
    [ProgramId]              VARCHAR (10) NULL,
    [CohortListId]           VARCHAR (10) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_ACGMedicalServicesProcess_Patient_id]
    ON [dbo].[ACGMedicalServicesProcess]([patient_id] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];

