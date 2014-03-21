CREATE TABLE [dbo].[LkUpFileType] (
    [FileTypeID]           [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [FileTypeName]         [dbo].[ShortDescription] NOT NULL,
    [TypeDescription]      [dbo].[LongDescription]  NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_LkUpFileType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_LkUpFileType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_LkUpFileType] PRIMARY KEY CLUSTERED ([FileTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_LkUpFileType_LastProvider] FOREIGN KEY ([LastModifiedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_LkUpFileType_Provider] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpFileType_FileTypeName]
    ON [dbo].[LkUpFileType]([FileTypeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

