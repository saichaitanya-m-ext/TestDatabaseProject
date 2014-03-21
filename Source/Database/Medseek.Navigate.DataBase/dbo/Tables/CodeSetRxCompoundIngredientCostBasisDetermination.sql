CREATE TABLE [dbo].[CodeSetRxCompoundIngredientCostBasisDetermination] (
    [RxCompoundIngredientCostBasisDeterminationID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [RxCompoundIngredientCostBasisDeterminationCode] VARCHAR (5)             NOT NULL,
    [RxCompoundIngredientCostBasisDeterminationName] VARCHAR (30)            NOT NULL,
    [CodeDescription]                                [dbo].[LongDescription] NULL,
    [DataSourceID]                                   [dbo].[KeyID]           NULL,
    [DataSourceFileID]                               [dbo].[KeyID]           NULL,
    [StatusCode]                                     [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetRxCompoundIngredientCostBasisDetermination_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]                                INT                     NOT NULL,
    [CreatedDate]                                    DATETIME                CONSTRAINT [DF_CodeSetRxCompoundIngredientCostBasisDetermination_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]                           INT                     NULL,
    [LastModifiedDate]                               DATETIME                NULL,
    CONSTRAINT [PK_CodeSetRxCompoundIngredientCostBasisDetermination] PRIMARY KEY CLUSTERED ([RxCompoundIngredientCostBasisDeterminationID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetRxCompoundIngredientCostBasisDetermination_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetRxCompoundIngredientCostBasisDetermination_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxCompoundIngredientCostBasisDetermination_DeterminationCode]
    ON [dbo].[CodeSetRxCompoundIngredientCostBasisDetermination]([RxCompoundIngredientCostBasisDeterminationCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxCompoundIngredientCostBasisDetermination_DeterminationName]
    ON [dbo].[CodeSetRxCompoundIngredientCostBasisDetermination]([RxCompoundIngredientCostBasisDeterminationName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

