CREATE TABLE [dbo].[CodeSetVaccineProcedure] (
    [VaccineProcedureID]       INT                IDENTITY (1, 1) NOT NULL,
    [ProcedureCode]            VARCHAR (20)       NOT NULL,
    [ProcedureDescription]     VARCHAR (500)      NULL,
    [ProcedureCodeStatus]      VARCHAR (10)       NULL,
    [ProcedureComment]         VARCHAR (500)      NULL,
    [ProcedureLastUpdatedDate] DATE               NULL,
    [VaccineID]                INT                NULL,
    [StatusCode]               [dbo].[StatusCode] NOT NULL,
    [DataSourceID]             [dbo].[KeyID]      NULL,
    [DataSourceFileID]         [dbo].[KeyID]      NULL,
    [CreatedByUserID]          [dbo].[KeyID]      NOT NULL,
    [CreatedDate]              [dbo].[UserDate]   NOT NULL,
    [LastModifiedByUserID]     [dbo].[KeyID]      NULL,
    [LastModifiedDate]         [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_CodeSetVaccineProcedure] PRIMARY KEY CLUSTERED ([VaccineProcedureID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetVaccineProcedure_CodeSetVaccine] FOREIGN KEY ([VaccineID]) REFERENCES [dbo].[CodeSetVaccine] ([VaccineID])
);

