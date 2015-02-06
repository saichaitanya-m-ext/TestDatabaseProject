CREATE TABLE [dbo].[LkUpPurposeCode] (
    [PurposeCodeID]        [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PurposeCode]          [dbo].[ShortDescription] NOT NULL,
    [PurposeDescription]   [dbo].[LongDescription]  NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_LkUpPurposeCode_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_LkUpPurposeCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_LkUpPurposeCode] PRIMARY KEY CLUSTERED ([PurposeCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_LkUpPurposeCode_LastProvider] FOREIGN KEY ([LastModifiedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_LkUpPurposeCode_Provider] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpPurposeCode_PurposeCode]
    ON [dbo].[LkUpPurposeCode]([PurposeCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

