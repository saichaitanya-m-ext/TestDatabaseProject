CREATE TABLE [dbo].[ProviderUser] (
    [ProviderUserID]       [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [ProviderID]           [dbo].[KeyID]    NOT NULL,
    [PatientID]            [dbo].[KeyID]    NOT NULL,
    [DataSourceID]         [dbo].[KeyID]    NULL,
    [DataSourceFileID]     [dbo].[KeyID]    NULL,
    [RecordTag_FileID]     VARCHAR (30)     NULL,
    [StatusCode]           VARCHAR (1)      CONSTRAINT [DF_ProviderUser_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]    NOT NULL,
    [CreatedDate]          [dbo].[UserDate] CONSTRAINT [DF_ProviderUser_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]    NULL,
    [LastModifiedDate]     [dbo].[UserDate] NULL,
    CONSTRAINT [PK_ProviderUser] PRIMARY KEY CLUSTERED ([ProviderID] ASC, [PatientID] ASC),
    CONSTRAINT [FK_ProviderUser_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ProviderUser_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_ProviderUser_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_ProviderUser_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);

