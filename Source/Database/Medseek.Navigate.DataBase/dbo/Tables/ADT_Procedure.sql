CREATE TABLE [dbo].[ADT_Procedure] (
    [ADTProcedureID]                                     INT           IDENTITY (1, 1) NOT NULL,
    [Patient_SetID]                                      VARCHAR (100) NULL,
    [SetId]                                              VARCHAR (150) NULL,
    [Procedure_CodingMethod]                             VARCHAR (150) NULL,
    [Procedure_Code_Identifier]                          VARCHAR (150) NULL,
    [Procedure_Code_Text]                                VARCHAR (100) NULL,
    [Procedure_Code_NameOfCodingSystem]                  VARCHAR (100) NULL,
    [Procedure_Code_AlternateIdentifier]                 VARCHAR (100) NULL,
    [Procedure_Code_AlternateText]                       VARCHAR (100) NULL,
    [Procedure_Code_NameOfAlternateCodingSystem]         VARCHAR (100) NULL,
    [Procedure_DateTime]                                 VARCHAR (100) NULL,
    [Procedure_CodeModifier_Identifier]                  VARCHAR (150) NULL,
    [Procedure_CodeModifier_Text]                        VARCHAR (100) NULL,
    [Procedure_CodeModifier_NameOfCodingSystem]          VARCHAR (100) NULL,
    [Procedure_CodeModifier_AlternateIdentifier]         VARCHAR (100) NULL,
    [Procedure_CodeModifier_AlternateText]               VARCHAR (100) NULL,
    [Procedure_CodeModifier_NameOfAlternateCodingSystem] VARCHAR (100) NULL
);

