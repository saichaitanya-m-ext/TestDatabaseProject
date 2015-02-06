CREATE TABLE [dbo].[CodeSetVaccine] (
    [VaccineID]               INT                IDENTITY (1, 1) NOT NULL,
    [CVXCode]                 VARCHAR (10)       NOT NULL,
    [VaccineShortDescription] VARCHAR (500)      NULL,
    [VaccineName]             VARCHAR (500)      NULL,
    [VaccineNote]             VARCHAR (500)      NULL,
    [VaccineStatus]           VARCHAR (10)       NULL,
    [ISVaccine]               VARCHAR (10)       NULL,
    [VaccineUpdatedDate]      DATE               NULL,
    [StatusCode]              [dbo].[StatusCode] NOT NULL,
    [DataSourceID]            [dbo].[KeyID]      NULL,
    [DataSourceFileID]        [dbo].[KeyID]      NULL,
    [CreatedByUserID]         [dbo].[KeyID]      NOT NULL,
    [CreatedDate]             [dbo].[UserDate]   NOT NULL,
    [LastModifiedByUserID]    [dbo].[KeyID]      NULL,
    [LastModifiedDate]        [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_CodeSetVaccine] PRIMARY KEY CLUSTERED ([VaccineID] ASC) ON [FG_Codesets]
);

