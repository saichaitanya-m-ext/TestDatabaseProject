CREATE TABLE [dbo].[LkUpDataType] (
    [DataTypeID]           [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [DataTypeCode]         VARCHAR (3)              NOT NULL,
    [DataTypeName]         [dbo].[ShortDescription] NOT NULL,
    [TypeDescription]      [dbo].[LongDescription]  NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_LkUpDataType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_LkUpDataType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_LkUpDataType] PRIMARY KEY CLUSTERED ([DataTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_LkUpDataType_LastProvider] FOREIGN KEY ([LastModifiedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_LkUpDataType_Provider] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpDataType_DataTypeCode]
    ON [dbo].[LkUpDataType]([DataTypeCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpDataType_DataTypeName]
    ON [dbo].[LkUpDataType]([DataTypeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

