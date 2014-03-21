CREATE TABLE [dbo].[ADTDiagnoses] (
    [Patient_PrimaryId_Id]                       UNIQUEIDENTIFIER NULL,
    [Diagnosis_SetId]                            VARCHAR (200)    NULL,
    [Diagnosis_CodingMethod]                     VARCHAR (200)    NULL,
    [Diagnosis_Code_Identifier]                  VARCHAR (200)    NULL,
    [Diagnosis_Code_Text]                        VARCHAR (200)    NULL,
    [Diagnosis_Code_NameOfCodingSystem]          VARCHAR (200)    NULL,
    [Diagnosis_Code_NameOfAlternateCodingSystem] VARCHAR (200)    NULL,
    [Diagnosis_DateTime]                         VARCHAR (200)    NULL,
    [Diagnosis_Type_Identifier]                  VARCHAR (200)    NULL,
    [Diagnosis_Type_NameOfCodingSystem]          VARCHAR (200)    NULL,
    [Diagnosis_Type_NameOfAlternateCodingSystem] VARCHAR (200)    NULL,
    [Diagnosis_Clinician_PersonIdentifier]       VARCHAR (200)    NULL,
    [Diagnosis_Clinician_FamilyName]             VARCHAR (200)    NULL,
    [Diagnosis_Clinician_GivenName]              VARCHAR (200)    NULL,
    [EventType]                                  VARCHAR (100)    NULL
);

