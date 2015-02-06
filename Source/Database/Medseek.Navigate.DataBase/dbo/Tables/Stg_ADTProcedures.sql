CREATE TABLE [dbo].[Stg_ADTProcedures] (
    [Patient_PrimaryId_Id]                               UNIQUEIDENTIFIER NULL,
    [Procedure_SetId]                                    VARCHAR (200)    NULL,
    [Procedure_CodingMethod]                             VARCHAR (200)    NULL,
    [Procedure_Code_Identifier]                          VARCHAR (200)    NULL,
    [Procedure_Code_Text]                                VARCHAR (200)    NULL,
    [Procedure_Code_NameOfCodingSystem]                  VARCHAR (200)    NULL,
    [Procedure_Code_NameOfAlternateCodingSystem]         VARCHAR (200)    NULL,
    [Procedure_DateTime]                                 VARCHAR (200)    NULL,
    [Procedure_CodeModifier_Identifier]                  VARCHAR (200)    NULL,
    [Procedure_CodeModifier_Text]                        VARCHAR (200)    NULL,
    [Procedure_CodeModifier_NameOfCodingSystem]          VARCHAR (200)    NULL,
    [Procedure_CodeModifier_NameOfAlternateCodingSystem] VARCHAR (200)    NULL,
    [EventType]                                          VARCHAR (10)     NULL
);

