CREATE TABLE [dbo].[LkUpEDIClaimType] (
    [EDIClaimTypeID]       [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [EDIClaimTypeCode]     VARCHAR (5)             NOT NULL,
    [EDIClaimTypeName]     VARCHAR (30)            NOT NULL,
    [TypeDescription]      [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_LkUpEDIClaimType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]           CONSTRAINT [DF_LkUpEDIClaimType_CreatedByUserID] DEFAULT ((1)) NOT NULL,
    [CreatedDate]          [dbo].[UserDate]        CONSTRAINT [DF_LkUpEDIClaimType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]           NULL,
    [LastModifiedDate]     [dbo].[UserDate]        NULL,
    CONSTRAINT [PK_LkUpEDIClaimType] PRIMARY KEY CLUSTERED ([EDIClaimTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_LkUpEDIClaimType_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_LkUpEDIClaimType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

