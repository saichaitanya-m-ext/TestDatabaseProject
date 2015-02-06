CREATE TABLE [dbo].[CodeSetAPRDRG] (
    [APRDRGCodeID]         [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [APRDRGCode]           VARCHAR (10)            NOT NULL,
    [APRDRGCodeName]       VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [BeginDate]            DATE                    NOT NULL,
    [EndDate]              DATE                    NOT NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetAPRDRG_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetAPRDRG_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetAPRDRG] PRIMARY KEY CLUSTERED ([APRDRGCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetAPRDRG_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetAPRDRG_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetAPRDRG_APRDRGCode]
    ON [dbo].[CodeSetAPRDRG]([APRDRGCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetAPRDRG_APRDRGCodeName]
    ON [dbo].[CodeSetAPRDRG]([APRDRGCodeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

