CREATE TABLE [dbo].[ACGPharmacyProcess] (
    [patient_id]     VARCHAR (50) NULL,
    [Rx_Fill_Date]   DATE         NULL,
    [Rx_Code]        VARCHAR (20) NULL,
    [Rx_Code_Type]   VARCHAR (10) NULL,
    [Rx_Days_Supply] SMALLINT     NULL,
    [ACGScheduleID]  INT          NULL,
    [CareTeamId]     VARCHAR (10) NULL,
    [ProgramId]      VARCHAR (10) NULL,
    [CohortListId]   VARCHAR (10) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_ACGPharmacyProcess_Patient_id_Rx_Code]
    ON [dbo].[ACGPharmacyProcess]([patient_id] ASC)
    INCLUDE([Rx_Code]) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];

