CREATE TABLE [dbo].[LkUpFileSource] (
    [FileSourceID]         [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [FileSourceName]       [dbo].[ShortDescription] NOT NULL,
    [SourceDescription]    [dbo].[LongDescription]  NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_LkUpFileSource_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_LkUpFileSource_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_LkUpFileSource] PRIMARY KEY CLUSTERED ([FileSourceID] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpFileSource_FileSourceName]
    ON [dbo].[LkUpFileSource]([FileSourceName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

