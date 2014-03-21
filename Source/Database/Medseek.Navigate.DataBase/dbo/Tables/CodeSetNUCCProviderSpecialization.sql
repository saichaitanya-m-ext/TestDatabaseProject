CREATE TABLE [dbo].[CodeSetNUCCProviderSpecialization] (
    [ProviderSpecializationID]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ProviderSpecializationName] [dbo].[ShortDescription] NOT NULL,
    [SpecializationDescription]  [dbo].[LongDescription]  NULL,
    [DataSourceID]               [dbo].[KeyID]            NULL,
    [DataSourceFileID]           [dbo].[KeyID]            NULL,
    [StatusCode]                 [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetNUCCProviderSpecialization_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]            INT                      NOT NULL,
    [CreatedDate]                DATETIME                 CONSTRAINT [DF_CodeSetNUCCProviderSpecialization_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]       INT                      NULL,
    [LastModifiedDate]           DATETIME                 NULL,
    CONSTRAINT [PK_CodeSetNUCCProviderSpecialization] PRIMARY KEY CLUSTERED ([ProviderSpecializationID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNUCCProviderSpecialization_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNUCCProviderSpecialization_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetNUCCProviderSpecialization_ProviderSpecializationName]
    ON [dbo].[CodeSetNUCCProviderSpecialization]([ProviderSpecializationName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

