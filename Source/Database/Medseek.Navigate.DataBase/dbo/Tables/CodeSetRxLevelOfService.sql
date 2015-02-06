CREATE TABLE [dbo].[CodeSetRxLevelOfService] (
    [RxLevelOfServiceID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [RxLevelOfServiceCode] VARCHAR (5)             NOT NULL,
    [RxLevelOfServiceName] VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetRxLevelOfService_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetRxLevelOfService_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetRxLevelOfService] PRIMARY KEY CLUSTERED ([RxLevelOfServiceID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetRxLevelOfService_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetRxLevelOfService_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxLevelOfService_ServiceCode]
    ON [dbo].[CodeSetRxLevelOfService]([RxLevelOfServiceCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxLevelOfService_ServiceName]
    ON [dbo].[CodeSetRxLevelOfService]([RxLevelOfServiceName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

