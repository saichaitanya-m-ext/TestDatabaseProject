CREATE TABLE [dbo].[CodeSetEmploymentStatus] (
    [EmploymentStatusID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [EmploymentStatus]     VARCHAR (30)            NOT NULL,
    [StatusDescription]    [dbo].[LongDescription] NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetEmploymentStatus_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_CodeSetEmploymentStatusCreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    CONSTRAINT [PK_CodeSetEmploymentStatus] PRIMARY KEY CLUSTERED ([EmploymentStatusID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetEmploymentStatus_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetEmploymentStatus_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetEmploymentStatus_EmploymentStatus]
    ON [dbo].[CodeSetEmploymentStatus]([EmploymentStatus] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

