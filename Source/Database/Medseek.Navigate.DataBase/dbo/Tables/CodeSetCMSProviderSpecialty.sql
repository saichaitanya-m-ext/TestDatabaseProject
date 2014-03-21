CREATE TABLE [dbo].[CodeSetCMSProviderSpecialty] (
    [CMSProviderSpecialtyCodeID] [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ProviderSpecialtyCode]      VARCHAR (2)              NOT NULL,
    [ProviderSpecialtyName]      [dbo].[ShortDescription] NOT NULL,
    [SpecialtyDescription]       [dbo].[LongDescription]  NULL,
    [DataSourceID]               [dbo].[KeyID]            NULL,
    [DataSourceFileID]           [dbo].[KeyID]            NULL,
    [StatusCode]                 [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetCMSProviderSpecialty_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]            INT                      NOT NULL,
    [CreatedDate]                DATETIME                 CONSTRAINT [DF_CodeSetCMSProviderSpecialty_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]       INT                      NULL,
    [LastModifiedDate]           DATETIME                 NULL,
    CONSTRAINT [PK_CodeSetCMSProviderSpecialty] PRIMARY KEY CLUSTERED ([CMSProviderSpecialtyCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetCMSProviderSpecialty_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetCMSProviderSpecialty_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE NONCLUSTERED INDEX [<IX_ProviderSpecialtyCode>]
    ON [dbo].[CodeSetCMSProviderSpecialty]([ProviderSpecialtyCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

