CREATE TABLE [dbo].[LkUpPhoneType] (
    [PhoneTypeID]          [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PhoneTypeCode]        VARCHAR (3)              NOT NULL,
    [PhoneTypeName]        [dbo].[ShortDescription] NOT NULL,
    [TypeDescription]      [dbo].[LongDescription]  NULL,
    [DataSourceID]         [dbo].[KeyID]            NULL,
    [DataSourceFileID]     [dbo].[KeyID]            NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_LkUpPhoneType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_LkUpPhoneType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_LkUpPhoneType] PRIMARY KEY CLUSTERED ([PhoneTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_LkUpPhoneType_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_LkUpPhoneType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_LkUpPhoneType_LastProvider] FOREIGN KEY ([LastModifiedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_LkUpPhoneType_Provider] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpPhoneType_PhoneTypeCode]
    ON [dbo].[LkUpPhoneType]([PhoneTypeCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpPhoneType_PhoneTypeName]
    ON [dbo].[LkUpPhoneType]([PhoneTypeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

