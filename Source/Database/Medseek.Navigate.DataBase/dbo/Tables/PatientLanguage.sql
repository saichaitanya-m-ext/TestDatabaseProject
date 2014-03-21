CREATE TABLE [dbo].[PatientLanguage] (
    [PatientLanguageID]    [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [PatientID]            [dbo].[KeyID]       NOT NULL,
    [LanguageID]           [dbo].[KeyID]       NOT NULL,
    [IsPrimarySpoken]      [dbo].[IsIndicator] NOT NULL,
    [IsPrimaryWritten]     [dbo].[IsIndicator] NOT NULL,
    [DataSourceID]         [dbo].[KeyID]       NULL,
    [DataSourceFileID]     [dbo].[KeyID]       NULL,
    [RecordTagFileID]      VARCHAR (30)        NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_PatientLanguage_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_PatientLanguage] PRIMARY KEY CLUSTERED ([PatientID] ASC, [LanguageID] ASC),
    CONSTRAINT [FK_PatientLanguage_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientLanguage_CodeSetLanguage] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[CodeSetLanguage] ([LanguageID]),
    CONSTRAINT [FK_PatientLanguage_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientLanguage_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);

