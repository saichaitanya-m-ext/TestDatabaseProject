CREATE TABLE [dbo].[CodeSetSpecialtyDrugCategory] (
    [SpecialtyDrugCategoryID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [SpecialtyDrugCategoryCode] VARCHAR (5)             NOT NULL,
    [SpecialtyDrugCategoryName] VARCHAR (30)            NOT NULL,
    [CodeDescription]           [dbo].[LongDescription] NULL,
    [DataSourceID]              [dbo].[KeyID]           NULL,
    [DataSourceFileID]          [dbo].[KeyID]           NULL,
    [StatusCode]                [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetSpecialtyDrugCategory_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]           [dbo].[KeyID]           NOT NULL,
    [CreatedDate]               DATETIME                CONSTRAINT [DF_CodeSetSpecialtyDrugCategory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]      [dbo].[KeyID]           NULL,
    [LastModifiedDate]          DATETIME                NULL,
    CONSTRAINT [PK_CodeSetSpecialtyDrugCategory] PRIMARY KEY CLUSTERED ([SpecialtyDrugCategoryID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetSpecialtyDrugCategory_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetSpecialtyDrugCategory_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetSpecialtyDrugCategory_CategoryCode]
    ON [dbo].[CodeSetSpecialtyDrugCategory]([SpecialtyDrugCategoryCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetSpecialtyDrugCategory_CategoryName]
    ON [dbo].[CodeSetSpecialtyDrugCategory]([SpecialtyDrugCategoryName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

