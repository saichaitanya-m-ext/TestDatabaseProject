CREATE TABLE [dbo].[CodeSetConditionCode] (
    [ConditionCodeID]      [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [ConditionCode]        VARCHAR (10)            NOT NULL,
    [ConditionName]        VARCHAR (30)            NOT NULL,
    [CodeDescription]      [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetConditionCode_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetConditionCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetConditionCode] PRIMARY KEY CLUSTERED ([ConditionCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetConditionCode_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetConditionCode_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetConditionCode_ConditionCode]
    ON [dbo].[CodeSetConditionCode]([ConditionCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetConditionCode_ConditionName]
    ON [dbo].[CodeSetConditionCode]([ConditionName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

