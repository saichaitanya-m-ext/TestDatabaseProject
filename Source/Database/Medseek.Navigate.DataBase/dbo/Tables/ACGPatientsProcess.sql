CREATE TABLE [dbo].[ACGPatientsProcess] (
    [patient_id]                      VARCHAR (50)  NULL,
    [Age]                             INT           NULL,
    [Sex]                             VARCHAR (1)   NULL,
    [Line_of_Business]                VARCHAR (100) NULL,
    [Company]                         VARCHAR (100) NULL,
    [Product]                         VARCHAR (100) NULL,
    [Employer_Group_ID]               VARCHAR (20)  NULL,
    [Employer_Group_Name]             VARCHAR (100) NULL,
    [Benefit_Plan]                    VARCHAR (50)  NULL,
    [Health_System]                   VARCHAR (50)  NULL,
    [PCP_ID]                          VARCHAR (50)  NULL,
    [PCP_Name]                        VARCHAR (50)  NULL,
    [PCP_Group_Name]                  VARCHAR (50)  NULL,
    [Pregnant]                        SMALLINT      NULL,
    [Delivered]                       SMALLINT      NULL,
    [Low_Birthweight]                 SMALLINT      NULL,
    [Total_Cost]                      MONEY         NULL,
    [Pharmacy_Cost]                   MONEY         NULL,
    [Inpatient_hospitalization_Count] SMALLINT      NULL,
    [Emergency_Visit_Count]           SMALLINT      NULL,
    [OutPatient_Visit_Count]          SMALLINT      NULL,
    [Dialysis_Service]                SMALLINT      NULL,
    [Nursing_Service]                 SMALLINT      NULL,
    [Major_Procedure]                 INT           NULL,
    [ACGScheduleID]                   VARCHAR (5)   NULL,
    [CohortListId]                    VARCHAR (10)  NULL,
    [ProgramId]                       VARCHAR (10)  NULL,
    [CareTeamId]                      VARCHAR (10)  NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_ACGPatientsProcess_Patient_id]
    ON [dbo].[ACGPatientsProcess]([patient_id] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];

